import 'package:app_sin_nombre/models/user.dart';
import 'package:app_sin_nombre/services/chat_socket.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_sin_nombre/services/user_service.dart';
import 'package:app_sin_nombre/globals.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  Future<void> signInWithGoogle() async {
    /*Globals.userName = "Fiochetto Lautaro" ?? '';
    Globals.userEmail = "fiochettalautaro@uch.edu.ar" ?? '';
    Globals.userImageUrl =
        "https://lh3.googleusercontent.com/a/ACg8ocKL2vrqZqIBSdDD7u52k8lcLD3vOp…" ??
        '';
    Globals.userId = "KHvsSoVodIPE5r7WIHrf8b9vrZJ2" ?? '';
    ChatsSocketService().connect(Globals.userId!);
    var userService = UserService();
    var resultado = await userService.getUserById(
      "KHvsSoVodIPE5r7WIHrf8b9vrZJ2" ?? '',
    );
    if (resultado == null) {
      //final newUser = AppUser.fromFirebase(user);
      //await userService.createUser(newUser);
    }*/

    // comentar de acá
    GoogleSignInAccount? googleUser;

    if (kIsWeb) {
      // En web, intenta sesión silenciosa primero
      googleUser = await GoogleSignIn().signInSilently();
      if (googleUser == null) {
        // Si no hay sesión, muestra el botón de Google en tu UI usando renderButton
        print('En web, usa GoogleSignIn().renderButton en tu widget de login.');
        return;
      }
    } else {
      // En mobile, usa el popup normal
      googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return; // El usuario canceló
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await FirebaseAuth.instance
        .signInWithCredential(credential);
    final User? user = userCredential.user;

    if (user != null) {
      Globals.userId = user.uid;
      Globals.userName = user.displayName ?? '';
      Globals.userEmail = user.email ?? '';
      Globals.userImageUrl = user.photoURL ?? '';
      Globals.userPhone = user.phoneNumber ?? '';
      Globals.idToken = (await user.getIdToken()) ?? '';
      print('ID Token: ${Globals.idToken}');
      print('user_id asignado: ${Globals.userId}');
      ChatsSocketService().connect((await user.getIdToken()) ?? '');
      var userService = UserService();
      var resultado = await userService.getUserById(user.uid);
      if (resultado == null) {
        final newUser = AppUser.fromFirebase(user);
        await userService.createUser(newUser);
      }
    }
    // hasta acá PARA  SALTAR LA VALIDACION DE GOOGLE
  }

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final User? user = userCredential.user;
      if (user == null) {
        print('Error: usuario es null tras autenticación.');
        return false;
      }

      await user.reload(); // Actualiza el estado de verificación
      if (!user.emailVerified) {
        print('Correo no verificado.');
        return false;
      }

      print("Usuario autenticado: ${user.uid}, ${user.email}");

      try {
        Globals.idToken = await user.getIdToken();
        print('ID Token: ${Globals.idToken}');
      } catch (e) {
        print('Error al obtener el ID token: $e');
        return false;
      }

      final String uid = userCredential.user?.uid ?? '';
      final usuario = await UserService().getUserById(uid);
      if (usuario == null) {
        print("No se encontró información extra del usuario en base de datos");
        // Si quieres, puedes crear el usuario aquí
        // return false; // Si no quieres crear el usuario, retorna false
      } else {
        Globals.userId = usuario.uid;
        Globals.userName = usuario.name;
        Globals.userEmail = usuario.email;
        Globals.userImageUrl = usuario.url_img;
        Globals.userPhone = usuario.number_cel;
      }

      ChatsSocketService().connect(Globals.userId ?? user.uid);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No existe un usuario con ese email.');
      } else if (e.code == 'wrong-password') {
        print('La contraseña es incorrecta.');
      } else {
        print('Error de autenticación: ${e.message}');
      }
      return false; // <-- Retorna false en caso de error de autenticación
    } catch (e) {
      print('Error inesperado: $e');
      return false; // <-- Retorna false en caso de error inesperado
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }

  User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }
}
