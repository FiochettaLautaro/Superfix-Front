import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:app_sin_nombre/globals.dart';

class ComentarService {
  final String baseUrl = "http://10.0.2.2:5000/api/post";

  Future<bool> agregarComentario({
    required String idPost,
    required String comentario,
    required int puntaje,
  }) async {
    final idUser = Globals.userId ?? '';
    final idToken = Globals.idToken ?? '';
    final url = Uri.parse('$baseUrl/add_opinion/$idPost');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${idToken}',
      },
      body: jsonEncode({
        'uid': idUser,
        'comentario': comentario,
        'puntaje': puntaje,
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print('Error al agregar comentario: ${response.body}');
      return false;
    }
  }
}
