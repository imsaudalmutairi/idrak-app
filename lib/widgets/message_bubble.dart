import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/message.dart';
import '../theme.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == Role.user;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) _avatar(),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? userBubble : aiBubble,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                    border: Border.all(color: borderColor, width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.imageBase64 != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            base64Decode(message.imageBase64!),
                            width: 200,
                          ),
                        ),
                      if (message.imageBase64 != null &&
                          message.content.isNotEmpty)
                        const SizedBox(height: 8),
                      if (message.isLoading)
                        _TypingDots()
                      else if (isUser)
                        Text(message.content,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15, height: 1.5))
                      else
                        MarkdownBody(
                          data: message.content,
                          styleSheet: MarkdownStyleSheet(
                            p: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                height: 1.5),
                            code: TextStyle(
                              backgroundColor:
                                  Colors.black.withValues(alpha: 0.4),
                              color: primaryColor,
                              fontFamily: 'monospace',
                              fontSize: 13,
                            ),
                            codeblockDecoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            h1: const TextStyle(
                                color: primaryColor,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                            h2: const TextStyle(
                                color: primaryColor,
                                fontSize: 17,
                                fontWeight: FontWeight.bold),
                            h3: const TextStyle(
                                color: primaryColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w600),
                            strong: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                            blockquote: const TextStyle(
                                color: Color(0xFF80CECA)),
                            listBullet: const TextStyle(color: primaryColor),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (isUser) _userAvatar(),
        ],
      ),
    );
  }

  Widget _avatar() => Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: primaryColor.withValues(alpha: 0.15),
          border: Border.all(color: primaryColor, width: 1),
        ),
        child: Center(
          child: Image.asset('assets/images/logo.png', width: 20, height: 20),
        ),
      );

  Widget _userAvatar() => Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: userBubble,
          border: Border.all(color: primaryDark, width: 1),
        ),
        child: const Icon(Icons.person, color: primaryColor, size: 18),
      );
}

class _TypingDots extends StatefulWidget {
  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final opacity =
                ((_ctrl.value * 3 - i).clamp(0.0, 1.0) * (1 - (_ctrl.value * 3 - i - 1).clamp(0.0, 1.0)));
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Opacity(
                opacity: 0.3 + opacity * 0.7,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
