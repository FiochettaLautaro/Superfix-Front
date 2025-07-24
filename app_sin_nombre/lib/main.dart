import 'package:flutter/material.dart';
import 'package:app_sin_nombre/screens/home.dart';
import 'package:app_sin_nombre/screens/login.dart';
import 'package:app_sin_nombre/screens/main_scaffold.dart';
import 'package:app_sin_nombre/screens/publicar_aviso_completo.dart';
import 'package:app_sin_nombre/screens/register.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('es', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 183, 62, 58),
        ),
      ),
      home: const MyLoginPage(),
      routes: {
        '/home': (context) => const MainScaffold(),
        '/crear_aviso': (context) => const PublicarAvisoCompleto(),
        '/register': (context) => const MyRegisterPage(),
        '/login': (context) => const MyLoginPage(),
        // Puedes agregar otras rutas aquí
      },
      onUnknownRoute:
          (settings) => MaterialPageRoute(
            builder:
                (context) => Scaffold(
                  appBar: AppBar(title: const Text('Ruta no encontrada')),
                  body: const Center(
                    child: Text('La ruta solicitada no existe.'),
                  ),
                ),
          ),
    );
  }
}
/*
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
         
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), 
    );
  }
}
*/