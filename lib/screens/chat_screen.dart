import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../models/message_model.dart';
import '../services/chat_service.dart';
import '../services/cloudinary_service.dart';
import '../widgets/chat_bubble.dart';

String getChatId(String uid1, String uid2) {
  return uid1.compareTo(uid2) < 0 ? '$uid1-$uid2' : '$uid2-$uid1';
}

final _chatService = ChatService();

class ChatScreen extends StatefulWidget {
  final String chatId; // ✅ new
  final String chatUserId;
  final String chatUserName;
  final String chatUserImageUrl;
  final String otherUserId;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.chatUserId,
    required this.chatUserName,
    required this.chatUserImageUrl,
    required this.otherUserId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _replyToMessage;
  late final String chatId;
  late final String currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser!.uid;
    chatId = getChatId(currentUserId, widget.otherUserId);
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final newMessage = MessageModel(
      id: '',
      senderId: currentUserId,
      content: text,
      type: 'text',
      timestamp: Timestamp.now(),
      isRead: false,
      replyTo: _replyToMessage,
    );

    _chatService.sendMessage(
      newMessage,
      currentUserId,
      widget.otherUserId,
      FirebaseAuth.instance.currentUser!.displayName ?? 'You',
      widget.chatUserName,
      FirebaseAuth.instance.currentUser!.photoURL ?? '',
      widget.chatUserImageUrl,
    );

    _messageController.clear();
    setState(() => _replyToMessage = null);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickAndUploadMedia() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    final file = File(picked.path);
    final mediaUrl = await CloudinaryService.uploadFile(file);

    if (mediaUrl != null) {
      final newMessage = MessageModel(
        id: '',
        senderId: currentUserId,
        content: mediaUrl,
        type: 'image',
        timestamp: Timestamp.now(),
        isRead: false,
      );
      _chatService.sendMessage(
        newMessage,
        currentUserId,
        widget.otherUserId,
        FirebaseAuth.instance.currentUser!.displayName ?? 'You',
        widget.chatUserName,
        FirebaseAuth.instance.currentUser!.photoURL ?? '',
        widget.chatUserImageUrl,
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent + 80,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _deleteMessage(String messageId) async {
    await _chatService.deleteMessage(chatId, messageId);
  }

  void _setReply(String content) {
    setState(() => _replyToMessage = content);
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = const Color(0xFFF2F2F2);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: const BackButton(color: Colors.black),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.chatUserImageUrl),
              radius: 18,
            ),
            const SizedBox(width: 10),
            Text(
              widget.chatUserName,
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (_replyToMessage != null)
            Container(
              color: Colors.purple.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Replying to: $_replyToMessage',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _replyToMessage = null),
                  ),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _chatService.getMessages(chatId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'No messages yet. Start the conversation!',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final messages = snapshot.data!;

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == currentUserId;
                    final readIcon =
                        isMe
                            ? msg.isRead
                                ? const Icon(
                                  Icons.done_all,
                                  color: Colors.blue,
                                  size: 16,
                                )
                                : const Icon(
                                  Icons.done,
                                  color: Colors.grey,
                                  size: 16,
                                )
                            : null;

                    return Slidable(
                      key: ValueKey(msg.timestamp),
                      endActionPane:
                          isMe
                              ? ActionPane(
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (_) => _deleteMessage(msg.id),
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    icon: Icons.delete,
                                    label: 'Delete',
                                  ),
                                ],
                              )
                              : null,
                      child: GestureDetector(
                        onHorizontalDragEnd: (_) => _setReply(msg.content),
                        onLongPress: () {
                          if (isMe) {
                            showDialog(
                              context: context,
                              builder:
                                  (ctx) => AlertDialog(
                                    title: const Text("Delete Message"),
                                    content: const Text(
                                      "Are you sure you want to delete this message?",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(ctx);
                                          _deleteMessage(msg.id);
                                        },
                                        child: const Text("Delete"),
                                      ),
                                    ],
                                  ),
                            );
                          }
                        },
                        child: ChatBubble(
                          message: msg.content,
                          isMe: isMe,
                          time: DateFormat.Hm().format(msg.timestamp.toDate()),
                          type: msg.type,
                          bubbleColor:
                              isMe
                                  ? const Color.fromARGB(255, 71, 129, 82)
                                  : Colors.white,
                          textColor: isMe ? Colors.white : Colors.black87,
                          replyTo: msg.replyTo,
                          readIcon: readIcon,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.photo, color: Colors.grey),
                    onPressed: _pickAndUploadMedia,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: "Type your message...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: Color.fromARGB(255, 71, 129, 82),
                    ),
                    onPressed: () => _sendMessage(_messageController.text),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
