class Message {
  final String _id;
  final String chat_id;
  final String remitente_id;
  final String type;
  final String content;
  final DateTime timestamp;
  final String? name;
  final String? image;
  final String? fileName;

  Message({
    required String id,
    required String chat_id,
    required String remitente_id,
    required String type,
    required String content,
    required DateTime timestamp,
    this.name,
    this.image,
    this.fileName,
  }) : _id = id,
       chat_id = chat_id,
       remitente_id = remitente_id,
       type = type,
       content = content,
       timestamp = timestamp;

  String get id => _id;
  String get chatId => chat_id;
  String get remitenteId => remitente_id;
  String get messageType => type;
  String get messageContent => content;
  DateTime get messageTimestamp => timestamp;

  Map<String, dynamic> toJson() {
    return {
      '_id': _id,
      'chat_id': chat_id,
      'remitente_id': remitente_id,
      'type': type,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'name': name,
      'image': image,
      'file_name': fileName,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'],
      chat_id: json['chat_id'],
      remitente_id: json['remitente_id'],
      type: json['type'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      name: json['name'],
      image: json['image'],
      fileName: json['file_name'],
    );
  }
}
