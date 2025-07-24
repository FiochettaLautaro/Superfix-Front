import 'dart:developer';

import 'package:app_sin_nombre/models/user.dart';
import 'package:app_sin_nombre/services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app_sin_nombre/models/comentario.dart';

class ComentariosWidget extends StatefulWidget {
  final List<Comentario> comentarios;
  final Color colorFondo;
  final Color colorIcono;

  const ComentariosWidget({
    super.key,
    required this.comentarios,
    required this.colorFondo,
    required this.colorIcono,
  });

  @override
  State<ComentariosWidget> createState() => _ComentariosWidgetState();
}

class _ComentariosWidgetState extends State<ComentariosWidget> {
  final serviceUser = UserService();

  @override
  Widget build(BuildContext context) {
    if (widget.comentarios.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      color: widget.colorFondo,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.comment, color: widget.colorIcono),
                const SizedBox(width: 6),
                const Text(
                  'Comentarios',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 180, // Puedes ajustar la altura según tu diseño
              child: ListView.builder(
                itemCount: widget.comentarios.length,
                itemBuilder: (context, index) {
                  final comentario = widget.comentarios[index];
                  return FutureBuilder<AppUser?>(
                    future: serviceUser.getUserById(comentario.usuario),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const ListTile(
                          leading: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          title: Text(
                            'Cargando...',
                            style: TextStyle(fontSize: 13),
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return const ListTile(
                          leading: Icon(
                            Icons.error,
                            color: Colors.red,
                            size: 20,
                          ),
                          title: Text(
                            'Error al cargar usuario',
                            style: TextStyle(fontSize: 13),
                          ),
                        );
                      }
                      final user = snapshot.data;
                      return ListTile(
                        dense: true,
                        leading:
                            user != null && user.url_img != null
                                ? CircleAvatar(
                                  backgroundImage: NetworkImage(user.url_img!),
                                  radius: 16,
                                )
                                : const Icon(
                                  Icons.person,
                                  color: Colors.grey,
                                  size: 32,
                                ),
                        title: Text(
                          comentario.texto,
                          style: const TextStyle(fontSize: 13),
                        ),
                        subtitle: Row(
                          children: [
                            ...List.generate(
                              comentario.estrellas,
                              (i) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 15,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              user != null
                                  ? (user.name ?? 'Usuario desconocido')
                                  : 'Usuario desconocido',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              comentario.fecha.toLocal().toString().substring(
                                0,
                                10,
                              ),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black38,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
