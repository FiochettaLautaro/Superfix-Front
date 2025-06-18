import 'package:app_sin_nombre/models/search.dart';
import 'package:app_sin_nombre/models/target_post.dart' as model;
import 'package:app_sin_nombre/models/user.dart';
import 'package:app_sin_nombre/screens/main_scaffold.dart';
import 'package:app_sin_nombre/screens/publicar_aviso_completo.dart';
import 'package:app_sin_nombre/screens/select_rubs.dart';
import 'package:app_sin_nombre/widgets/home_widgets/target/target.dart' as card;
import 'package:flutter/material.dart';
import 'package:app_sin_nombre/widgets/home_widgets/barra_superior.dart';
import 'package:app_sin_nombre/widgets/home_widgets/search/search.dart';
import 'package:app_sin_nombre/services/home_service.dart';
import 'package:app_sin_nombre/globals.dart';
import 'package:app_sin_nombre/screens/favorites.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const MainScaffold(),
      routes: {
        '/crear_aviso': (_) => const PublicarAvisoCompleto(),
        // Agrega más rutas si lo necesitas
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TargetService _targetService = TargetService();
  late Future<List<model.Target_post>> _targetsFuture;
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _targetsFuture = _targetService.searchApp();
  }

  void _actualizarBusqueda(FiltrosBusqueda filtros) {
    setState(() {
      _targetsFuture = _targetService.searchApp(
        text: filtros.text,
        rubros:
            filtros.rubros != null && filtros.rubros!.isNotEmpty
                ? filtros.rubros
                : null,
        matricula: filtros.matriculado,
        latitud: filtros.latitud,
        longitud: filtros.longitud,
      );
    });
  }

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const FavoritesPage()),
      );
    }
  }

  void _onCreatePost() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PublicarAvisoCompleto()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: SuperFixAppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Encuentra Tu Profesional",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              SuperSearch(onFilterChanged: _actualizarBusqueda),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(144, 233, 227, 227),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    ValueListenableBuilder<FiltrosBusqueda>(
                      valueListenable: Globals.filtrosNotifier,
                      builder: (context, filtros, _) {
                        return FutureBuilder<List<model.Target_post>>(
                          future: _targetService.searchApp(
                            text: filtros.text,
                            rubros: filtros.rubros,
                            matricula: filtros.matriculado,
                            latitud: filtros.latitud,
                            longitud: filtros.longitud,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (snapshot.hasError ||
                                !snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const Text(
                                "No se encontraron profesionales.",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            } else {
                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: snapshot.data!.length,
                                separatorBuilder:
                                    (context, index) =>
                                        const SizedBox(height: 4),
                                itemBuilder: (context, index) {
                                  final post = snapshot.data![index];
                                  return card.Target(data: post);
                                },
                              );
                            }
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            if (index == 3) {
              _onCreatePost();
            } else {
              _onNavTapped(index);
            }
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFFFF5963),
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border),
              label: 'Favoritos',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_box_outlined),
              label: 'Crear Aviso',
            ),
          ],
        ),
      ),
    );
  }
}
