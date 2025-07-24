import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:app_sin_nombre/globals.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({super.key});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  LatLng? _selectedLocation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar ubicación'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed:
                _selectedLocation == null
                    ? null
                    : () {
                      Navigator.pop(context, _selectedLocation);
                    },
          ),
        ],
      ),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(-32.8908, -68.8272), // Por ejemplo, Mendoza
          zoom: 13.0,
          onTap: (tapPosition, latlng) {
            setState(() {
              _selectedLocation = latlng;
            });
          },
          interactiveFlags:
              InteractiveFlag.all, // Esto habilita todos los gestos
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app_sin_nombre2',
          ),
          if (_selectedLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _selectedLocation!,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 40,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
