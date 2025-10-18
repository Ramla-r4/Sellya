import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../screens/chat_screen.dart';
import '../services/chat_service.dart';

class ChatListScreen extends StatefulWidget {
  final String currentUserId;

  const ChatListScreen({super.key, required this.currentUserId});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatService _chatService = ChatService();
  List<Map<String, dynamic>> _chats = [];
  bool _loading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _listenToChats();
  }

  void _listenToChats() {
    _chatService.getUserChats(widget.currentUserId).listen((data) {
      setState(() {
        _chats = data;
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: const Color(0xFFF2F2F2),
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child:
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _chats.isEmpty
                    ? const Center(child: Text("No chats found."))
                    : ListView.separated(
                      padding: const EdgeInsets.only(top: 8),
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemCount: _chats.length,
                      itemBuilder: (context, index) {
                        final chat = _chats[index];
                        final isUser1 = chat['user1Id'] == widget.currentUserId;
                        final otherUserId =
                            isUser1 ? chat['user2Id'] : chat['user1Id'];
                        final name =
                            isUser1
                                ? chat['user2Name'] ?? "Unknown"
                                : chat['user1Name'] ?? "Unknown";
                        final imageUrl =
                            isUser1
                                ? chat['user2ImageUrl'] ?? ''
                                : chat['user1ImageUrl'] ?? '';
                        final lastMessage = chat['lastMessage'] ?? '';
                        final lastTime =
                            chat['lastMessageTime'] != null
                                ? DateFormat.Hm().format(
                                  chat['lastMessageTime'].toDate(),
                                )
                                : '';

                        if (searchQuery.isNotEmpty &&
                            !name.toLowerCase().contains(searchQuery)) {
                          return const SizedBox.shrink();
                        }

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          leading: CircleAvatar(
                            radius: 26,
                            backgroundImage:
                                imageUrl.isNotEmpty
                                    ? NetworkImage(imageUrl)
                                    : const AssetImage(
                                          "assets/images/default_profile.png",
                                        )
                                        as ImageProvider,
                          ),
                          title: Text(
                            name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            lastMessage,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: Text(
                            lastTime,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => ChatScreen(
                                      chatId: _chatService.getChatId(
                                        widget.currentUserId,
                                        otherUserId,
                                      ),
                                      chatUserId: otherUserId,
                                      chatUserName: name,
                                      chatUserImageUrl: imageUrl,
                                      otherUserId: otherUserId,
                                    ),
                              ),
                            );
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: const Color(0xFFF2F2F2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: (val) => setState(() => searchQuery = val.toLowerCase()),
        decoration: InputDecoration(
          hintText: 'Search chats...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
