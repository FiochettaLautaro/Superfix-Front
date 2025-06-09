import 'package:app_sin_nombre/models/target_post.dart' as model;
import 'package:app_sin_nombre/widgets/home_widgets/cards/target.dart' as card;
import 'package:flutter/material.dart';
import 'package:app_sin_nombre/widgets/home_widgets/barra_superior.dart';
import 'package:app_sin_nombre/widgets/home_widgets/search/search.dart';
import 'package:app_sin_nombre/controllers/home_service.dart';

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
              const SuperSearch(),
              FutureBuilder<List<model.Target_post>>(
                future: _targetsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("No se encontraron profesionales.");
                  } else {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.length,
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
      ),
    );
  }
}
