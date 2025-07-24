import 'package:app_sin_nombre/services/create_post.dart';
import 'package:app_sin_nombre/services/user_service.dart';
import 'package:app_sin_nombre/models/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MyRegisterPage extends StatefulWidget {
  const MyRegisterPage({super.key});

  @override
  State<MyRegisterPage> createState() => RegisterPage();
}

class RegisterPage extends State<MyRegisterPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController numberCelController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController password2Controller = TextEditingController();

  File? _imageFile;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      // Aquí puedes subir la imagen a S3 y obtener la URL si lo necesitas
    }
  }

  bool _isPasswordSecure(String password) {
    final regex = RegExp(
      r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[!@#\$&*~]).{8,}$',
    );
    return regex.hasMatch(password);
  }

  bool _validateFields() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final numberCel = numberCelController.text.trim();
    final password = passwordController.text.trim();
    final password2 = password2Controller.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        numberCel.isEmpty ||
        password.isEmpty ||
        password2.isEmpty) {
      _showMessage("Por favor, completa todos los campos.");
      return false;
    }
    if (!email.contains('@') || !email.contains('.')) {
      _showMessage("Ingresa un correo electrónico válido.");
      return false;
    }
    if (_imageFile == null) {
      _showMessage("Selecciona una imagen de perfil.");
      return false;
    }
    if (password != password2) {
      _showMessage("Las contraseñas no coinciden.");
      return false;
    }
    if (!_isPasswordSecure(password)) {
      _showMessage(
        "La contraseña debe tener al menos 8 caracteres, una mayúscula, una minúscula, un número y un símbolo.",
      );
      return false;
    }
    return true;
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<bool> registrarUser(
    String nombre,
    String email,
    String numeroCelular,
    String password,
    String urlImg,
  ) async {
    String uid = '';
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      uid = userCredential.user?.uid ?? '';
      print("Usuario registrado con UID: $uid");
    } catch (e) {
      _showMessage("Error al registrar usuario en Firebase Auth: $e");
      return false;
    }
    // Envía el correo de verificación
    await FirebaseAuth.instance.currentUser?.sendEmailVerification();

    final usuario = AppUser(
      uid: uid,
      name: nombre,
      email: email,
      number_cel: numeroCelular,
      url_img: urlImg,
    );
    print("Registrando usuario en la base de datos: $usuario");
    await UserService().createUser(usuario);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registro")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 48,
                backgroundImage:
                    _imageFile != null ? FileImage(_imageFile!) : null,
                child:
                    _imageFile == null
                        ? const Icon(Icons.add_a_photo, size: 40)
                        : null,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Nombre completo",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Correo electrónico",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: numberCelController,
              decoration: InputDecoration(
                labelText: "Número de celular",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: "Contraseña",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: password2Controller,
              decoration: InputDecoration(
                labelText: "Repetir contraseña",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_validateFields()) {
                    final urlImg =
                        (await cargardocumento(_imageFile!)) ??
                        'https://superfix20.s3.us-east-2.amazonaws.com/imagenes+post/usuario+(1).png';
                    bool resultado = await registrarUser(
                      nameController.text.trim(),
                      emailController.text.trim(),
                      numberCelController.text.trim(),
                      passwordController.text.trim(),
                      urlImg,
                    );
                    if (resultado) {
                      _showMessage(
                        "Usuario creado correctamente. Revisa tu correo y verifica la cuenta antes de iniciar sesión.",
                      );
                      Navigator.pushReplacementNamed(context, '/login');
                    } else {
                      _showMessage(
                        "No se pudo crear el usuario. Intenta nuevamente.",
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Registrarse",
                  style: TextStyle(fontSize: 17, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
