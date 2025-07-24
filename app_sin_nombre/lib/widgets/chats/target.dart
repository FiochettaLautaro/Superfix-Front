import 'package:flutter/material.dart';
import 'package:app_sin_nombre/models/target_chat.dart';

class TargetChatTile extends StatelessWidget {
  final TargetChat chat;
  final VoidCallback onTap;

  const TargetChatTile({super.key, required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading:
          (chat.imagen != null && chat.imagen!.isNotEmpty)
              ? CircleAvatar(backgroundImage: NetworkImage(chat.imagen!))
              : CircleAvatar(
                child: Text(
                  chat.name.isNotEmpty ? chat.name[0] : '?',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              chat.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            chat.lastUpdated,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
      subtitle: Text(
        chat.lastMessage.isNotEmpty ? chat.lastMessage : 'Sin mensajes',
      ),
      onTap: onTap,
    );
  }
}
