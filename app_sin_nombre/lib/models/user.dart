import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  final String uid;
  final String? name;
  final String? email;
  final String? url_img;
  final String? number_cel;

  // Constructor correcto
  AppUser({
    required this.uid,
    this.name,
    this.email,
    this.url_img,
    this.number_cel,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] as String,
      url_img: json['url_img'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      number_cel: json['number_cel'] as String?,
    );
  }

  // Factory para convertir desde Firebase User
  factory AppUser.fromFirebase(User firebaseUser) {
    return AppUser(
      uid: firebaseUser.uid,
      name: firebaseUser.displayName,
      email: firebaseUser.email,
      url_img: firebaseUser.photoURL,
      number_cel: firebaseUser.phoneNumber,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'url_img': url_img,
      'number_cel': number_cel,
    };
  }
}
