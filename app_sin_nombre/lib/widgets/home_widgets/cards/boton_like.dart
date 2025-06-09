import 'package:flutter/material.dart';

class FavoriteBoton extends StatefulWidget {
  final bool estado;
  const FavoriteBoton({Key? key, required this.estado}) : super(key: key);

  @override
  State<FavoriteBoton> createState() => _MyFavorite();
}

class _MyFavorite extends State<FavoriteBoton> {
  late bool favorito;

  @override
  void initState() {
    super.initState();
    favorito = widget.estado;
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.favorite,
        color: favorito ? const Color(0xFFFF5963) : Colors.grey,
        size: 26, // Tamaño adecuado, puedes ajustar si quieres
      ),
      onPressed: () {
        setState(() {
          favorito = !favorito;
        });
      },
      splashRadius: 22, // Hace el área de toque cómoda pero no muy grande
      tooltip: 'Favorito',
    );
  }
}
