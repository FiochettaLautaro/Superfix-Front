import 'dart:developer';

import 'package:app_sin_nombre/globals.dart';
import 'package:app_sin_nombre/screens/chat.dart';
import 'package:app_sin_nombre/services/chats_services.dart';
import 'package:app_sin_nombre/services/home_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:app_sin_nombre/screens/detalle_post_screen.dart';
import 'package:app_sin_nombre/models/target_post.dart';
import 'package:app_sin_nombre/widgets/home_widgets/target/boton_like.dart';
import 'package:google_fonts/google_fonts.dart';

class Target extends StatefulWidget {
  final Target_post data;
  const Target({super.key, required this.data});

  @override
  State<Target> createState() => _TargetState();
}

class _TargetState extends State<Target> {
  int _indiceImagen = 0;
  late Timer _timer;

  String? post_id = '';
  TargetService service = TargetService();
  ChatsService serviceChat = ChatsService();
  Map<String, String> nombresRubros = {};
  String? user_id = Globals.userId;

  bool like = false;

  @override
  void initState() {
    super.initState();
    like = widget.data.like;
    _timer = Timer.periodic(const Duration(seconds: 7), (timer) {
      setState(() {
        _indiceImagen = (_indiceImagen + 1) % widget.data.imagenes.length;
      });
    });
    _cargarNombresRubros();
    _initLike();
  }

  Future<void> _initLike() async {
    bool result = await service.likeRub(widget.data.id, user_id ?? '');
    setState(() {
      like = result;
    });
  }

  Future<void> _cargarNombresRubros() async {
    Map<String, String> temp = {};
    for (var rubroId in widget.data.rubros) {
      try {
        temp[rubroId] = await service.fetchRub(rubroId);
      } catch (_) {
        temp[rubroId] = rubroId; // fallback al id si falla
      }
    }
    setState(() {
      nombresRubros = temp;
    });
  }

  Future<void> enviarMensaje() async {
    var result = await serviceChat.crearChat(widget.data.id);
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

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetallePostScreen(postId: widget.data.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen a la izquierda
            Image.network(
              widget.data.imagenes[_indiceImagen],
              width: 100,
              height: 100,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 10),

            // Info y botones
            Expanded(
              child: SizedBox(
                height: 100,
                child: Row(
                  children: [
                    // Columna principal (Textos)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Título
                          Container(
                            constraints: const BoxConstraints(maxWidth: 140),
                            child: Text(
                              widget.data.title,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Rubros
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children:
                                  widget.data.rubros.map((rubro) {
                                    final nombre =
                                        nombresRubros[rubro] ?? '...';
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: Chip(
                                        label: Text(
                                          nombre,
                                          style: const TextStyle(fontSize: 11),
                                        ),
                                        backgroundColor: const Color.fromARGB(
                                          255,
                                          255,
                                          224,
                                          224,
                                        ),
                                        labelStyle: const TextStyle(
                                          color: Color.fromARGB(
                                            255,
                                            255,
                                            99,
                                            99,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: -2,
                                        ),
                                        shape: const StadiumBorder(),
                                        visualDensity: const VisualDensity(
                                          horizontal: -4,
                                          vertical: -4,
                                        ),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                          const Spacer(),

                          // Puntaje
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text('${widget.data.puntaje}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Columna de botones
                    SizedBox(
                      width: 40,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.favorite,
                              color: like ? Colors.red : Colors.grey,
                            ),
                            onPressed: () async {
                              TargetService service = TargetService();
                              bool result = await service.AdlikeRub(
                                widget.data.id,
                              );
                              setState(() {
                                like = result;
                              });
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.message),
                            onPressed: () async {
                              await enviarMensaje();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
