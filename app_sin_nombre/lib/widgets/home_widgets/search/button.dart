import 'package:flutter/material.dart';

class BotonSearch extends StatefulWidget {
  final String texto;

  const BotonSearch({super.key, required this.texto});

  @override
  State<BotonSearch> createState() => _MibotonState();
}

class _MibotonState extends State<BotonSearch> {
  bool valor = false;

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
      child: Text(
        widget.texto,
        style: TextStyle(
          fontSize: 12, // Más chico
          color: valor ? const Color(0xFF2B2B2B) : const Color(0xFFFF5963),
        ),
      ),
    );
  }
}
