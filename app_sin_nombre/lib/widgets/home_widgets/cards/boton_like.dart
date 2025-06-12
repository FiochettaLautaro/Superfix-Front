import 'package:flutter/material.dart';
import 'package:app_sin_nombre/services/home_service.dart';
import 'package:app_sin_nombre/globals.dart';

class FavoriteBoton extends StatefulWidget {
  final bool estado;
  final String post_id;
  const FavoriteBoton({Key? key, required this.estado, required this.post_id})
    : super(key: key);

  @override
  State<FavoriteBoton> createState() => _MyFavorite();
}

class _MyFavorite extends State<FavoriteBoton> {
  late bool favorito;
  TargetService service = TargetService();
  String? user_id = Globals.userId;
  @override
  void initState() {
    super.initState();
    _initFavorito();
  }

  void _initFavorito() async {
    favorito = await service.likeRub(widget.post_id, user_id ?? '');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.favorite,
        color:
            favorito
                ? const Color(0xFFFF5963)
                : const Color.fromARGB(255, 199, 193, 193),
        size: 26, // Tamaño del icono
      ),
      onPressed: () {
        /*setState(() async {
          TargetService service = TargetService();
          favorito = await service.AdlikeRub(widget.post_id);
        });*/
      },
      splashRadius: 22, // Hace el área de toque cómoda pero no muy grande
      tooltip: 'Favorito',
    );
  }
}
