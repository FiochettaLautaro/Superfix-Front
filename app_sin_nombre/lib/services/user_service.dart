import 'dart:convert';
import 'package:app_sin_nombre/globals.dart';
import 'package:http/http.dart' as http;
import 'package:app_sin_nombre/models/user.dart';

class UserService {
  final String baseUrl = "http://10.0.2.2:5000/api/users/";

  Future<List<AppUser>> getUsers() async {
    try {
      await Globals.refreshIdToken();
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer ${Globals.idToken}',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((user) => AppUser.fromJson(user)).toList();
      } else {
        throw Exception("Failed to load users");
      }
    } catch (e) {
      throw Exception("Failed to load users: $e");
    }
  }

  Future<AppUser?> getUserById(String id) async {
    try {
      /*await Globals.refreshIdToken();*/
      final response = await http.get(
        Uri.parse("$baseUrl$id"),
        headers: {
          'Authorization': 'Bearer ${Globals.idToken}',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        return AppUser.fromJson(json.decode(response.body));
      } else if (response.statusCode == 404) {
        // Usuario no encontrado, retorna null
        return null;
      } else {
        throw Exception("Failed to load user: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to load user: $e");
    }
  }

  Future<void> createUser(AppUser user) async {
    try {
      /*await Globals.refreshIdToken();*/
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer ${Globals.idToken}',
          'Content-Type': 'application/json',
        },
        body: json.encode(user.toJson()),
      );
      print('POST $baseUrl');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      if (response.statusCode == 400) {
        final body = json.decode(response.body);
        if (body["Error"] == "El correo ya existe") {
          // No lanzar excepción, solo continuar
          print('El correo ya existe, se continúa el flujo.');
          return;
        }
      }
      if (response.statusCode != 201) {
        throw Exception("Failed to create user");
      }
    } catch (e) {
      throw Exception("Failed to create user: $e");
    }
  }

  Future<void> updateUser(AppUser user) async {
    try {
      await Globals.refreshIdToken();
      final response = await http.put(
        Uri.parse("$baseUrl/${user.uid}"),
        headers: {
          'Authorization': 'Bearer ${Globals.idToken}',
          'Content-Type': 'application/json',
        },
        body: json.encode(user.toJson()),
      );
      if (response.statusCode != 200) {
        throw Exception("Failed to update user");
      }
    } catch (e) {
      throw Exception("Failed to update user: $e");
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await Globals.refreshIdToken();
      final response = await http.delete(
        Uri.parse("$baseUrl$id"),
        headers: {
          'Authorization': 'Bearer ${Globals.idToken}',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode != 204) {
        throw Exception("Failed to delete user");
      }
    } catch (e) {
      throw Exception("Failed to delete user: $e");
    }
  }
}
