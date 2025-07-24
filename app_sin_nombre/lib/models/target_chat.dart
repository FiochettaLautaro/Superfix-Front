class TargetChat {
  final String chat_id;
  final String name;
  final String lastMessage;
  final dynamic lastUpdated;
  final String? imagen;
  bool hasNotification;
  final DateTime? lastUpdatedDateTime; // <-- Campo para ordenación

  TargetChat({
    required this.chat_id,
    required this.name,
    required this.lastMessage,
    required this.lastUpdated,
    this.imagen,
    this.hasNotification = false,
    this.lastUpdatedDateTime,
  });

  factory TargetChat.fromChat(dynamic chat) {
    // Intenta convertir el campo de fecha a DateTime
    DateTime? lastUpdatedDateTime;
    final rawDate =
        chat.lastUpdated ?? chat['lastUpdated'] ?? chat['last_updated'] ?? '';
    if (rawDate is DateTime) {
      lastUpdatedDateTime = rawDate;
    } else if (rawDate is String && rawDate.isNotEmpty) {
      try {
        lastUpdatedDateTime = DateTime.parse(rawDate);
      } catch (_) {
        lastUpdatedDateTime = null;
      }
    }
    

    return TargetChat(
      chat_id: chat.chat_id ?? chat['_id'] ?? '',
      name: chat.name ?? chat['name'] ?? '',
      lastMessage:
          chat.lastMessage ?? chat['lastMessage'] ?? chat['last_message'] ?? '',
      lastUpdated: rawDate,
      imagen: chat.imagen ?? chat['imagen'] ?? '',
      hasNotification: false,
      lastUpdatedDateTime: lastUpdatedDateTime,
    );
  }

 
}
