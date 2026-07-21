// lib/screens/category_tabs/chat_tab.dart
import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../models/chat_message.dart';
import '../../services/chat_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/id_gen.dart';
import '../../widgets/chat_bubble.dart';

class ChatTab extends StatefulWidget {
  final Category category;
  const ChatTab({super.key, required this.category});

  @override
  State<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  final ChatService _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  late String _sessionId;
  bool _isSending = false;
  bool _isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
    _sessionId = generateSessionId();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoadingHistory = true);
    try {
      final history = await _chatService.fetchHistory(
        categoryId: widget.category.id,
        sessionId: _sessionId,
      );
      if (mounted && history.isNotEmpty) {
        setState(() {
          _messages.clear();
          for (final item in history) {
            _messages.add(ChatMessage(
              text: item['message'] as String? ?? item['text'] as String? ?? '',
              isUser: item['is_user'] as bool? ?? (item['role'] == 'user'),
            ));
          }
        });
      } else if (mounted && _messages.isEmpty) {
        _addInitialGreeting();
      }
    } catch (_) {
      if (mounted && _messages.isEmpty) {
        _addInitialGreeting();
      }
    } finally {
      if (mounted) setState(() => _isLoadingHistory = false);
      _scrollToBottom();
    }
  }

  void _addInitialGreeting() {
    _messages.add(ChatMessage(
      text: "Hi! I'm your ${widget.category.title.toLowerCase()} stylist. Ask me anything about colors, budget picks, what suits an occasion, or whatever you need!",
      isUser: false,
    ));
  }

  Future<void> _clearChat() async {
    try {
      await _chatService.clearHistory(
        categoryId: widget.category.id,
        sessionId: _sessionId,
      );
    } catch (_) {}

    if (mounted) {
      setState(() {
        _messages.clear();
        _sessionId = generateSessionId();
        _addInitialGreeting();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chat history cleared')),
      );
    }
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _controller.clear();
      _isSending = true;
    });
    _scrollToBottom();

    try {
      final reply = await _chatService.sendMessage(
        categoryId: widget.category.id,
        sessionId: _sessionId,
        message: text,
      );
      if (mounted) {
        setState(() => _messages.add(ChatMessage(text: reply, isUser: false)));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _messages.add(ChatMessage(text: "Sorry, something went wrong: $e", isUser: false)));
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: _clearChat,
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: const Text('Clear Chat', style: TextStyle(fontSize: 12)),
                style: TextButton.styleFrom(foregroundColor: AppColors.textMuted),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isLoadingHistory
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: _messages.length + (_isSending ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length) {
                      return const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 6),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gradientEnd),
                          ),
                        ),
                      );
                    }
                    return ChatBubble(message: _messages[index]);
                  },
                ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: 'Ask your stylist...',
                      filled: true,
                      fillColor: AppColors.chipUnselected,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
                  child: IconButton(
                    onPressed: _isSending ? null : _send,
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}