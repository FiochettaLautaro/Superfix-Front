import 'package:app_sin_nombre/services/home_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:app_sin_nombre/models/target_post.dart';
import 'package:app_sin_nombre/widgets/home_widgets/cards/boton_like.dart';

class Target extends StatefulWidget {
  final Target_post data;
  const Target({super.key, required this.data});

  @override
  State<Target> createState() => _TargetState();
}

class _TargetState extends State<Target> {
  int _indiceImagen = 0;
  late Timer _timer;
  bool like = false;
  TargetService service = TargetService();
  Map<String, String> nombresRubros = {};

  @override
  void initState() {
    super.initState();
    like = widget.data.like;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _indiceImagen = (_indiceImagen + 1) % widget.data.imagenes.length;
      });
    });
    _cargarNombresRubros();
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

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.5), blurRadius: 5),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen a la izquierda
          Image(
            image: AssetImage(widget.data.imagenes[_indiceImagen]),
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
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
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
                                  final nombre = nombresRubros[rubro] ?? '...';
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
                                        color: Color.fromARGB(255, 255, 99, 99),
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
                          onPressed: () {
                            setState(() {
                              like = !like;
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.message),
                          onPressed: () {},
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
    );
  }
}
