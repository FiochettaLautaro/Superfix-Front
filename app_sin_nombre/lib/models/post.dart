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
  };
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
}

class Matricula {
  final String url;
  Matricula({required this.url});
  Map<String, dynamic> toJson() => {'url': url};
}
