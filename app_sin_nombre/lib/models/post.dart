import 'package:app_sin_nombre/models/comentario.dart';

class Post {
  final String uid;
  final List<String> rubs;
  final String title;
  final String description;
  final Ubicacion ubicacion;
  final Matricula matricula;
  final List<String> certificaciones; // solo urls
  final List<String> fotos;
  final DateTime fechaPost;
  final List<Comentario>? comentarios;

  Post({
    required this.uid,
    required this.rubs,
    required this.title,
    required this.description,
    required this.ubicacion,
    required this.matricula,
    required this.certificaciones,
    required this.fotos,
    required this.fechaPost,
    this.comentarios,
  });

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'rubs': rubs,
    'title': title,
    'description': description,
    'ubicacion': ubicacion.toJson(),
    'matricula': matricula.toJson(),
    'certificaciones': certificaciones,
    'fotos': fotos,
    'fecha_post': fechaPost.toIso8601String(),
    'comentarios': comentarios?.map((c) => c.toJson()).toList(),
  };

  static Post fromJson(Map<String, dynamic> jsonData) {
    return Post(
      uid: jsonData['uid'] ?? '',
      rubs:
          (jsonData['rubs'] as List?)?.map((e) => e.toString()).toList() ?? [],
      title: jsonData['title'] ?? '',
      description: jsonData['description'] ?? '',
      ubicacion: Ubicacion.fromJson(jsonData['ubicacion'] ?? {}),
      matricula: Matricula.fromJson(jsonData['matricula'] ?? {}),
      certificaciones:
          (jsonData['certificaciones'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      fotos:
          (jsonData['fotos'] as List?)?.map((e) => e.toString()).toList() ?? [],
      fechaPost:
          DateTime.tryParse(jsonData['fecha_post'] ?? '') ?? DateTime.now(),
      comentarios:
          (jsonData['opiniones'] as List?)
              ?.map((e) => Comentario.fromJson(e))
              .toList(),
    );
  }
}

class Ubicacion {
  final String ciudad;
  final String direccion;
  final String localidad;
  final String latitud;
  final String longitud;

  Ubicacion({
    required this.ciudad,
    required this.direccion,
    required this.localidad,
    required this.latitud,
    required this.longitud,
  });

  Map<String, dynamic> toJson() => {
    'ciudad': ciudad,
    'direccion': direccion,
    'localidad': localidad,
    'latitud': latitud,
    'longitud': longitud,
  };

  factory Ubicacion.fromJson(Map<String, dynamic> json) {
    return Ubicacion(
      ciudad: json['ciudad'] ?? '',
      direccion: json['direccion'] ?? '',
      localidad: json['localidad'] ?? '',
      latitud: json['latitud']?.toString() ?? '',
      longitud: json['longitud']?.toString() ?? '',
    );
  }
}

class Matricula {
  final String url;
  Matricula({required this.url});
  Map<String, dynamic> toJson() => {'url': url};

  factory Matricula.fromJson(Map<String, dynamic> json) {
    return Matricula(url: json['url'] ?? '');
  }
}
