import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatMessageBubble extends StatefulWidget {
  final String Name;
  final String imagen;
  final bool isMe;
  final String type; // 'text', 'image', 'file'
  final String content;
  final String? fileName;

  const ChatMessageBubble({
    super.key,
    required this.Name,
    required this.imagen,
    required this.isMe,
    required this.type,
    required this.content,
    this.fileName,
  });

  @override
  State<ChatMessageBubble> createState() => _ChatMessageBubbleState();
}

class _ChatMessageBubbleState extends State<ChatMessageBubble> {
  Future<void> _openFile() async {
    final url = Uri.encodeFull(widget.fileName ?? '');
    print('Intentando abrir: $url');
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo abrir el archivo: $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bubbleColor =
        widget.isMe ? Color.fromARGB(255, 255, 224, 224) : Colors.white;
    final align =
        widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final borderRadius =
        widget.isMe
            ? const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            )
            : const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            );

    Widget messageContent;
    if (widget.type == 'text') {
      messageContent = Text(
        widget.content,
        style: const TextStyle(fontSize: 16),
      );
    } else if (widget.type == 'image') {
      messageContent = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          widget.content,
          width: 180,
          height: 180,
          fit: BoxFit.cover,
        ),
      );
    } else if (widget.type == 'file') {
      messageContent = InkWell(
        onTap: _openFile,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.picture_as_pdf,
              color: Color.fromARGB(255, 255, 99, 99),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                widget.fileName?.split('/').last ?? 'Archivo PDF',
                softWrap: true,
                maxLines: 3,
                overflow: TextOverflow.visible,
                style: const TextStyle(
                  decoration: TextDecoration.underline,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      messageContent = const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!widget.isMe)
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(
                widget.imagen.isNotEmpty
                    ? widget.imagen
                    : 'https://definicion.de/wp-content/uploads/2019/07/perfil-de-usuario.png',
              ),
            ),
          if (!widget.isMe) const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: align,
              children: [
                if (!widget.isMe)
                  Text(
                    widget.Name,
                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: borderRadius,
                  ),
                  child: messageContent,
                ),
              ],
            ),
          ),
          if (widget.isMe) const SizedBox(width: 8),
          if (widget.isMe)
            CircleAvatar(
              radius: 18,
              backgroundImage: NetworkImage(widget.imagen),
            ),
        ],
      ),
    );
  }
}
