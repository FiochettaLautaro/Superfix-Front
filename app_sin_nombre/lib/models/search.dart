class FiltrosBusqueda {
  static final FiltrosBusqueda _instancia = FiltrosBusqueda._interno();

  FiltrosBusqueda._interno(); //constructor

  factory FiltrosBusqueda() => _instancia;

  bool? _matriculado;
  double? _latitud;
  double? _longitud;
  String? _rubro;

  bool? get matriculado => _matriculado;
  double? get latitud => _latitud;
  double? get longitud => _longitud;
  String? get rubro => _rubro;

  void setMatriculado(bool valor) {
    _matriculado = valor;
  }

  void setUbicacion(double lat, double lng) {
    _latitud = lat;
    _longitud = lng;
  }

  void setRubro(String nuevoRubro) {
    _rubro = nuevoRubro;
  }

  void limpiar() {
    _matriculado = null;
    _latitud = null;
    _longitud = null;
    _rubro = null;
  }
}
