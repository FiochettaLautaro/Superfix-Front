import 'package:flutter/foundation.dart';

class FiltrosBusqueda extends ChangeNotifier {
  static final FiltrosBusqueda _instancia = FiltrosBusqueda._interno();

  FiltrosBusqueda._interno();

  factory FiltrosBusqueda() => _instancia;

  String? _text;
  bool? _matriculado;
  double? _latitud;
  double? _longitud;
  List<String> _rubros = [];

  String? get text => _text;
  bool? get matriculado => _matriculado;
  double? get latitud => _latitud;
  double? get longitud => _longitud;
  List<String> get rubros => _rubros;

  void setText(String nuevoText) {
    _text = nuevoText;
    notifyListeners();
  }

  void setMatriculado(bool valor) {
    _matriculado = valor;
    notifyListeners();
  }

  void setUbicacion(double lat, double lng) {
    _latitud = lat;
    _longitud = lng;
    notifyListeners();
  }

  void setRubros(List<String> nuevosRubros) {
    _rubros = nuevosRubros;
    notifyListeners();
  }

  void limpiar() {
    _text = null;
    _matriculado = null;
    _latitud = null;
    _longitud = null;
    _rubros = [];
    notifyListeners();
  }
}
