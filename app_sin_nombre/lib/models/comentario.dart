class Comentario {
  final String usuario;
  final String texto;
  final int estrellas;
  final DateTime fecha;

  Comentario({
    required this.usuario,
    required this.texto,
    required this.estrellas,
    required this.fecha,
  });

  factory Comentario.fromJson(Map<String, dynamic> json) {
    return Comentario(
      usuario: json['uid'] ?? '',
      texto: json['comentario'] ?? '',
      estrellas: json['estrellas'] ?? 0,
      fecha: DateTime.tryParse(json['fecha'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': usuario,
    'comentario': texto,
    'estrellas': estrellas,
    'fecha': fecha.toIso8601String(),
  };
}
