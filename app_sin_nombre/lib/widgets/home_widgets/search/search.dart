import 'package:app_sin_nombre/models/search.dart';
import 'package:app_sin_nombre/widgets/home_widgets/search/buton_icon.dart';
import 'package:flutter/material.dart';
import 'button.dart';

class SuperSearch extends StatefulWidget {
  const SuperSearch({super.key});

  @override
  State<SuperSearch> createState() => _MisearchState();
}

class _MisearchState extends State<SuperSearch> {
  final TextEditingController _controller = TextEditingController();
  final filtros = FiltrosBusqueda();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
                  width: 12,
                  height: 12,
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
                    onPressed: () {},
                    splashRadius: 16,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              children: const [
                BotonIcon(texto: 'Ubicación'),
                SizedBox(width: 6),
                BotonSearch(texto: 'Rubro'),
                SizedBox(width: 6),
                BotonSearch(texto: 'Matriculado'),
                SizedBox(width: 6),
                BotonSearch(texto: 'Recomendado por App'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
