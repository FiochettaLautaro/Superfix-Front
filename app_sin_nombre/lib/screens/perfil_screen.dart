import 'package:app_sin_nombre/services/auth_service.dart'; // service de auth para cerrar sesión
import 'package:flutter/material.dart'; // importamos material para usar widgets de Flutter
import 'package:app_sin_nombre/globals.dart'; // importammos variables globales

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String? nombre = Globals.userName;
    final String? email = Globals.userEmail;
    final String? imageUrl = Globals.userImageUrl;
    final String? userPhone = Globals.userPhone;

    final Color rojoPastel = const Color.fromARGB(255, 255, 99, 99);
    final Color rosaPastel = const Color.fromARGB(255, 255, 224, 224);
    final Color blanco = const Color.fromARGB(255, 255, 255, 255);

    return Scaffold(
      backgroundColor: blanco,
      appBar: AppBar(
        backgroundColor: blanco,
        elevation: 0,
        title: const Text('Perfil', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 54,
              backgroundColor: rosaPastel,
              backgroundImage:
                  imageUrl != null && imageUrl.isNotEmpty
                      ? NetworkImage(imageUrl)
                      : null,
              child:
                  (imageUrl == null || imageUrl.isEmpty)
                      ? Icon(Icons.person, size: 60, color: rojoPastel)
                      : null,
            ),
            const SizedBox(height: 24),
            Text(
              nombre ?? 'Sin nombre',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(email ?? 'Sin email', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),
            Text(
              userPhone ?? 'Sin teléfono',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              child: ElevatedButton.icon(
                icon: Icon(Icons.logout, color: rojoPastel),
                label: Text(
                  'Cerrar sesión',
                  style: TextStyle(color: rojoPastel),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: rosaPastel,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () async {
                  await AuthService().signOut();
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/login', (route) => false);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
