import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:app_sin_nombre/services/home_service.dart';
import 'package:app_sin_nombre/globals.dart';
import 'package:app_sin_nombre/models/post.dart';
import 'package:app_sin_nombre/services/create_post.dart';
import 'package:app_sin_nombre/screens/ubicacion_post.dart';
import 'package:app_sin_nombre/screens/mapa.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

class PublicarAvisoCompleto extends StatefulWidget {
  const PublicarAvisoCompleto({super.key});

  @override
  State<PublicarAvisoCompleto> createState() => _PublicarAvisoCompletoState();
}

class _PublicarAvisoCompletoState extends State<PublicarAvisoCompleto> {
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _ciudadController = TextEditingController(text: 'Mendoza');
  final _direccionController = TextEditingController();
  final _localidadController = TextEditingController();

  String? _rubroSeleccionadoId;
  String? _rubroSeleccionadoNombre;
  double? _latitud = -32.8908; // Mendoza por defecto
  double? _longitud = -68.8272; // Mendoza por defecto

  List<PlatformFile> _matriculas = [];
  List<PlatformFile> _certificaciones = [];
  List<PlatformFile> _fotos = [];

  List<String> matriculasUrls = [];
  List<String> certificadosUrls = [];
  List<String> fotosUrls = [];

  final Color rojoPastel = const Color.fromARGB(255, 255, 99, 99);
  final Color blanco = const Color.fromARGB(255, 255, 255, 255);

  bool _subiendo = false;
  bool _cancelarSubida = false;

  List<Map<String, String>> _rubros = [];
  bool _rubrosCargando = true;

  Future<String?> _subirArchivoFirebase(
    PlatformFile file,
    String carpeta,
  ) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(
        '$carpeta/${file.name}',
      );
      final uploadTask = storageRef.putFile(File(file.path!));
      final snapshot = await uploadTask;
      final url = await snapshot.ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Error subiendo archivo $file: $e');
      return null;
    }
  }

  Future<void> _pickFiles(List<PlatformFile> lista, int maxFiles) async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        lista.clear();
        lista.addAll(result.files.take(maxFiles));
      });
    }
  }

  void _removeFile(List<PlatformFile> lista, int index) {
    setState(() {
      lista.removeAt(index);
    });
  }

  Future<void> _publicar() async {
    if (_rubroSeleccionadoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor seleccioná un rubro')),
      );
      return;
    }

    if (_latitud == null || _longitud == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debés seleccionar una ubicación')),
      );
      return;
    }

    if (_ciudadController.text.isEmpty ||
        _direccionController.text.isEmpty ||
        _localidadController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completá los datos de ubicación')),
      );
      return;
    }

    if (_tituloController.text.isEmpty || _descripcionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completá el título y la descripción')),
      );
      return;
    }

    final snackBarLoading = SnackBar(
      content: Row(
        children: const [
          CircularProgressIndicator(),
          SizedBox(width: 20),
          Text('Subiendo archivos...'),
        ],
      ),
      duration: const Duration(minutes: 5),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBarLoading);

    matriculasUrls.clear();
    certificadosUrls.clear();
    fotosUrls.clear();

    setState(() {
      _subiendo = true;
      _cancelarSubida = false;
    });

    for (var file in _matriculas) {
      if (_cancelarSubida) break;
      final url = await cargardocumento(File(file.path!));
      matriculasUrls.add(url);
    }

    for (var file in _certificaciones) {
      if (_cancelarSubida) break;
      final url = await cargardocumento(File(file.path!));
      certificadosUrls.add(url);
    }

    for (var file in _fotos) {
      if (_cancelarSubida) break;
      final url = await cargardocumento(File(file.path!));
      fotosUrls.add(url);
    }
    setState(() {
      _subiendo = false;
    });
    if (_cancelarSubida) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subida cancelada por el usuario.')),
      );
      return;
    }

    final post = Post(
      uid: Globals.userId ?? '',
      rubs: [_rubroSeleccionadoId!],
      title: _tituloController.text,
      description: _descripcionController.text,
      ubicacion: Ubicacion(
        ciudad: _ciudadController.text,
        direccion: _direccionController.text,
        localidad: _localidadController.text,
        latitud: _latitud!.toString(),
        longitud: _longitud!.toString(),
      ),
      matricula:
          matriculasUrls.isNotEmpty
              ? Matricula(url: matriculasUrls.first)
              : Matricula(url: ''),
      certificaciones: certificadosUrls,
      fotos: fotosUrls,
      fechaPost: DateTime.now(),
    );

    try {
      await enviarPostAlBackend(post);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Publicado con éxito')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Error al publicar')));
    }
  }

  Widget paso(String titulo, Widget contenido) => Container(
    width: double.infinity,
    child: Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      color: const Color.fromARGB(255, 255, 244, 244),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            contenido,
          ],
        ),
      ),
    ),
  );

  Widget _listaArchivos(
    List<PlatformFile> archivos,
    void Function(int) onRemove,
  ) {
    return Wrap(
      spacing: 8,
      children: List.generate(
        archivos.length,
        (i) => Chip(
          label: Text(archivos[i].name, overflow: TextOverflow.ellipsis),
          backgroundColor: blanco,
          deleteIcon: const Icon(Icons.close),
          onDeleted: () => onRemove(i),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _cargarRubros();
  }

  Future<void> _cargarRubros() async {
    final rubros = await TargetService().getRubros();
    setState(() {
      _rubros = rubros.map((r) => {'id': r.id, 'nombre': r.nombre}).toList();
      _rubrosCargando = false;
    });
  }

  Widget _buildRubrosDropdown() {
    if (_rubrosCargando) {
      return const Center(child: CircularProgressIndicator());
    }
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Rubro (obligatorio)',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey[50],
        prefixIcon: const Icon(Icons.category),
      ),
      value: _rubroSeleccionadoId,
      items:
          _rubros.map((rubro) {
            return DropdownMenuItem<String>(
              value: rubro['id'],
              child: Text(rubro['nombre'] ?? ''),
            );
          }).toList(),
      onChanged: (value) {
        setState(() {
          _rubroSeleccionadoId = value;
          _rubroSeleccionadoNombre =
              _rubros.firstWhere((r) => r['id'] == value)['nombre'];
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blanco,
      appBar: AppBar(
        title: const Text('Publicar Aviso'),
        backgroundColor: blanco,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Paso 1: Datos del aviso
            paso(
              'Datos del aviso',
              Column(
                children: [
                  const SizedBox(height: 8),
                  _buildTextField(_tituloController, 'Título', Icons.title),
                  const SizedBox(height: 8),
                  _buildTextField(
                    _descripcionController,
                    'Descripción',
                    Icons.description,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),
                  _buildRubrosDropdown(),
                ],
              ),
            ),
            // Paso 2: Ubicación
            paso(
              'Ubicación',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMapButton(),
                  const SizedBox(height: 8),
                  _buildLocationInfo(),
                ],
              ),
            ),
            // Paso 3: Archivos
            paso(
              'Archivos (opcional)',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFileSection(
                    'Matrículas',
                    _matriculas,
                    3,
                    _pickFiles,
                    _removeFile,
                  ),
                  const SizedBox(height: 8),
                  _buildFileSection(
                    'Certificaciones',
                    _certificaciones,
                    3,
                    _pickFiles,
                    _removeFile,
                  ),
                ],
              ),
            ),
            // Paso 4: Fotos
            paso(
              'Fotos de trabajos (máx 6)',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFileSection(
                    'Fotos',
                    _fotos,
                    6,
                    _pickFiles,
                    _removeFile,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (_subiendo)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.cancel),
                  label: const Text('Cancelar subida'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[700],
                    foregroundColor: blanco,
                  ),
                  onPressed: () {
                    setState(() {
                      _cancelarSubida = true;
                    });
                  },
                ),
              ),
            _buildPublishButton(),
          ],
        ),
      ),
    );
  }

  // Widgets auxiliares para mejor UX
  Widget _buildWarning() => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(
      color: Colors.yellow[100],
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.amber, width: 1),
    ),
    child: Row(
      children: [
        const Icon(Icons.warning, color: Colors.amber),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '¡Seleccionar Rubro es obligatorio!',
            style: TextStyle(
              color: Colors.amber[900],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) => TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      filled: true,
      fillColor: Colors.grey[50],
    ),
    maxLines: maxLines,
  );

  Widget _buildMapButton() => ElevatedButton.icon(
    icon: const Icon(Icons.map),
    label: const Text('Seleccionar desde el mapa'),
    style: ElevatedButton.styleFrom(
      backgroundColor: rojoPastel,
      foregroundColor: blanco,
      minimumSize: const Size.fromHeight(48),
    ),
    onPressed: () async {
      final LatLng? result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MapaScreen()),
      );
      if (result != null) {
        setState(() {
          _latitud = result.latitude;
          _longitud = result.longitude;
        });
        // Geocodificación inversa con Nominatim
        final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${result.latitude}&lon=${result.longitude}&zoom=18&addressdetails=1',
        );
        final response = await http.get(
          url,
          headers: {'User-Agent': 'FlutterApp'},
        );
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final address = data['address'] ?? {};
          setState(() {
            _ciudadController.text =
                address['city'] ??
                address['town'] ??
                address['village'] ??
                _ciudadController.text;
            _direccionController.text =
                address['road'] != null
                    ? '${address['road']} ${address['house_number'] ?? ''}'
                        .trim()
                    : _direccionController.text;
            _localidadController.text =
                address['state'] ??
                address['suburb'] ??
                _localidadController.text;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se seleccionó una ubicación válida.'),
          ),
        );
      }
    },
  );

  Widget _buildLocationInfo() =>
      (_latitud != null && _longitud != null)
          ? Card(
            color: Colors.green[50],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Ubicación seleccionada: ($_latitud, $_longitud)',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          )
          : const SizedBox.shrink();

  Widget _buildFileSection(
    String label,
    List<PlatformFile> archivos,
    int maxFiles,
    Future<void> Function(List<PlatformFile>, int) pickFiles,
    void Function(List<PlatformFile>, int) removeFile,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ElevatedButton.icon(
        icon: const Icon(Icons.attach_file),
        label: Text('Seleccionar $label (${archivos.length}/$maxFiles)'),
        style: ElevatedButton.styleFrom(
          backgroundColor: rojoPastel,
          foregroundColor: blanco,
          minimumSize: const Size.fromHeight(40),
        ),
        onPressed: () => pickFiles(archivos, maxFiles),
      ),
      if (archivos.isNotEmpty)
        Wrap(
          spacing: 8,
          children: List.generate(
            archivos.length,
            (i) => Chip(
              label: Text(archivos[i].name, overflow: TextOverflow.ellipsis),
              backgroundColor: blanco,
              deleteIcon: const Icon(Icons.close),
              onDeleted: () => removeFile(archivos, i),
            ),
          ),
        ),
    ],
  );

  Widget _buildPublishButton() => ElevatedButton.icon(
    icon: const Icon(Icons.publish),
    label: const Text('Publicar Aviso'),
    onPressed: _publicar,
    style: ElevatedButton.styleFrom(
      backgroundColor: rojoPastel,
      foregroundColor: blanco,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      minimumSize: const Size.fromHeight(48),
      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
