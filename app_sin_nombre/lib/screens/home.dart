import 'package:app_sin_nombre/models/target_post.dart' as model;
import 'package:app_sin_nombre/widgets/home_widgets/cards/target.dart' as card;
import 'package:flutter/material.dart';
import 'package:app_sin_nombre/widgets/home_widgets/barra_superior.dart';
import 'package:app_sin_nombre/widgets/home_widgets/search/search.dart';
import 'package:app_sin_nombre/services/home_service.dart';

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
    _targetsFuture = _targetService.fetchTargets();
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
              const SizedBox(height: 10),
              // Container mejorado para UI amigable
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SuperSearch(),
                    const SizedBox(height: 16),
                    FutureBuilder<List<model.Target_post>>(
                      future: _targetsFuture,
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
                          return const Text("No se encontraron profesionales.");
                        } else {
                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: snapshot.data!.length,
                            separatorBuilder:
                                (context, index) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final post = snapshot.data![index];
                              return card.Target(data: post);
                            },
                          );
                        }
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
// este es un comentario