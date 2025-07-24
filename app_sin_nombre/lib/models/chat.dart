import 'package:app_sin_nombre/services/chats_services.dart';

class Chat {
  final String _id;
  final List<String> participants;
  final String last_message;
  final DateTime? last_updated;
  final DateTime? created_at;

  Chat({
    required String id,
    required List<String> participants,
    required String last_message,
    required DateTime? last_updated,
    required DateTime? created_at,
  }) : _id = id,
       participants = participants,
       last_message = last_message,
       last_updated = last_updated,
       created_at = created_at;

  String get id => _id;
  String get lastMessage => last_message;
  DateTime? get lastUpdated => last_updated;
  DateTime? get createdAt => created_at;
  Map<String, dynamic> toJson() {
    return {
      '_id': _id,
      'participants': participants,
      'last_message': last_message,
      'last_updated': last_updated?.toIso8601String(),
      'created_at':
          created_at?.toIso8601String(), //objeto DateTime de Dart a un string
    };
  }

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['_id'],
      participants: List<String>.from(json['participants']),
      last_message: json['last_message'],
      last_updated: parseRFC1123(json['last_updated']), // convertimos a DateTime desde un string con formato RFC 1123
      created_at: parseRFC1123(json['created_at']),
    );
  }
}
