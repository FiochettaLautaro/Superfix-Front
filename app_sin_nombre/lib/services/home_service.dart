import 'dart:convert';
import 'package:app_sin_nombre/globals.dart';
import 'package:app_sin_nombre/models/post.dart';
import 'package:app_sin_nombre/models/rub.dart';
import 'package:http/http.dart' as http;
import 'package:app_sin_nombre/models/target_post.dart';

class TargetService {
  final String baseUrl = "http://10.0.2.2:5000/api/post";
  final String baseUrl1 = "http://10.0.2.2:5000/api/rubs/";
  final String baseUrl2 = "http://10.0.2.2:5000/api/favorites/one";
  final String baseUrl3 = "http://10.0.2.2:5000/api/favorites";

  Future<List<Target_post>> fetchTargets() async {
    await Globals.refreshIdToken();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer ${Globals.idToken}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      //print(jsonList);
      return jsonList.map((json) => Target_post.fromJson(json)).toList();
    } else {
      throw Exception("Error al cargar los datos");
    }
  }

  /// Obtiene el nombre de un rubro a partir de su ID.
  Future<String> fetchRub(String id_rub) async {
    await Globals.refreshIdToken();
    var url = "$baseUrl1$id_rub";
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${Globals.idToken}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['nombre'] ?? '';
    } else {
      throw Exception(
        "Error al obtener el rubro ($id_rub): ${response.statusCode}",
      );
    }
  }

  Future<List<Rubro>> getRubros() async {
    await Globals.refreshIdToken();
    final response = await http.get(
      Uri.parse(baseUrl1),
      headers: {
        'Authorization': 'Bearer ${Globals.idToken}',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Rubro.fromJson(json)).toList();
    } else {
      throw Exception("Error al cargar los rubros");
    }
  }

  Future<Target_post> getPostById(String id) async {
    await Globals.refreshIdToken();
    final response = await http.get(
      Uri.parse('http://10.0.2.2:5000/api/post/searchById/$id'),
      headers: {
        'Authorization': 'Bearer ${Globals.idToken}',
        'Content-Type': 'application/json',
      },
    );
    print("[getPostById] Post ID: $id");
    print("[getPostById] Response: ${response.body}");
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return Target_post.fromJson(jsonData);
    } else {
      throw Exception("Error al cargar el post con ID: $id");
    }
  }

  Future<Post> getPostByIdDetalles(String id) async {
    await Globals.refreshIdToken();
    final response = await http.get(
      Uri.parse('http://10.0.2.2:5000/api/post/searchById/$id'),
      headers: {
        'Authorization': 'Bearer ${Globals.idToken}',
        'Content-Type': 'application/json',
      },
    );
    print("[getPostById] Post ID: $id");
    print("[getPostById] Response: ${response.body}");
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return Post.fromJson(jsonData);
    } else {
      throw Exception("Error al cargar el post con ID: $id");
    }
  }

  Future<List<Target_post>> getFavorites() async {
    await Globals.refreshIdToken();
    String? user_id = Globals.userId;
    var url = "http://10.0.2.2:5000/api/favorites/all/$user_id";
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${Globals.idToken}',
        'Content-Type': 'application/json',
      },
    );
    print("[getFavorites] Response: ${response.body}");
    if (response.statusCode == 200) {
      final dynamic decoded = json.decode(response.body);
      final List<Target_post> posts = [];
      if (decoded is List) {
        // Puede ser lista de strings o lista de objetos
        for (var item in decoded) {
          String? postId;
          if (item is String) {
            postId = item;
          } else if (item is Map && item.containsKey('post_id')) {
            var postIdField = item['post_id'];
            if (postIdField is List && postIdField.isNotEmpty) {
              postId = postIdField[0];
            } else if (postIdField is String) {
              postId = postIdField;
            }
          }
          if (postId != null) {
            print("[getFavorites] Post ID extraído: $postId");
            try {
              Target_post post = await getPostById(postId);
              post.like = true;
              posts.add(post);
            } catch (e) {
              print("[getFavorites] Error al obtener post $postId: $e");
            }
          } else {
            print("[getFavorites] No se pudo extraer post_id de: $item");
          }
        }
      } else {
        print("[getFavorites] Respuesta inesperada: ${response.body}");
      }
      return posts;
    } else {
      throw Exception("Error al cargar los favoritos");
    }
  }

  /// Busca posts según los parámetros proporcionados
  Future<List<Target_post>> searchApp({
    String? text,
    List<String>? rubros,
    bool? matricula,
    double? longitud,
    double? latitud,
  }) async {
    final queryParameters = <String, dynamic>{};

    if (text != null && text.isNotEmpty) queryParameters['text'] = text;
    if (rubros != null && rubros.isNotEmpty) {
      for (var rub in rubros) {
        queryParameters.putIfAbsent('rubs', () => []).add(rub);
      }
    }
    if (matricula != null && matricula) queryParameters['matricula'] = 'true';
    if (longitud != null) queryParameters['longitud'] = longitud.toString();
    if (latitud != null) queryParameters['latitud'] = latitud.toString();

    final uri = Uri.http('10.0.2.2:5000', '/api/post', queryParameters);

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer ${Globals.idToken}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Target_post.fromJson(json)).toList();
    } else {
      throw Exception("Error al buscar posts: ${response.statusCode}");
    }
  }

  Future<bool> likeRub(String post_id, String user_id) async {
    await Globals.refreshIdToken();
    var url = "$baseUrl2/$user_id/$post_id";
    print('URL GET: $url');
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${Globals.idToken}',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return true;
    } else {
      return false;
    }
  }

  /// Crea o elimina un favorito
  Future<bool> AdlikeRub(String post_id) async {
    //await Globals.refreshIdToken();
    String? user_id = Globals.userId;

    if (user_id == null) {
      print("Error: user_id es null");
      return false;
    }

    var url = "$baseUrl2/$user_id/$post_id";
    Map<String, dynamic> persona = {"user_uid": user_id, "post_id": post_id};
    print('URL GET: $url');
    print('user_uid: $user_id, post_id: $post_id');

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer ${Globals.idToken}',
        'Content-Type': 'application/json',
      },
    );

    final data = json.decode(response.body);
    print(data['Mensaje']);

    if (data['Mensaje'] == "Favorite no encontrado" ||
        data['Mensaje'] == "Favorite encontrado") {
      var url20 = "$baseUrl3/CreaDelete";
      final response20 = await http.post(
        Uri.parse(url20),
        headers: {
          'Authorization': 'Bearer ${Globals.idToken}',
          'Content-Type': 'application/json',
        },
        body: json.encode(persona),
      );
      print(response20);
      if (response20.statusCode == 201) {
        return true;
      } else if (response20.statusCode == 200) {
        return false;
      } else {
        print("Error en response20: ${response20.statusCode}");
        return false;
      }
    } else {
      print("Error en response: ${response.statusCode}");
      return false;
    }
  }
}
