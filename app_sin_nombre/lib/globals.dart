import 'package:app_sin_nombre/models/search.dart';
import 'package:flutter/foundation.dart';

class Globals {
  static String? userId;
  static String? userName;
  static String? userEmail;
  static String? userImageUrl;
  static FiltrosBusqueda? filtro;
  static final filtrosNotifier = ValueNotifier<FiltrosBusqueda>(
    FiltrosBusqueda(),
  );
}
