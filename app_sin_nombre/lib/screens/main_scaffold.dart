import 'package:app_sin_nombre/screens/chats.dart';
import 'package:app_sin_nombre/services/chat_socket.dart';
import 'package:flutter/material.dart';
import 'package:app_sin_nombre/screens/home.dart';
import 'package:app_sin_nombre/screens/favorites.dart';
import 'package:app_sin_nombre/screens/perfil_screen.dart';

class MainScaffold extends StatefulWidget {
  final int initialIndex;

  const MainScaffold({super.key, this.initialIndex = 1});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 1;
  int? _tempSelectedIndex;
  bool _hasNewChatNotification = false;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    ChatsSocketService().onNewMessage((data) {
      setState(() {
        _hasNewChatNotification = true;
      });
    });
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return const FavoritesPage();
      case 1:
        return const MyHomePage();
      default:
        return const MyHomePage();
    }
  }

  void _onNavTapped(int index) {
    if (index == 2) {
      // Crear Aviso
      Navigator.of(context).pushNamed('/crear_aviso');
      return;
    }
    if (index == 4) {
      // Perfil
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const PerfilScreen()));
      return;
    }
    if (index == 3) {
      setState(() {
        _hasNewChatNotification = false; // Oculta el punto rojo al abrir chats
      });
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => ChatsPage()));
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //proporciona la estructura visual básica para una pantalla. El widget "Padre" de una pantalla que compone de otros widgets hijos (AppBar,Body,Snackbar, etc.).
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // indice usado en la app
        onTap: _onNavTapped,
        type:
            BottomNavigationBarType
                .fixed, //Hace que todos los ítems se muestren siempre (no se ocultan ni se agrupan, aunque haya más de 3).
        selectedItemColor: const Color(0xFFFF5963),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.favorite_border,
              color: _tempSelectedIndex == 0 ? const Color(0xFFFF5963) : null,
            ),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color:
                  (_tempSelectedIndex == null && _selectedIndex == 1)
                      ? const Color(0xFFFF5963)
                      : null,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            label: 'Crear Aviso',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(
                  Icons.message_outlined,
                  color:
                      _tempSelectedIndex == 5 ? const Color(0xFFFF5963) : null,
                ),
                if (_hasNewChatNotification)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Chats',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person,
              color: _tempSelectedIndex == 2 ? const Color(0xFFFF5963) : null,
            ),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
