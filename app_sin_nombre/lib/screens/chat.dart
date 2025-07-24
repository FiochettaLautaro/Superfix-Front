import 'package:app_sin_nombre/globals.dart';
import 'package:app_sin_nombre/models/message.dart';
import 'package:app_sin_nombre/services/chat_socket.dart';
import 'package:app_sin_nombre/services/chats_services.dart';
import 'package:app_sin_nombre/widgets/chats/message_buble.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String chatTitle;
  final String? imagen;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.chatTitle,
    required this.imagen,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  bool _enviando = false; //Indicador de envío
  late ChatsSocketService socketService;
  List<Message> mensajes = [];
  FilePickerResult? _selectedFile;
  bool _filePickerActive = false; //Para evitar doble file picker

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _selectedFile == null) return;

    setState(() {
      _enviando = true;
      // Agrega el mensaje localmente (optimista)
      mensajes.add(
        Message(
          remitente_id: Globals.userId ?? '',
          content: text,
          type: _selectedFile != null ? 'file' : 'text',
          fileName: _selectedFile?.files.first.name,
          id: '',
          chat_id: widget.chatId,
          timestamp: DateTime.now(),
        ),
      );
    });

    final service = ChatsService();
    await service.sendMessage(
      widget.chatId,
      text,
      _selectedFile?.files.first,
      _selectedFile != null ? 'file' : 'text',
    );
    if (!mounted) return;
    setState(() {
      _controller.clear();
      _selectedFile = null;
      _enviando = false;
    });

    await Future.delayed(const Duration(milliseconds: 100));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }

    // Espera un poco y scrollea al final
    await Future.delayed(const Duration(milliseconds: 100));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    socketService.dispose(); // Desconecta y limpia listeners del socket
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    socketService = ChatsSocketService();
    //socketService.connect(Globals.userId ?? '');
    socketService.joinChat(widget.chatId);
    socketService.onNewMessage((data) {
      if (!mounted) return;
      setState(() {
        mensajes.add(Message.fromJson(data['message']));
      });
    });
    cargarMessages();
  }

  Future<void> cargarMessages() async {
    setState(() => isLoading = true);
    try {
      final service = ChatsService();
      final result = await service.getMessages(widget.chatId);
      if (!mounted) return;
      setState(() {
        mensajes = result;
        isLoading = false;
      });
      // Espera un frame y scrollea al final
      await Future.delayed(const Duration(milliseconds: 100));
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(widget.imagen ?? '')),
            const SizedBox(width: 9),
            Text(
              widget.chatTitle,
              style: const TextStyle(
                fontSize: 20, // Cambia este valor al tamaño que quieras
                fontWeight: FontWeight.bold, // Opcional: negrita
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller:
                  _scrollController, // Controla el scroll del ListView (para moverlo programáticamente)
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount:
                  mensajes
                      .length, // Cantidad de mensajes a mostrar que se pasa a al constructor itemBuilder en el index
              itemBuilder: (context, index) {
                final msg = mensajes[index];
                return ChatMessageBubble(
                  Name: widget.chatTitle,
                  imagen:
                      msg.remitente_id == Globals.userId
                          ? (Globals.userImageUrl ??
                              'https://definicion.de/wp-content/uploads/2019/07/perfil-de-usuario.png')
                          : (widget.imagen ??
                              'https://definicion.de/wp-content/uploads/2019/07/perfil-de-usuario.png'),
                  isMe: msg.remitente_id == Globals.userId,
                  type: msg.messageType,
                  content: msg.content,
                  fileName:
                      msg.fileName != null && msg.fileName!.isNotEmpty
                          ? msg.fileName!
                          : msg.content.split('/').last,
                );
              },
            ),
          ),
          const Divider(height: 1),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_selectedFile != null)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 4.0,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedFile!.files.first.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed:
                          _enviando
                              ? null
                              : () {
                                setState(() {
                                  _selectedFile = null;
                                });
                              },
                    ),
                  ],
                ),
              ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed:
                      _enviando
                          ? null
                          : () async {
                            if (_filePickerActive) return;
                            _filePickerActive = true;
                            try {
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles();
                              if (result != null && result.files.isNotEmpty) {
                                setState(() {
                                  _selectedFile = result;
                                });
                                print(
                                  'Archivo seleccionado: ${result.files.first.name}',
                                );
                              }
                            } catch (e) {
                              print('Error al seleccionar archivo: $e');
                            } finally {
                              _filePickerActive = false;
                            }
                          },
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 5,
                    enabled: !_enviando,
                    decoration: const InputDecoration(
                      hintText: 'Mensaje...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                _enviando
                    ? const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                    : IconButton(
                      icon: const Icon(Icons.send, color: Colors.pink),
                      onPressed: _sendMessage,
                    ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
