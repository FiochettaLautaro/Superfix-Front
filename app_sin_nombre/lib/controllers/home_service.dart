import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_sin_nombre/models/target_post.dart';

class TargetService {
  final String baseUrl = "http://10.0.2.2:5000/api/post";
  final String baseUrl1 = "http://10.0.2.2:5000/api/rubs/";

  Future<List<Target_post>> fetchTargets() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      //print(jsonList);
      return jsonList.map((json) => Target_post.fromJson(json)).toList();
    } else {
      throw Exception("Error al cargar los datos");
    }
  }

  Future<String> fetchRub(String id_rub) async {
    var url = "$baseUrl1$id_rub";
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['nombre'] ?? '';
    } else {
      throw Exception(
        "Error al obtener el rubro ($id_rub): ${response.statusCode}",
      );
    }
  }
}
