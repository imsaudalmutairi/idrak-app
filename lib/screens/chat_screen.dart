import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../widgets/message_bubble.dart';
import '../theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _picker = ImagePicker();
  final List<Message> _messages = [];
  bool _busy = false;
  String? _pendingImageBase64;

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80, maxWidth: 1280);
    if (file == null) return;
    final bytes = await File(file.path).readAsBytes();
    setState(() => _pendingImageBase64 = base64Encode(bytes));
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if ((text.isEmpty && _pendingImageBase64 == null) || _busy) return;

    final userMsg = Message(
      role: Role.user,
      content: text,
      imageBase64: _pendingImageBase64,
    );
    final loadingMsg = Message(
        role: Role.assistant, content: '', isLoading: true);

    setState(() {
      _messages.add(userMsg);
      _messages.add(loadingMsg);
      _pendingImageBase64 = null;
      _busy = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final reply = await ApiService.chat(_messages);
      setState(() {
        _messages.removeLast();
        _messages.add(Message(role: Role.assistant, content: reply));
        _busy = false;
      });
    } catch (e) {
      setState(() {
        _messages.removeLast();
        _messages.add(Message(
            role: Role.assistant,
            content: '⚠️ Error: ${e.toString()}'));
        _busy = false;
      });
    }
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _pendingImageBase64 = null;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: surfaceColor,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo.png', width: 28, height: 28),
            const SizedBox(width: 10),
            const Text('idrak',
                style: TextStyle(
                    color: primaryColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF4DB8B5)),
            tooltip: 'New chat',
            onPressed: _clearChat,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: borderColor),
        ),
      ),
      drawer: _buildDrawer(),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty ? _buildWelcome() : _buildMessages(),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildWelcome() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/images/logo.png', width: 80, height: 80),
          const SizedBox(height: 20),
          const Text('idrak',
              style: TextStyle(
                  color: primaryColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1)),
          const SizedBox(height: 8),
          const Text('by SJM Labs',
              style: TextStyle(color: Color(0xFF4DB8B5), fontSize: 14)),
          const SizedBox(height: 40),
          _suggestionChip('ما هو الذكاء الاصطناعي؟'),
          const SizedBox(height: 10),
          _suggestionChip('Write a Python hello world'),
          const SizedBox(height: 10),
          _suggestionChip('Explain quantum computing simply'),
        ],
      ),
    );
  }

  Widget _suggestionChip(String text) {
    return GestureDetector(
      onTap: () {
        _controller.text = text;
        _send();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Text(text,
            style: const TextStyle(color: Color(0xFF80CECA), fontSize: 14)),
      ),
    );
  }

  Widget _buildMessages() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 12, bottom: 8),
      itemCount: _messages.length,
      itemBuilder: (_, i) => MessageBubble(message: _messages[i]),
    );
  }

  Widget _buildInput() {
    return Container(
      color: surfaceColor,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_pendingImageBase64 != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      base64Decode(_pendingImageBase64!),
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 2,
                    right: 2,
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _pendingImageBase64 = null),
                      child: Container(
                        decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file_rounded,
                    color: Color(0xFF4DB8B5)),
                onPressed: _pickImage,
                tooltip: 'Attach image',
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  maxLines: 5,
                  minLines: 1,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: const InputDecoration(
                    hintText: 'Message idrak...',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _send,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _busy ? cardColor : primaryColor,
                  ),
                  child: Icon(
                    _busy ? Icons.hourglass_empty_rounded : Icons.arrow_upward_rounded,
                    color: _busy ? primaryDark : Colors.black,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text('idrak can make mistakes. Verify important information.',
              style: TextStyle(color: Color(0xFF2A6060), fontSize: 11)),
        ],
      ),
    );
  }

  Drawer _buildDrawer() {
    return Drawer(
      backgroundColor: surfaceColor,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Image.asset('assets/images/logo.png', width: 60, height: 60),
                  const SizedBox(height: 12),
                  const Text('idrak',
                      style: TextStyle(
                          color: primaryColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('by SJM Labs',
                      style:
                          TextStyle(color: Color(0xFF4DB8B5), fontSize: 13)),
                ],
              ),
            ),
            const Divider(color: borderColor),
            ListTile(
              leading:
                  const Icon(Icons.add_comment_rounded, color: primaryColor),
              title: const Text('New Chat',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                _clearChat();
                Navigator.pop(context);
              },
            ),
            const Spacer(),
            const Divider(color: borderColor),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text('SJM Labs',
                      style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                  SizedBox(height: 4),
                  Text('idrak v1.0',
                      style: TextStyle(
                          color: Color(0xFF2A6060), fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
