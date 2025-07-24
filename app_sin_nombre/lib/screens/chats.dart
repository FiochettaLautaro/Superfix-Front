import 'package:app_sin_nombre/globals.dart';
import 'package:app_sin_nombre/models/chat.dart';
import 'package:app_sin_nombre/screens/chat.dart';
import 'package:app_sin_nombre/services/chat_socket.dart';
import 'package:flutter/material.dart';
import 'package:app_sin_nombre/models/target_chat.dart';
import 'package:app_sin_nombre/widgets/chats/target.dart';
import 'package:app_sin_nombre/services/chats_services.dart';

class ChatsPage extends StatefulWidget {
  const ChatsPage({super.key});

  @override
  State<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends State<ChatsPage> {
  List<TargetChat> chats = [];
  bool isLoading = true;
  late ChatsSocketService socketService;

  @override
  void initState() {
    super.initState();
    socketService = ChatsSocketService();
    //socketService.connect(Globals.userId ?? '');
    socketService.onReloadChats((data) {
      cargarChats();
    });
    // Escucha mensajes nuevos y marca el chat
    socketService.onNewMessage((data) {
      final chatId = data['chat_id'];
      setState(() {
        for (var chat in chats) {
          if (chat.chat_id == chatId) {
            chat.hasNotification = true;
          }
        }
      });
    });
    cargarChats();
  }

  Future<void> cargarChats() async {
    setState(() => isLoading = true);
    try {
      final service = ChatsService();
      final result = await service.getChats();
      print('Chats recibidos: $result');
      setState(() {
        chats = result;
        isLoading = false;
      });
    } catch (e) {
      print('Error al cargar chats: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : chats.isEmpty
              ? const Center(child: Text('No hay chats'))
              : ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: chats.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  return TargetChatTile(
                    chat: chat,
                    onTap: () async {
                      setState(() {
                        chat.hasNotification = false;
                      });
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ChatScreen(
                                chatId: chat.chat_id,
                                chatTitle: chat.name,
                                imagen: chat.imagen ?? '',
                              ),
                        ),
                      );
                      await cargarChats();
                    },
                  );
                },
              ),
    );
  }
}
