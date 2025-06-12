import 'package:app_sin_nombre/models/search.dart';
import 'package:app_sin_nombre/models/target_post.dart' as model;
import 'package:app_sin_nombre/models/user.dart';
import 'package:app_sin_nombre/widgets/home_widgets/cards/target.dart' as card;
import 'package:flutter/material.dart';
import 'package:app_sin_nombre/widgets/home_widgets/barra_superior.dart';
import 'package:app_sin_nombre/widgets/home_widgets/search/search.dart';
import 'package:app_sin_nombre/services/home_service.dart';
import 'package:app_sin_nombre/globals.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TargetService _targetService = TargetService();
  late Future<List<model.Target_post>> _targetsFuture;

  @override
  void initState() {
    super.initState();
    // Búsqueda inicial sin filtros
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
                            } else if (snapshot.hasError) {
                              return Text("Error: ${snapshot.error}");
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return const Text(
                                "No se encontraron profesionales.",
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
      ),
    );
  }
}
