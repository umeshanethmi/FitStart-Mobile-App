import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/models/support_chat.dart';
import 'package:fitstart_mobile_app/services/support_chat_service.dart';

class ExpertChatScreen extends StatefulWidget {
  const ExpertChatScreen({
    super.key,
    required this.chatId,
    required this.peerName,
    required this.peerRole,
    this.isExpertView = false,
  });

  final String chatId;
  final String peerName;
  final String peerRole;
  final bool isExpertView;

  @override
  State<ExpertChatScreen> createState() => _ExpertChatScreenState();
}

class _ExpertChatScreenState extends State<ExpertChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _chatService = SupportChatService();
  late Stream<List<SupportMessage>> _messagesStream;
  bool _isSending = false;
  bool _isMarkingRead = false;
  bool _hasShownReadError = false;

  @override
  void initState() {
    super.initState();
    _messagesStream = _chatService.watchMessages(widget.chatId);
  }

  @override
  void didUpdateWidget(covariant ExpertChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chatId != widget.chatId) {
      _messagesStream = _chatService.watchMessages(widget.chatId);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isSending) return;
    setState(() => _isSending = true);
    try {
      await _chatService.sendMessage(chatId: widget.chatId, text: text);
      if (!mounted) return;
      _messageController.clear();
      _scrollToBottom();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is ArgumentError
                ? error.message
                : 'We could not send your message. Please try again.',
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        if (maxScroll > 0) {
          _scrollController.jumpTo(maxScroll);
        }
      }
    });
  }

  Future<void> _markMessagesRead() async {
    if (_isMarkingRead) return;
    _isMarkingRead = true;
    try {
      await _chatService.markConversationRead(widget.chatId);
    } catch (error) {
      if (mounted && !_hasShownReadError) {
        _hasShownReadError = true;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Messages loaded, but read status could not be updated.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      _isMarkingRead = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FD),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.peerName),
            Text(
              widget.peerRole,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<SupportMessage>>(
              stream: _messagesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2563EB)),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        'We could not load this conversation. Please try again.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFF475569)),
                      ),
                    ),
                  );
                }
                final messages = snapshot.data ?? const <SupportMessage>[];
                if (messages.any(
                  (message) =>
                      message.senderId != currentUserId &&
                      message.readAt == null,
                )) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    unawaited(_markMessagesRead());
                  });
                }
                if (messages.isEmpty) {
                  return const Center(
                    child: Text(
                      'Start the conversation with a quick hello.',
                      style: TextStyle(color: Color(0xFF64748B)),
                    ),
                  );
                }
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _scrollToBottom(),
                );
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMine = message.senderId == currentUserId;
                    final createdAt = message.createdAt;

                    return Align(
                      alignment: isMine
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.72,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isMine
                              ? const Color(0xFF2563EB)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(18).copyWith(
                            bottomLeft: isMine
                                ? const Radius.circular(18)
                                : const Radius.circular(6),
                            bottomRight: isMine
                                ? const Radius.circular(6)
                                : const Radius.circular(18),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.text,
                              style: TextStyle(
                                color: isMine
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              createdAt != null
                                  ? '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}'
                                  : '',
                              style: TextStyle(
                                fontSize: 11,
                                color: isMine
                                    ? Colors.white.withValues(alpha: 0.8)
                                    : const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Write a message...',
                      fillColor: const Color(0xFFF8FAFC),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _isSending ? null : _sendMessage,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    fixedSize: const Size(52, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: _isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
