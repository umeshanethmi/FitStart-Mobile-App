import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/models/support_request.dart';
import 'package:fitstart_mobile_app/services/support_request_service.dart';

class SupportRequestThreadScreen extends StatefulWidget {
  const SupportRequestThreadScreen({
    super.key,
    required this.request,
    required this.isExpertView,
  });

  final SupportRequest request;
  final bool isExpertView;

  @override
  State<SupportRequestThreadScreen> createState() =>
      _SupportRequestThreadScreenState();
}

class _SupportRequestThreadScreenState
    extends State<SupportRequestThreadScreen> {
  final _service = SupportRequestService();
  final _replyController = TextEditingController();
  late Stream<List<SupportRequestReply>> _repliesStream;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _repliesStream = _service.watchReplies(widget.request);
  }

  @override
  void didUpdateWidget(covariant SupportRequestThreadScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.request.id != widget.request.id ||
        oldWidget.request.userId != widget.request.userId) {
      _repliesStream = _service.watchReplies(widget.request);
    }
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _sendReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    try {
      await _service.replyToRequest(request: widget.request, text: text);
      if (!mounted) return;
      _replyController.clear();
    } catch (error) {
      if (!mounted) return;
      final message = error is ArgumentError || error is StateError
          ? error.toString().replaceFirst('Bad state: ', '')
          : 'Could not send the reply. Check the connection and try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFFB42318),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F6),
      appBar: AppBar(
        title: Text(widget.isExpertView ? 'Support request' : 'Expert reply'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF15372C),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<SupportRequestReply>>(
              stream: _repliesStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return _StateMessage(
                    icon: Icons.cloud_off_outlined,
                    title: 'Replies unavailable',
                    message: 'We could not load this conversation. Check your access and connection, then retry.',
                    onRetry: () => setState(
                      () => _repliesStream = _service.watchReplies(
                        widget.request,
                      ),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF15765A)),
                  );
                }

                final replies = snapshot.data ?? const <SupportRequestReply>[];
                return ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE3EBE6)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.isExpertView
                                      ? widget.request.userName
                                      : widget.request.expertName,
                                  style: const TextStyle(
                                    color: Color(0xFF15372C),
                                    fontWeight: FontWeight.w800,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                              _StatusChip(status: widget.request.status),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.request.specialization,
                            style: const TextStyle(
                              color: Color(0xFF15765A),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            widget.request.message,
                            style: const TextStyle(
                              color: Color(0xFF33443B),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'Conversation',
                      style: TextStyle(
                        color: Color(0xFF15372C),
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (replies.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'No replies yet. Replies will appear here in real time.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Color(0xFF66766D)),
                        ),
                      )
                    else
                      ...replies.map(
                        (reply) => _ReplyBubble(
                          reply: reply,
                          isExpertView: widget.isExpertView,
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
          if (widget.isExpertView)
            SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE3EBE6))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _replyController,
                        minLines: 1,
                        maxLines: 4,
                        maxLength: 2000,
                        decoration: InputDecoration(
                          hintText: 'Write a reply to this request',
                          counterText: '',
                          filled: true,
                          fillColor: const Color(0xFFF5F8F6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    IconButton.filled(
                      onPressed: _sending ? null : _sendReply,
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF15765A),
                        foregroundColor: Colors.white,
                        fixedSize: const Size(48, 48),
                      ),
                      icon: _sending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded),
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

class _ReplyBubble extends StatelessWidget {
  const _ReplyBubble({required this.reply, required this.isExpertView});

  final SupportRequestReply reply;
  final bool isExpertView;

  @override
  Widget build(BuildContext context) {
    final isMine = isExpertView
        ? reply.senderRole == 'coach' || reply.senderRole == 'therapist'
        : reply.senderRole == 'user';
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.8,
        ),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: isMine ? const Color(0xFF15765A) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isMine ? null : Border.all(color: const Color(0xFFE3EBE6)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              reply.senderRole == 'coach' || reply.senderRole == 'therapist'
                  ? 'Expert'
                  : 'You',
              style: TextStyle(
                color: isMine
                    ? Colors.white.withValues(alpha: 0.82)
                    : const Color(0xFF66766D),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              reply.text,
              style: TextStyle(
                color: isMine ? Colors.white : const Color(0xFF20352B),
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final resolved = status == 'resolved';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: resolved ? const Color(0xFFE7F5ED) : const Color(0xFFFFF3DA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          color: resolved ? const Color(0xFF15765A) : const Color(0xFF92620A),
          fontWeight: FontWeight.w800,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.onRetry,
  });

  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 42, color: const Color(0xFF15765A)),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF15372C),
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
