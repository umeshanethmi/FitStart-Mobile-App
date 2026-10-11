import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/models/expert_profile.dart';
import 'package:fitstart_mobile_app/models/support_chat.dart';
import 'package:fitstart_mobile_app/models/support_request.dart';
import 'package:fitstart_mobile_app/screens/expert_chat_screen.dart';
import 'package:fitstart_mobile_app/screens/support_request_thread_screen.dart';
import 'package:fitstart_mobile_app/services/expert_service.dart';
import 'package:fitstart_mobile_app/services/support_chat_service.dart';
import 'package:fitstart_mobile_app/services/support_request_service.dart';

class ExpertSupportScreen extends StatefulWidget {
  const ExpertSupportScreen({super.key});

  @override
  State<ExpertSupportScreen> createState() => _ExpertSupportScreenState();
}

class _ExpertSupportScreenState extends State<ExpertSupportScreen> {
  final _service = SupportRequestService();
  final _chatService = SupportChatService();

  late Stream<List<SupportRequest>> _requestsStream;
  int _directoryRevision = 0;

  @override
  void initState() {
    super.initState();
    _requestsStream = _service.watchRequests();
  }

  void _retryLoading() {
    setState(() => _requestsStream = _service.watchRequests());
  }

  Future<void> _refreshDirectory() async {
    setState(() => _directoryRevision++);
  }

  Future<void> _openProfile(ExpertProfile expert) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFFDBEAFE),
                  child: Text(
                    expert.name.isNotEmpty
                        ? expert.name.substring(0, 1).toUpperCase()
                        : 'E',
                    style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expert.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        expert.displayRole,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _InfoRow(label: 'Specialization', value: expert.specialization),
            _InfoRow(label: 'Experience', value: '${expert.experience} years'),
            _InfoRow(label: 'Availability', value: expert.availabilityText),
            const SizedBox(height: 8),
            Text(
              expert.bio,
              style: const TextStyle(
                color: Color(0xFF334155),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _openSupportRequest(expert),
                icon: const Icon(Icons.assignment_outlined),
                label: const Text('Send a Support Request'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  _openConversation(expert);
                },
                icon: const Icon(Icons.message_rounded),
                label: const Text('Message Expert'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openSupportRequest(ExpertProfile expert) async {
    final controller = TextEditingController();
    var isSubmitting = false;
    String? errorMessage;
    try {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text('Contact ${expert.name}'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Your message will be sent to this ${expert.displayRole.toLowerCase()}.',
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  autofocus: true,
                  minLines: 3,
                  maxLines: 6,
                  maxLength: 2000,
                  decoration: const InputDecoration(
                    hintText:
                        'Describe what support you need (10-2000 characters)',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                if (errorMessage != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Color(0xFFB42318)),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: isSubmitting
                    ? null
                    : () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        setDialogState(() {
                          isSubmitting = true;
                          errorMessage = null;
                        });
                        try {
                          await _service.submitRequest(
                            expertId: expert.uid,
                            expertRole: expert.role,
                            expertName: expert.name,
                            specialization: expert.specialization,
                            message: controller.text,
                          );
                          if (!dialogContext.mounted) return;
                          Navigator.of(dialogContext).pop();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Your support request was sent.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        } catch (error) {
                          if (!dialogContext.mounted) return;
                          setDialogState(() {
                            isSubmitting = false;
                            errorMessage = error is ArgumentError
                                ? error.message
                                : 'The request could not be sent. Check your connection and access, then try again.';
                          });
                        }
                      },
                child: isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Send request'),
              ),
            ],
          ),
        ),
      );
    } finally {
      controller.dispose();
    }
  }

  Future<void> _openConversation(ExpertProfile expert) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign in to start a conversation.'),
          backgroundColor: Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      final chat = await _chatService.getOrCreateChat(
        expertId: expert.uid,
        expertRole: expert.role,
        expertName: expert.name,
      );

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ExpertChatScreen(
            chatId: chat.id,
            peerName: expert.name,
            peerRole: expert.displayRole,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      final message = error is FirebaseException
          ? 'Could not open chat (${error.code}). Check your connection and Firestore access.'
          : error is StateError || error is ArgumentError
          ? error.toString().replaceFirst('Bad state: ', '')
          : 'Could not open this chat. Please try again.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFFB42318),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FD),
      appBar: AppBar(
        title: const Text(
          'Expert Support',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color(0xFFF6F8FD),
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Refresh experts',
            onPressed: _refreshDirectory,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: RefreshIndicator(
              onRefresh: _refreshDirectory,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.support_agent_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'A coach or therapist is just a message away',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Browse approved experts, review their profiles, and message them directly in real time.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const _SectionHeading(
                    title: 'Fitness Coaches',
                    subtitle: 'Home workout support and performance guidance.',
                  ),
                  const SizedBox(height: 10),
                  _ExpertSection(
                    key: ValueKey('coach-$_directoryRevision'),
                    role: 'coach',
                    onOpenProfile: _openProfile,
                    onOpenChat: _openConversation,
                  ),
                  const SizedBox(height: 22),
                  const _SectionHeading(
                    title: 'Therapists',
                    subtitle:
                        'Recovery, movement safety, and wellness support.',
                  ),
                  const SizedBox(height: 10),
                  _ExpertSection(
                    key: ValueKey('therapist-$_directoryRevision'),
                    role: 'therapist',
                    onOpenProfile: _openProfile,
                    onOpenChat: _openConversation,
                  ),
                  const SizedBox(height: 22),
                  const _SectionHeading(
                    title: 'My Conversations',
                    subtitle: 'Restart a prior discussion or continue a chat.',
                  ),
                  const SizedBox(height: 10),
                  _ConversationList(chatService: _chatService),
                  const SizedBox(height: 22),
                  const _SectionHeading(
                    title: 'Your support requests',
                    subtitle: 'Legacy requests saved in your account.',
                  ),
                  const SizedBox(height: 10),
                  _requestHistory(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _requestHistory() {
    return StreamBuilder<List<SupportRequest>>(
      stream: _requestsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _StateCard(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF2563EB)),
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          final message = snapshot.error is StateError
              ? 'Sign in to view your support requests.'
              : snapshot.error is FirebaseException
              ? 'We could not load your requests. Check your connection or access and try again.'
              : 'Something went wrong while loading your requests.';
          return _StateCard(
            child: _EmptyOrErrorContent(
              icon: Icons.cloud_off_outlined,
              title: 'Requests unavailable',
              message: message,
              actionLabel: 'Try again',
              onPressed: _retryLoading,
            ),
          );
        }
        final requests = snapshot.data ?? const <SupportRequest>[];
        if (requests.isEmpty) {
          return const _StateCard(
            child: _EmptyOrErrorContent(
              icon: Icons.inbox_outlined,
              title: 'No requests yet',
              message: 'When you send a support request, it will appear here with its current status.',
            ),
          );
        }
        return Column(
          children: [
            for (final request in requests) ...[
              _RequestCard(
                request: request,
                onOpen: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => SupportRequestThreadScreen(
                      request: request,
                      isExpertView: false,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }
}

class _ExpertSection extends StatefulWidget {
  const _ExpertSection({
    super.key,
    required this.role,
    required this.onOpenProfile,
    required this.onOpenChat,
  });

  final String role;
  final Future<void> Function(ExpertProfile) onOpenProfile;
  final Future<void> Function(ExpertProfile) onOpenChat;

  @override
  State<_ExpertSection> createState() => _ExpertSectionState();
}

class _ExpertSectionState extends State<_ExpertSection> {
  late Future<List<ExpertProfile>> _expertsFuture;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _expertsFuture = ExpertService().getApprovedExperts(role: widget.role);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ExpertProfile>>(
      future: _expertsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _StateCard(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF2563EB)),
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          final error = snapshot.error;
          final message = error is FirebaseException
              ? 'Directory request failed (${error.code}). ${error.message ?? 'Check your connection, directory documents, and Firestore access.'}'
              : error is StateError
              ? error.message.toString()
              : 'The approved expert list could not be retrieved. Check your connection and Firestore configuration.';
          return _StateCard(
            child: _EmptyOrErrorContent(
              icon: Icons.error_outline_rounded,
              title: 'Experts unavailable',
              message: message,
              actionLabel: 'Try again',
              onPressed: () => setState(_refresh),
            ),
          );
        }
        final experts = snapshot.data ?? const <ExpertProfile>[];
        if (experts.isEmpty) {
          return const _StateCard(
            child: _EmptyOrErrorContent(
              icon: Icons.person_search_outlined,
              title: 'No experts available',
              message: 'Check back soon for a new member of the support team.',
            ),
          );
        }
        return Column(
          children: [
            for (final expert in experts) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: const Color(0xFFDBEAFE),
                      backgroundImage: expert.photoUrl.isNotEmpty
                          ? NetworkImage(expert.photoUrl)
                          : null,
                      child: Text(
                        expert.photoUrl.isEmpty
                            ? (expert.name.isNotEmpty
                                  ? expert.name.substring(0, 1).toUpperCase()
                                  : 'E')
                            : '',
                        style: const TextStyle(
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  expert.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: expert.isAvailable == true
                                      ? const Color(0xFFDCFCE7)
                                      : const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  expert.availabilityText,
                                  style: TextStyle(
                                    color: expert.isAvailable == true
                                        ? const Color(0xFF15803D)
                                        : const Color(0xFF475569),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            expert.specialization,
                            style: const TextStyle(
                              color: Color(0xFF2563EB),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            expert.bio,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF475569),
                              fontSize: 13,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => widget.onOpenProfile(expert),
                                  child: const Text('View Profile'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: FilledButton(
                                  onPressed: () => widget.onOpenChat(expert),
                                  child: const Text('Message'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
            ],
          ],
        );
      },
    );
  }
}

class _ConversationList extends StatefulWidget {
  const _ConversationList({required this.chatService});

  final SupportChatService chatService;

  @override
  State<_ConversationList> createState() => _ConversationListState();
}

class _ConversationListState extends State<_ConversationList> {
  late Stream<List<SupportChat>> _chatsStream;

  @override
  void initState() {
    super.initState();
    _chatsStream = widget.chatService.watchUserChats();
  }

  @override
  void didUpdateWidget(covariant _ConversationList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.chatService != widget.chatService) {
      _chatsStream = widget.chatService.watchUserChats();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SupportChat>>(
      stream: _chatsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _StateCard(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF2563EB)),
              ),
            ),
          );
        }
        if (snapshot.hasError) {
          return _StateCard(
            child: _EmptyOrErrorContent(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Conversations unavailable',
              message: 'Please retry in a moment.',
            ),
          );
        }
        final chats = snapshot.data ?? const <SupportChat>[];
        if (chats.isEmpty) {
          return const _StateCard(
            child: _EmptyOrErrorContent(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'No conversations yet',
              message: 'Choose an expert and start your first chat from the directory above.',
            ),
          );
        }
        return Column(
          children: [
            for (final chat in chats) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFDBEAFE),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  title: Text(
                    chat.expertName,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    chat.lastMessage.isEmpty
                        ? 'No messages yet'
                        : chat.lastMessage,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: chat.lastMessageAt != null
                      ? Text(
                          '${chat.lastMessageAt!.day}/${chat.lastMessageAt!.month}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        )
                      : null,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ExpertChatScreen(
                        chatId: chat.id,
                        peerName: chat.expertName,
                        peerRole: chat.expertRole == 'coach'
                            ? 'Fitness Coach'
                            : 'Therapist',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request, required this.onOpen});

  final SupportRequest request;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    request.expertName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    request.status.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF1D4ED8),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              request.specialization,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              request.message,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            _LatestRequestReply(request: request),
            const SizedBox(height: 6),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'View conversation',
                style: TextStyle(
                  color: Color(0xFF2563EB),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LatestRequestReply extends StatefulWidget {
  const _LatestRequestReply({required this.request});

  final SupportRequest request;

  @override
  State<_LatestRequestReply> createState() => _LatestRequestReplyState();
}

class _LatestRequestReplyState extends State<_LatestRequestReply> {
  final _service = SupportRequestService();
  late Stream<List<SupportRequestReply>> _repliesStream;

  @override
  void initState() {
    super.initState();
    _repliesStream = _service.watchReplies(widget.request);
  }

  @override
  void didUpdateWidget(covariant _LatestRequestReply oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.request.id != widget.request.id ||
        oldWidget.request.userId != widget.request.userId) {
      _repliesStream = _service.watchReplies(widget.request);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SupportRequestReply>>(
      stream: _repliesStream,
      builder: (context, snapshot) {
        if (snapshot.hasError ||
            snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }
        final replies = snapshot.data ?? const <SupportRequestReply>[];
        if (replies.isEmpty) return const SizedBox.shrink();
        final reply = replies.last;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(11),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F7F3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Latest reply: ${reply.text}',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF33443B),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        );
      },
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 12.5),
        ),
      ],
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: child,
    );
  }
}

class _EmptyOrErrorContent extends StatelessWidget {
  const _EmptyOrErrorContent({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 38, color: const Color(0xFF2563EB)),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF64748B),
              height: 1.5,
            ),
          ),
          if (actionLabel != null && onPressed != null) ...[
            const SizedBox(height: 14),
            FilledButton(onPressed: onPressed, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
