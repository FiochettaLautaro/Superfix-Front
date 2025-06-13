import 'package:app_sin_nombre/globals.dart';
import 'package:app_sin_nombre/models/search.dart';
import 'package:app_sin_nombre/screens/mapa.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class SuperSearch extends StatefulWidget {
  final Function(FiltrosBusqueda) onFilterChanged;

  const SuperSearch({super.key, required this.onFilterChanged});

  @override
  State<SuperSearch> createState() => _SuperSearchState();
}

class _SuperSearchState extends State<SuperSearch> {
  final TextEditingController _controller = TextEditingController();
  final filtros = FiltrosBusqueda();

  void actualizarBusqueda() {
    filtros.setText(_controller.text);
    widget.onFilterChanged(filtros); // 🔥 Notifica al padre
    print('BÚSQUEDA ACTUALIZADA: ${filtros.toString()}');
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(actualizarBusqueda);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleFavoritos() {
    setState(() {
      filtros.setMatriculado(!(filtros.matriculado ?? false));

      actualizarBusqueda();
    });
  }

  void toggleRecomendado() {
    setState(() {
      actualizarBusqueda();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE0E0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: TextField(
              controller: _controller,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Ingresa lo que buscas',
                hintStyle: const TextStyle(fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: Container(
                  margin: const EdgeInsets.only(right: 4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF5963),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.search,
                      color: Color.fromARGB(255, 255, 255, 255),
                      size: 20,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: () => actualizarBusqueda(),
                    splashRadius: 16,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                BotonIcon(
                  texto: 'Ubicación',
                  onPressed: () async {
                    final LatLng? location = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MapaScreen(),
                      ),
                    );

                    if (location != null) {
                      setState(() {
                        filtros.setUbicacion(
                          location.latitude,
                          location.longitude,
                        );
                        Globals.filtro?.setUbicacion(
                          location.latitude,
                          location.longitude,
                        );
                        actualizarBusqueda();
                      });
                    }
                  },
                ),
                const SizedBox(width: 6),
                BotonSearch(
                  texto: 'Rubro',
                  onPressed: () {
                    // TODO: lógica rubro
                  },
                ),
                const SizedBox(width: 6),
                CustomToggleButton(
                  texto: 'Matriculado',
                  estadoInicial: filtros.matriculado ?? false,
                  onToggle: () {
                    setState(() {
                      final nuevoValor = !(filtros.matriculado ?? false);
                      filtros.setMatriculado(nuevoValor);
                      Globals.filtro?.setMatriculado(nuevoValor);
                      actualizarBusqueda();
                    });
                  },
                ),

                const SizedBox(width: 6),
                CustomToggleButton(
                  texto: 'Recomendado por App',
                  estadoInicial: false,
                  onToggle: toggleRecomendado,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Toggle reutilizable
class CustomToggleButton extends StatefulWidget {
  final String texto;
  final bool estadoInicial;
  final VoidCallback onToggle;

  const CustomToggleButton({
    Key? key,
    required this.texto,
    required this.estadoInicial,
    required this.onToggle,
  }) : super(key: key);

  @override
  State<CustomToggleButton> createState() => _CustomToggleButtonState();
}

class _CustomToggleButtonState extends State<CustomToggleButton> {
  late bool valor;

  @override
  void initState() {
    super.initState();
    valor = widget.estadoInicial;
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          valor = !valor;
        });
        widget.onToggle();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
            valor ? const Color(0xFFFF5963) : const Color(0xFFFFFFFF),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
        minimumSize: const Size(0, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        elevation: 0,
        shape: const StadiumBorder(),
      ),
      child: Text(
        widget.texto,
        style: TextStyle(
          fontSize: 12,
          color: valor ? Colors.white : const Color(0xFFFF5963),
        ),
      ),
    );
  }
}

// Botón de filtro simple
class BotonSearch extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;

  const BotonSearch({super.key, required this.texto, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFFFFF),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
        minimumSize: const Size(0, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        elevation: 0,
        shape: const StadiumBorder(),
      ),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 12, color: Color(0xFFFF5963)),
      ),
    );
  }
}

// Botón con ícono (Ubicación)
class BotonIcon extends StatelessWidget {
  final String texto;
  final VoidCallback onPressed;

  const BotonIcon({super.key, required this.texto, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFFFFF),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
        minimumSize: const Size(0, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        elevation: 0,
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_pin, color: Color(0xFFFF5963), size: 14),
          const SizedBox(width: 4),
          Text(
            texto,
            style: const TextStyle(fontSize: 12, color: Color(0xFFFF5963)),
          ),
        ],
      ),
    );
  }
}
