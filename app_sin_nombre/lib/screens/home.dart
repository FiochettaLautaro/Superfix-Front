import 'package:app_sin_nombre/models/search.dart'; // modelo de filtros de busqueda
import 'package:app_sin_nombre/models/target_post.dart'
    as model; //modelo de las preview posts
import 'package:app_sin_nombre/models/user.dart'; // modelo de User
import 'package:app_sin_nombre/screens/main_scaffold.dart';
import 'package:app_sin_nombre/screens/publicar_aviso_completo.dart';
import 'package:app_sin_nombre/screens/select_rubs.dart';
import 'package:app_sin_nombre/widgets/home_widgets/target/target.dart' as card;
import 'package:flutter/material.dart';
import 'package:app_sin_nombre/widgets/home_widgets/barra_superior.dart';
import 'package:app_sin_nombre/widgets/home_widgets/search/search.dart';
import 'package:app_sin_nombre/services/home_service.dart'; //Importamos services de home service para: darle soporte al Search, y pdarla soporte a otras funcionalidades
import 'package:app_sin_nombre/globals.dart'; // impostamos las variables globales
import 'package:app_sin_nombre/screens/favorites.dart'; // importamos pantalla de favoritos

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
      routes: {'/crear_aviso': (_) => const PublicarAvisoCompleto()},
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
    /// con esto permitimos la navegacion entre las diferentes pantallas de la app dentro de un Scaffold
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
    // esta funcion permite navegar a la pantalla de crear un nuevo aviso
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PublicarAvisoCompleto()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                                  (context, index) => const SizedBox(height: 4),
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
    );
  }
}
