import 'package:app_sin_nombre/models/search.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class Globals {
  static String? userId;
  static String? userName;
  static String? userEmail;
  static String? userImageUrl;
  static String? userPhone;
  static String? idToken;
  static FiltrosBusqueda? filtro;
  static final filtrosNotifier = ValueNotifier<FiltrosBusqueda>(
    FiltrosBusqueda(),
  );

  static Future<void> refreshIdToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      idToken = (await user.getIdToken(true)) ?? '';
    }
  }
}
/**Globals.userName =  ;
  Globals.userEmail = "fiochettalautaro@uch.edu.ar" ;
  Globals.userImageUrl = "https://lh3.googleusercontent.com/a/ACg8ocKL2vrqZqIBSdDD7u52k8lcLD3vOp…" ;
  Globals.userId = "KHvsSoVodIPE5r7WIHrf8b9vrZJ2" ;
 */