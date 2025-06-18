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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blanco,
      appBar: AppBar(
        title: const Text('Publicar Aviso'),
        backgroundColor: blanco,
        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            paso(
              'Paso 1: Datos del aviso',
              Column(
                children: [
                  Container(
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
                  ),
                  TextField(
                    controller: _tituloController,
                    decoration: const InputDecoration(labelText: 'Título'),
                  ),
                  TextField(
                    controller: _descripcionController,
                    decoration: const InputDecoration(labelText: 'Descripción'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: rojoPastel,
                      foregroundColor: blanco,
                    ),
                    onPressed: () async {
                      final rubros = await TargetService().getRubros();
                      final seleccionado =
                          await showModalBottomSheet<Map<String, String>>(
                            context: context,
                            builder:
                                (context) => ListView(
                                  children:
                                      rubros
                                          .map(
                                            (rubro) => ListTile(
                                              title: Text(rubro.nombre),
                                              onTap:
                                                  () => Navigator.pop(context, {
                                                    'id': rubro.id,
                                                    'nombre': rubro.nombre,
                                                  }),
                                            ),
                                          )
                                          .toList(),
                                ),
                          );
                      if (seleccionado != null) {
                        setState(() {
                          _rubroSeleccionadoId = seleccionado['id'];
                          _rubroSeleccionadoNombre =
                              seleccionado['nombre'] ?? '';
                        });
                      }
                    },
                    child: Text(
                      _rubroSeleccionadoNombre ??
                          'Seleccionar Rubro (obligatorio)',
                    ),
                  ),
                ],
              ),
            ),
            paso(
              'Paso 2: Ubicación',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.map),
                    label: const Text('Seleccionar desde el mapa'),
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
                            content: Text(
                              'No se seleccionó una ubicación válida.',
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: rojoPastel,
                      foregroundColor: blanco,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_latitud != null && _longitud != null)
                    Text(
                      'Ubicación seleccionada: ($_latitud, $_longitud)',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                ],
              ),
            ),
            paso(
              'Paso 3: Archivos (opcional)',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Formatos permitidos para matrículas y certificaciones: PDF, JPG, JPEG, PNG, HEIC',
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 4),
                  ElevatedButton(
                    onPressed: () => _pickFiles(_matriculas, 3),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: rojoPastel,
                      foregroundColor: blanco,
                    ),
                    child: Text(
                      'Seleccionar Matrículas (${_matriculas.length}/3)',
                    ),
                  ),
                  if (_matriculas.isNotEmpty)
                    _listaArchivos(
                      _matriculas,
                      (i) => _removeFile(_matriculas, i),
                    ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _pickFiles(_certificaciones, 3),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: rojoPastel,
                      foregroundColor: blanco,
                    ),
                    child: Text(
                      'Seleccionar Certificaciones (${_certificaciones.length}/3)',
                    ),
                  ),
                  if (_certificaciones.isNotEmpty)
                    _listaArchivos(
                      _certificaciones,
                      (i) => _removeFile(_certificaciones, i),
                    ),
                ],
              ),
            ),
            paso(
              'Paso 4: Fotos de trabajos (máx 6)',
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () => _pickFiles(_fotos, 6),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: rojoPastel,
                      foregroundColor: blanco,
                    ),
                    child: Text('Seleccionar Fotos (${_fotos.length}/6)'),
                  ),
                  if (_fotos.isNotEmpty)
                    _listaArchivos(_fotos, (i) => _removeFile(_fotos, i)),
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
            ElevatedButton.icon(
              icon: const Icon(Icons.publish),
              label: const Text('Publicar Aviso'),
              onPressed: _publicar,
              style: ElevatedButton.styleFrom(
                backgroundColor: rojoPastel,
                foregroundColor: blanco,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
