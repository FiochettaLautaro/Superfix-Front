import 'package:app_sin_nombre/models/user.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:app_sin_nombre/services/user_service.dart';

class AuthService {
  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return; // El usuario canceló

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
      var userService = UserService();
      var resultado = await userService.getUserById(user.uid);
      if (resultado == null) {
        print('Usuario no encontrado, creando nuevo usuario...');
        print('UID: ${user.uid}');
        print('Nombre: ${user.displayName}');
        print('Email: ${user.email}');
        print('URL Imagen: ${user.photoURL}');
        print('Número de Celular: ${user.phoneNumber}');
        final newUser = AppUser.fromFirebase(user);
        await userService.createUser(newUser);
      }
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No existe un usuario con ese email.');
      } else if (e.code == 'wrong-password') {
        print('La contraseña es incorrecta.');
      } else {
        print('Error de autenticación: ${e.message}');
      }
    } catch (e) {
      print('Error inesperado: $e');
    }

    return null;
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseAuth.instance.signOut();
  }

  User? getCurrentUser() {
    return FirebaseAuth.instance.currentUser;
  }
}
