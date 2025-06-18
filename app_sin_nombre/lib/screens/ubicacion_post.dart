import 'package:flutter/material.dart';

class MapsPickerOSM extends StatelessWidget {
  const MapsPickerOSM({super.key});

  @override
  Widget build(BuildContext context) {
    // Simula la selección de una ubicación
    return Scaffold(
      appBar: AppBar(title: const Text('Seleccionar ubicación')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'lat': -34.6037,
              'lng': -58.3816,
              'ciudad': 'Buenos Aires',
              'direccion': 'Calle Falsa 123',
              'localidad': 'CABA',
            });
          },
          child: const Text('Seleccionar esta ubicación'),
        ),
      ),
    );
  }
}
