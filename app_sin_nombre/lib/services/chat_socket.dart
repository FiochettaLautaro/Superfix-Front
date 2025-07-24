import 'package:app_sin_nombre/globals.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatsSocketService {
  static final ChatsSocketService _instance = ChatsSocketService._internal();
  IO.Socket? socket; // Cambia a nullable

  factory ChatsSocketService() {
    return _instance;
  }

  ChatsSocketService._internal();

  void connect(String userId) {
    // Si ya existe un socket, desconéctalo antes de crear uno nuevo
    if (socket != null) {
      socket!.disconnect();
      socket = null;
    }
    socket = IO.io('http://10.0.2.2:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket!.connect();
    socket!.onConnect((_) {
      print('Socket conectado');
      socket!.emit('join_user', {'user_id': Globals.userId});
    });
  }

  void joinChat(String chatId) {
    if (socket != null) {
      socket!.emit('join_chat', {'chat_id': chatId});
    }
  }

  void onReloadChats(Function(dynamic) callback) {
    if (socket != null) {
      socket!.on('reload_chats', (data) {
        print('Evento reload_chats recibido en el frontend: $data');
        callback(data);
      });
    }
  }

  void onNewMessage(Function(dynamic) callback) {
    if (socket != null) {
      socket!.on('new_message', (data) {
        print('Evento new_message recibido en el frontend: $data');
        callback(data);
      });
    }
  }

  void onLeaveChat(Function(dynamic) callback) {
    if (socket != null) {
      socket!.on('leave_chat', (data) {
        print('Evento leave_chat recibido en el frontend: $data');
        callback(data);
      });
    }
  }

  void dispose() {
    if (socket != null) {
      socket!.clearListeners();
      socket!.disconnect();
      socket = null;
    }
  }
}
