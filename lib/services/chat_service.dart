import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ownsell/models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String getChatId(String uid1, String uid2) {
    return uid1.compareTo(uid2) < 0 ? '$uid1-$uid2' : '$uid2-$uid1';
  }

  Future<void> sendMessage(
    MessageModel message,
    String currentUserId,
    String otherUserId,
    String currentUserName,
    String otherUserName,
    String currentUserImageUrl,
    String otherUserImageUrl,
  ) async {
    final chatId = getChatId(currentUserId, otherUserId);
    final chatDocRef = _firestore.collection('chats').doc(chatId);

    final chatExists = (await chatDocRef.get()).exists;

    if (!chatExists) {
      await chatDocRef.set({
        'participants': [currentUserId, otherUserId],
        'user1Id': currentUserId,
        'user2Id': otherUserId,
        'user1Name': currentUserName,
        'user2Name': otherUserName,
        'user1ImageUrl': currentUserImageUrl,
        'user2ImageUrl': otherUserImageUrl,
        'lastMessage': message.content,
        'lastMessageTime': message.timestamp,
      });
    } else {
      await chatDocRef.update({
        'lastMessage': message.content,
        'lastMessageTime': message.timestamp,
      });
    }

    await chatDocRef.collection('messages').add(message.toMap());
  }

  /// ✅ Takes `chatId` directly (no need for receiverId)
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return MessageModel(
              id: doc.id,
              senderId: data['senderId'],
              content: data['content'],
              type: data['type'],
              timestamp: data['timestamp'],
              isRead: data['isRead'] ?? false,
              replyTo: data['replyTo'],
            );
          }).toList();
        });
  }

  Stream<List<Map<String, dynamic>>> getUserChats(String currentUserId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .snapshots()
        .map((snapshot) {
          final chatList =
              snapshot.docs
                  .map((doc) => {'id': doc.id, ...doc.data()})
                  .toList();

          // Sort by lastMessageTime descending locally
          chatList.sort((a, b) {
            final tsA = a['lastMessageTime'];
            final tsB = b['lastMessageTime'];
            if (tsA == null || tsB == null) return 0;
            return (tsB as Timestamp).compareTo(tsA as Timestamp);
          });

          return chatList;
        });
  }

  /// ✅ Takes `chatId` directly (instead of recomputing)
  Future<void> deleteMessage(String chatId, String messageId) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }
}

Future<int> getUnreadCount(String chatId, String currentUserId) async {
  final snapshot =
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('isRead', isEqualTo: false)
          .where('senderId', isNotEqualTo: currentUserId)
          .get();

  return snapshot.docs.length;
}
