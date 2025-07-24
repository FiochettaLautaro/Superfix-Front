import 'package:app_sin_nombre/models/target_chat.dart';
import 'package:app_sin_nombre/models/message.dart';
import 'package:app_sin_nombre/models/chat.dart';
import 'package:app_sin_nombre/globals.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

// Función para parsear RFC 1123
DateTime? parseRFC1123(String dateStr) {
  try {
    return DateFormat(
      'EEE, dd MMM yyyy HH:mm:ss',
      'en_US',
    ).parseUtc(dateStr.replaceAll(' GMT', ''));
  } catch (e) {
    return null;
  }
}

class ChatsService {
  final String baseUrl = "http://10.0.2.2:5000/api/chats";
  final String baseUrlMessages = "http://10.0.2.2:5000/api";

  Future<List<TargetChat>> getChats() async {
    try {
      String uid = Globals.userId ?? '';
      final response = await http.get(
        Uri.parse("$baseUrl/$uid"),
        headers: {
          'Authorization': 'Bearer ${Globals.idToken}',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<TargetChat> targetChats = [];
        for (var chat in data) {
          final chatObj = Chat.fromJson(chat);

          if (chatObj.participants.isEmpty) continue;

          String targetUserId;
          if (chatObj.participants.length == 1) {
            targetUserId = chatObj.participants[0];
          } else {
            targetUserId =
                chatObj.participants[0] == Globals.userId
                    ? chatObj.participants[1]
                    : chatObj.participants[0];
          }

          final userResponse = await http.get(
            Uri.parse("http://10.0.2.2:5000/api/users/$targetUserId"),
            headers: {
              'Authorization': 'Bearer ${Globals.idToken}',
              'Content-Type': 'application/json',
            },
          );

          // Parseo seguro de fecha RFC 1123
          DateTime? lastUpdatedDT;
          if (chatObj.last_updated is DateTime) {
            lastUpdatedDT = chatObj.last_updated;
          } else if (chatObj.last_updated is String &&
              chatObj.last_updated != null &&
              (chatObj.last_updated as String).isNotEmpty) {
            lastUpdatedDT = parseRFC1123(chatObj.last_updated as String);
          }

          if (userResponse.statusCode == 200) {
            final userData = json.decode(userResponse.body);
            final name = userData['name'] ?? '-';
            final targetChat = TargetChat(
              chat_id: chatObj.id,
              name: name,
              imagen: userData['url_img'] ?? null,
              lastMessage: chatObj.last_message,
              lastUpdated: formatLastUpdated(lastUpdatedDT),
              lastUpdatedDateTime: lastUpdatedDT,
            );
            targetChats.add(targetChat);
          } else if (userResponse.statusCode == 404) {
            final targetChat = TargetChat.fromChat(chatObj);
            targetChats.add(targetChat);
          }
        }

        // Ordenar por última actualización (más reciente primero)
        targetChats.sort((a, b) {
          final aDate = a.lastUpdatedDateTime ?? DateTime(2000);
          final bDate = b.lastUpdatedDateTime ?? DateTime(2000);
          return bDate.compareTo(aDate);
        });

        print("Chats obtenidos: ${targetChats.length}");
        return targetChats;
      } else {
        throw Exception("Sin conexión con el servidor");
      }
    } catch (e) {
      throw Exception("Sin conexión con el servidor: $e");
    }
  }

  String formatLastUpdated(DateTime? lastUpdated) {
    if (lastUpdated == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDay = DateTime(
      lastUpdated.year,
      lastUpdated.month,
      lastUpdated.day,
    );

    if (messageDay == today) {
      return DateFormat('HH:mm').format(lastUpdated);
    } else if (now.difference(messageDay).inDays < 7) {
      return DateFormat('EEEE', 'es').format(lastUpdated);
    } else {
      return DateFormat('dd/MM/yyyy').format(lastUpdated);
    }
  }

  Future<dynamic> crearChat(String targetId) async {
    try {
      print(targetId);
      final respUser = await http.get(
        Uri.parse("http://10.0.2.2:5000/api/post/searchById/${targetId}"),
        headers: {
          'Authorization': 'Bearer ${Globals.idToken}',
          'Content-Type': 'application/json',
        },
      );
      String? nombre;
      String? imagen;
      String userId = '';
      if (respUser.statusCode == 200) {
        final data = json.decode(respUser.body);
        userId = data['uid'] ?? '';
        final responseUser = await http.get(
          Uri.parse("http://10.0.2.2:5000/api/users/${userId}"),
          headers: {
            'Authorization': 'Bearer ${Globals.idToken}',
            'Content-Type': 'application/json',
          },
        );
        final dataUser = json.decode(responseUser.body);
        nombre = dataUser['name'] ?? '';
        imagen = dataUser['url_img'] ?? null;

        if (responseUser.statusCode != 200) {
          throw Exception("Failed to get user data");
        }
      }
      final response = await http.post(
        Uri.parse("$baseUrl/${Globals.userId}/${userId}"),
        headers: {
          'Authorization': 'Bearer ${Globals.idToken}',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final chatData = json.decode(response.body);
        print("datos del chat: ${chatData}, ${nombre}, ${imagen}");
        return {
          'chatId': chatData['chat_id'],
          'chatTitle': nombre ?? '',
          'imagen': imagen,
        };
      } else {
        print("Error al crear el chat: ${response.body}");
        throw Exception("Failed to create chat");
      }
    } catch (e) {
      print("Error al crear el chat: $e");
      throw Exception("Failed to create chat: $e");
    }
  }

  Future<List<Message>> getMessages(String chatId) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrlMessages/chats/$chatId/${Globals.userId}"),
        headers: {
          'Authorization': 'Bearer ${Globals.idToken}',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic> data =
            decoded is List ? decoded : decoded['messages'] ?? [];
        //print("Mensajes obtenidos: ${data}");
        final mensajes =
            data.map((message) => Message.fromJson(message)).toList();
        print(mensajes);
        return mensajes;
      } else {
        throw Exception("Failed to load messages");
      }
    } catch (e) {
      throw Exception("Failed to load messages: $e");
    }
  }

  Future<void> sendMessage(
    String chatId,
    String content,
    PlatformFile? file,
    String type,
  ) async {
    try {
      var uri = Uri.parse("$baseUrlMessages/chats/$chatId/messages");
      var request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer ${Globals.idToken}';

      request.fields['remitente_id'] = Globals.userId ?? '';
      request.fields['type'] = type;
      request.fields['content'] = content;

      if (file != null) {
        if (file.bytes != null) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'file_name',
              file.bytes!,
              filename: file.name,
            ),
          );
        } else if (file.path != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'file_name',
              file.path!,
              filename: file.name,
            ),
          );
        } else {
          throw Exception("No se pudo obtener el archivo seleccionado.");
        }
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Mensaje enviado");
      } else {
        throw Exception("Failed to send message: ${response.body}");
      }
    } catch (e) {
      throw Exception("Failed to send message: $e");
    }
  }
}
