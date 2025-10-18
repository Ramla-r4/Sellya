import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String time;
  final String type;
  final Color bubbleColor;
  final Color textColor;
  final String? replyTo; // new
  final Widget? readIcon; // new

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.time,
    required this.type,
    required this.bubbleColor,
    required this.textColor,
    this.replyTo,
    this.readIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reply To Message Section
                if (replyTo != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isMe
                              ? Colors.white.withOpacity(0.2)
                              : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      replyTo!,
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                        color: isMe ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ),

                // Main Message
                type == 'image'
                    ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        message,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    )
                    : Text(
                      message,
                      style: TextStyle(color: textColor, fontSize: 15),
                    ),
              ],
            ),
          ),

          // Time + Read Icon
          Padding(
            padding: const EdgeInsets.only(
              bottom: 6,
              left: 6,
              right: 6,
              top: 2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
                if (readIcon != null) ...[const SizedBox(width: 4), readIcon!],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
