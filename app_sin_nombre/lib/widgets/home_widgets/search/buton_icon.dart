import 'package:flutter/material.dart';

class FiltrosBusqueda {
  String texto = '';
  String? rubro;
  bool favoritos = false;
  bool recomendado = false;
  String? ubicacion;

  @override
  String toString() {
    return 'Texto: $texto, Rubro: $rubro, Ubicación: $ubicacion, Favoritos: $favoritos, Recomendado: $recomendado';
  }
}

class SuperSearch extends StatefulWidget {
  const SuperSearch({super.key});

  @override
  State<SuperSearch> createState() => _SuperSearchState();
}

class _SuperSearchState extends State<SuperSearch> {
  final TextEditingController _controller = TextEditingController();
  final filtros = FiltrosBusqueda();

  void actualizarBusqueda() {
    filtros.texto = _controller.text;
    print('BÚSQUEDA ACTUALIZADA: ${filtros.toString()}');
    // Acá iría la lógica real de búsqueda con estos filtros
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(actualizarBusqueda); // Se actualiza al tipear
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleFavoritos() {
    setState(() {
      filtros.favoritos = !filtros.favoritos;
      actualizarBusqueda();
    });
  }

  void toggleRecomendado() {
    setState(() {
      filtros.recomendado = !filtros.recomendado;
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
                      color: Colors.black,
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
                  onPressed: () {
                    // TODO: lógica ubicación
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
                  texto: 'Favoritos',
                  estadoInicial: filtros.favoritos,
                  onToggle: toggleFavoritos,
                ),
                const SizedBox(width: 6),
                CustomToggleButton(
                  texto: 'Recomendado por App',
                  estadoInicial: filtros.recomendado,
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
