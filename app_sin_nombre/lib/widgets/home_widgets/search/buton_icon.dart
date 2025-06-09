import 'package:app_sin_nombre/models/search.dart';
import 'package:flutter/material.dart';

class BotonIcon extends StatefulWidget {
  final String texto;

  const BotonIcon({super.key, required this.texto});

  @override
  State<BotonIcon> createState() => _MibotonState();
}

class _MibotonState extends State<BotonIcon> {
  bool valor = false;
  final filtros = FiltrosBusqueda();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          valor = !valor;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            valor ? const Color(0xFFFF5963) : const Color(0xFFFFFFFF),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 1,
        ), // Más chico
        minimumSize: Size(0, 32), // Altura mínima pequeña
        tapTargetSize:
            MaterialTapTargetSize.shrinkWrap, // Reduce el área de toque
        elevation: 0, // Sin sombra
        shape: StadiumBorder(), // Bordes redondeados tipo "píldora"
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_pin,
            color: valor ? const Color(0xFF2B2B2B) : const Color(0xFFFF5963),
            size: 14, // Más chico
          ),
          const SizedBox(width: 4),
          Text(
            widget.texto,
            style: TextStyle(
              fontSize: 11, // Más chico
              color: valor ? const Color(0xFF2B2B2B) : const Color(0xFFFF5963),
            ),
          ),
        ],
      ),
    );
  }
}
