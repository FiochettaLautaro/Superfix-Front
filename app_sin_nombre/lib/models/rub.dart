class Rubro {
  final String id;
  final String nombre;
  final String icono;

  Rubro({required this.id, required this.nombre, required this.icono});

  factory Rubro.fromJson(Map<String, dynamic> json) {
    return Rubro(
      id: json['_id'] as String,
      nombre: json['nombre'] as String,
      icono: json['icono'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'nombre': nombre, 'icono': icono};
  }
}
