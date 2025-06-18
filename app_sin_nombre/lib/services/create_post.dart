import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:app_sin_nombre/models/post.dart';

Future<void> enviarPostAlBackend(Post post) async {
  final url = Uri.parse(
    'http://192.168.1.33:5000/api/post/create',
  ); // Ajusta la URL si es necesario
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode(post.toJson()),
  );
  print('POST ${url.toString()}');
  print('Status: ${response.statusCode}');
  print('Body: ${response.body}');
  if (response.statusCode != 201 && response.statusCode != 200) {
    throw Exception('Error al crear el aviso: ${response.body}');
  }
}

Future<String> cargardocumento(File archivo) async {
  String extension = archivo.path.split('.').last.toLowerCase();
  late Uri url;

  if (extension == 'pdf') {
    url = Uri.parse('http://192.168.1.33:5000/api/upload/pdf');
  } else if (['jpg', 'jpeg', 'png', 'heic'].contains(extension)) {
    url = Uri.parse('http://192.168.1.33:5000/api/upload/photo');
  } else {
    throw Exception('Tipo de archivo no soportado');
  }

  var request = http.MultipartRequest('POST', url);
  request.files.add(await http.MultipartFile.fromPath('file', archivo.path));

  var streamedResponse = await request.send();
  var response = await http.Response.fromStream(streamedResponse);

  print('POST ${url.toString()}');
  print('Status: ${response.statusCode}');
  print('Body: ${response.body}');

  if (response.statusCode != 200) {
    throw Exception('Error al cargar el documento: ${response.body}');
  }

  // Extraer la URL del JSON de respuesta
  final urlRespuesta =
      (jsonDecode(response.body) as Map<String, dynamic>)['url'];
  return urlRespuesta;
}
