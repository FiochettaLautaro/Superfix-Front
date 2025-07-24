import 'dart:developer';
import 'package:app_sin_nombre/models/comentario.dart';
import 'package:app_sin_nombre/services/comentar_service.dart';
import 'package:app_sin_nombre/widgets/detalle_post/comentariosWidget.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:app_sin_nombre/screens/chat.dart';
import 'package:flutter/material.dart';
import 'package:app_sin_nombre/models/post.dart';
import 'package:app_sin_nombre/services/home_service.dart';
import 'package:app_sin_nombre/services/chats_services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DetallePostScreen extends StatefulWidget {
  final String postId;
  const DetallePostScreen({Key? key, required this.postId}) : super(key: key);

  @override
  State<DetallePostScreen> createState() => _DetallePostScreenState();
}

class _DetallePostScreenState extends State<DetallePostScreen> {
  late Future<Post> _postFuture;
  final serviceChat = ChatsService();
  Map<String, String> _nombresRubros = {};

  final Color rojoPastel = const Color.fromARGB(255, 255, 99, 99);
  final Color rosaPastel = const Color.fromARGB(255, 255, 224, 224);
  final Color blanco = const Color.fromARGB(255, 255, 255, 255);

  @override
  void initState() {
    super.initState();
    _postFuture = TargetService().getPostByIdDetalles(widget.postId);
  }

  Future<void> _cargarNombresRubros(List<String> rubros) async {
    Map<String, String> temp = {};
    for (var rubroId in rubros) {
      try {
        temp[rubroId] = await TargetService().fetchRub(rubroId);
      } catch (_) {
        temp[rubroId] = rubroId;
      }
    }
    setState(() {
      _nombresRubros = temp;
    });
  }

  Widget _buildFotoCarousel(List<String> fotos) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double side = constraints.maxWidth;
        return Center(
          child: SizedBox(
            width: side,
            height: side,
            child: PageView.builder(
              itemCount: fotos.length,
              itemBuilder:
                  (context, i) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.network(
                        fotos[i], // URL de la imagen a mostrar
                        fit:
                            BoxFit
                                .cover, // La imagen se recorta para cubrir todo el espacio disponible
                        width:
                            side, // Ancho igual al máximo disponible (cuadrado)
                        height:
                            side, // Alto igual al máximo disponible (cuadrado)
                        alignment: Alignment.center, // Centra la imagen
                        loadingBuilder: // Función que se llama mientras la imagen se está cargando
                            (context, child, progress) =>
                                progress ==
                                        null // Si la imagen ya se cargó...
                                    ? child // ...muestra la imagen normalmente
                                    : Container(
                                      // Si la imagen está cargando...
                                      color:
                                          rosaPastel, // ...muestra un fondo rosa claro
                                      child: const Center(
                                        child:
                                            CircularProgressIndicator(), // ...y un spinner de carga
                                      ),
                                    ),
                      ),
                    ),
                  ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMiniMapa(Post post) {
    double? lat = double.tryParse(post.ubicacion.latitud);
    double? lon = double.tryParse(post.ubicacion.longitud);
    if (lat == null || lon == null) {
      return const Text('Ubicación no disponible');
    }
    return SizedBox(
      height: 160,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          options: MapOptions(
            center: LatLng(lat, lon),
            zoom: 15,
            interactiveFlags: InteractiveFlag.none,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app_sin_nombre',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  width: 40,
                  height: 40,
                  point: LatLng(lat, lon),
                  child: Icon(Icons.location_on, color: rojoPastel, size: 36),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void mostrarDialogoComentario(
    BuildContext context,
    Function(int, String) onEnviar,
  ) {
    int estrellas = 5;
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Dejar un comentario'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RatingBar.builder(
                  initialRating: 5,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemBuilder:
                      (context, _) =>
                          const Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (rating) {
                    estrellas = rating.toInt();
                  },
                ),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(labelText: 'Comentario'),
                  maxLines: 3,
                ),
              ],
            ),
            actions: [
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: const Text('Enviar'),
                onPressed: () {
                  onEnviar(estrellas, controller.text);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
    );
  }

  Future<void> enviarMensaje() async {
    var result = await serviceChat.crearChat(widget.postId);
    if (result != null) {
      log('Chat creado con ID: ${result['chatId']}');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => ChatScreen(
                chatId: result['chatId'],
                chatTitle: result['chatTitle'],
                imagen: result['imagen'],
              ),
        ),
      );
    } else {
      log('Error al crear el chat');
    }
  }

  Widget _buildBotonHablar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          icon: const Icon(Icons.chat_bubble_outline),
          label: const Text('Hablar con el anunciante'),
          onPressed: () {
            enviarMensaje();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: rojoPastel,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _enviarComentario(int estrellas, String comentario) async {
    try {
      await ComentarService().agregarComentario(
        idPost: widget.postId,
        comentario: comentario,
        puntaje: estrellas,
      );
      setState(() {
        _postFuture = TargetService().getPostByIdDetalles(widget.postId);
      });
    } catch (e) {
      log('Error al enviar el comentario: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: blanco,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: blanco,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Detalle del Aviso',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<Post>(
                future: _postFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData) {
                    return const Center(
                      child: Text('No se encontró el aviso.'),
                    );
                  }
                  final post = snapshot.data!;
                  if (_nombresRubros.isEmpty && post.rubs.isNotEmpty) {
                    _cargarNombresRubros(post.rubs);
                  }
                  return ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              post.title,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          ...post.rubs.map(
                            (id) => Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Chip(
                                label: Text(
                                  _nombresRubros[id] ?? '...',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: rojoPastel,
                                  ),
                                ),
                                backgroundColor: rosaPastel,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      if (post.fotos.isNotEmpty)
                        _buildFotoCarousel(post.fotos), // carrusel de fotos
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: _DescripcionExpandable(text: post.description),
                      ),
                      const SizedBox(height: 18),
                      Card(
                        color: rosaPastel,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.location_on, color: rojoPastel),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Ubicación',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              _buildMiniMapa(post),
                              const SizedBox(height: 10),
                              Text('Ciudad: ${post.ubicacion.ciudad}'),
                              Text('Dirección: ${post.ubicacion.direccion}'),
                              Text('Localidad: ${post.ubicacion.localidad}'),
                              Text(
                                'Lat: ${post.ubicacion.latitud}, Lon: ${post.ubicacion.longitud}',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (post.matricula.url.isNotEmpty)
                        Card(
                          color: blanco,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: ListTile(
                            leading: Icon(
                              Icons.picture_as_pdf,
                              color: rojoPastel,
                            ),
                            title: const Text('Matrícula'),
                            subtitle: Text(post.matricula.url),
                            onTap: () {},
                          ),
                        ),
                      if (post.certificaciones.isNotEmpty) // Certificaciones
                        Card(
                          color: blanco,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.verified, color: rojoPastel),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'Certificaciones',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                ...post.certificaciones.map(
                                  (url) => ListTile(
                                    leading: const Icon(Icons.file_present),
                                    title: Text(url),
                                    onTap: () {},
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ElevatedButton.icon(
                        // comentarios agregar
                        icon: const Icon(
                          Icons.rate_review,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Comentar',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          mostrarDialogoComentario(context, (
                            estrellas,
                            comentario,
                          ) {
                            _enviarComentario(estrellas, comentario);
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: rojoPastel,
                        ),
                      ),
                      if (post.comentarios != null &&
                          post.comentarios!.isNotEmpty) // comentarios mostrar
                        ComentariosWidget(
                          comentarios: post.comentarios!,
                          colorFondo: const Color.fromARGB(223, 255, 255, 255),
                          colorIcono: rojoPastel,
                        ),

                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: rojoPastel,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Publicado: ${post.fechaPost.toLocal().toString().substring(0, 10)}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  );
                },
              ),
            ),
            _buildBotonHablar(),
          ],
        ),
      ),
    );
  }
}

// Widget descripcion
class _DescripcionExpandable extends StatefulWidget {
  final String text;
  const _DescripcionExpandable({required this.text});

  @override
  State<_DescripcionExpandable> createState() => _DescripcionExpandableState();
}

class _DescripcionExpandableState extends State<_DescripcionExpandable> {
  bool expanded = false;
  static const int maxLines = 4;

  @override
  Widget build(BuildContext context) {
    final textWidget = Text(
      widget.text,
      style: TextStyle(fontSize: 16, color: Colors.grey[800]),
      maxLines: expanded ? null : maxLines,
      overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis,
      textAlign: TextAlign.justify,
    );
    final needsExpand =
        widget.text.split(' ').length > 30 || widget.text.length > 120;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descripción',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        textWidget,
        if (needsExpand)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Color.fromARGB(255, 255, 99, 99),
              ),
              onPressed: () => setState(() => expanded = !expanded),
              child: Text(expanded ? 'Ver menos' : 'Ver más'),
            ),
          ),
      ],
    );
  }
}
