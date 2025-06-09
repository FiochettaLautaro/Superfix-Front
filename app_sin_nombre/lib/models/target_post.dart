import 'package:app_sin_nombre/widgets/home_widgets/cards/target.dart';

class Target_post {
  String title;
  double puntaje;
  String id;
  bool like;
  List<String> rubros;
  List<String> imagenes;

  Target_post({
    required this.title,
    required this.id,
    required this.puntaje,
    required this.like,
    required this.rubros,
    required this.imagenes,
  });

  factory Target_post.fromJson(Map<String, dynamic> json) {
    return Target_post(
      title: json['title'] ?? '',
      puntaje: (json['puntaje_promedio'] ?? 0).toDouble(),
      id: json['_id'] ?? '',
      like: false,
      /*json['like'] tenemos  que verificar con la api de favorite en caso de que tenga like es true o en su defecto es false*/
      rubros:
          (json['rubs'] as List?)
              ?.where((e) => e != null)
              .map((e) => e.toString())
              .toList() ??
          [],
      imagenes:
          (json['fotos'] as List?)
              ?.where((e) => e != null)
              .map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
