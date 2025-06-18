import 'package:flutter/material.dart';
import 'package:app_sin_nombre/screens/home.dart';
import 'package:app_sin_nombre/screens/favorites.dart';
// import 'package:app_sin_nombre/screens/profile.dart'; // Descomenta y crea tu pantalla de perfil si la tienes

class MainScaffold extends StatefulWidget {
  final int initialIndex;
  const MainScaffold({super.key, this.initialIndex = 1});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return const FavoritesPage();
      case 1:
        return const MyHomePage();
      case 2:
        // return const ProfilePage();
        return Center(child: Text('Perfil (próximamente)'));
      default:
        return const MyHomePage();
    }
  }

  void _onNavTapped(int index) {
    if (index == 3) {
      // Crear aviso
      Navigator.of(context).pushNamed('/crear_aviso');
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
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
    );
  }
}
