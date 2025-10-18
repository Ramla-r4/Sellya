import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String content;
  final String type;
  final Timestamp timestamp;
  final bool isRead;
  final String? replyTo;

  MessageModel({
    required this.id, // <-- Update this
    required this.senderId,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.replyTo,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'content': content,
      'type': type,
      'timestamp': timestamp,
      'isRead': isRead,
      'replyTo': replyTo,
    };
  }

  factory MessageModel.fromMap(Map<String, dynamic> map, String id) {
    return MessageModel(
      id: id,
      senderId: map['senderId'],
      content: map['content'],
      type: map['type'],
      timestamp: map['timestamp'],
      isRead: map['isRead'] ?? false,
      replyTo: map['replyTo'],
    );
  }
}
