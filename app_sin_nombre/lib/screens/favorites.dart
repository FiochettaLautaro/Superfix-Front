import 'package:app_sin_nombre/models/target_post.dart' as model;
import 'package:app_sin_nombre/widgets/home_widgets/target/target.dart' as card;
import 'package:app_sin_nombre/services/home_service.dart'; // Importamos el servicio de home para obtener las publicaciones favoritas
import 'package:flutter/material.dart'; // importamos el paquete de material para usar widgets de flutter
import 'package:app_sin_nombre/widgets/home_widgets/barra_superior.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late Future<List<model.Target_post>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _favoritesFuture = TargetService().getFavorites();
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
                "Tus publicaciones favoritas",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                color: const Color.fromARGB(144, 233, 227, 227),
                borderRadius: BorderRadius.circular(10),
              ),
              child: FutureBuilder<List<model.Target_post>>(
                future: _favoritesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError ||
                      !snapshot.hasData ||
                      snapshot.data!.isEmpty) {
                    return const Text(
                      "No tienes publicaciones favoritas.",
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
