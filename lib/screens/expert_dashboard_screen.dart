import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/models/expert_profile.dart';
import 'package:fitstart_mobile_app/models/support_chat.dart';
import 'package:fitstart_mobile_app/models/support_request.dart';
import 'package:fitstart_mobile_app/screens/expert_chat_screen.dart';
import 'package:fitstart_mobile_app/screens/support_request_thread_screen.dart';
import 'package:fitstart_mobile_app/screens/welcome_screen.dart';
import 'package:fitstart_mobile_app/services/auth_service.dart';
import 'package:fitstart_mobile_app/services/expert_service.dart';
import 'package:fitstart_mobile_app/services/support_request_service.dart';
import 'package:fitstart_mobile_app/services/support_chat_service.dart';

class ExpertDashboardScreen extends StatefulWidget {
  const ExpertDashboardScreen({super.key});

  @override
  State<ExpertDashboardScreen> createState() => _ExpertDashboardScreenState();
}

class _ExpertDashboardScreenState extends State<ExpertDashboardScreen> {
  static const _green = Color(0xFF15765A);
  static const _ink = Color(0xFF15372C);

  final _expertService = ExpertService();
  final _requestService = SupportRequestService();
  final _chatService = SupportChatService();
  final _authService = AuthService();

  late Future<ExpertProfile> _profileFuture;
  late Stream<List<SupportRequest>> _requestsStream;

  @override
  void initState() {
    super.initState();
    _profileFuture = _expertService.getCurrentExpertProfile();
    _requestsStream = _requestService.watchAssignedRequests();
  }

  void _retry() {
    setState(() {
      _profileFuture = _expertService.getCurrentExpertProfile();
      _requestsStream = _requestService.watchAssignedRequests();
    });
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const WelcomeScreen()),
        (_) => false,
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not sign out: $error'),
          backgroundColor: const Color(0xFFB42318),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ExpertProfile>(
      future: _profileFuture,
      builder: (context, profileSnapshot) {
        if (profileSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF5F8F6),
            body: Center(child: CircularProgressIndicator(color: _green)),
          );
        }
        if (profileSnapshot.hasError || profileSnapshot.data == null) {
          return _buildProfileError(profileSnapshot.error);
        }

        final profile = profileSnapshot.data!;
        return StreamBuilder<List<SupportRequest>>(
          stream: _requestsStream,
          builder: (context, requestSnapshot) {
            final requests = requestSnapshot.data ?? const <SupportRequest>[];
            final openCount = requests
                .where((request) => request.status != 'resolved')
                .length;
            final latest = requests.take(3).toList();

            return Scaffold(
              backgroundColor: const Color(0xFFF5F8F6),
              appBar: AppBar(
                backgroundColor: Colors.white,
                foregroundColor: _ink,
                elevation: 0,
                title: const Text(
                  'Expert Dashboard',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                actions: [
                  IconButton(
                    tooltip: 'Log out',
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout_rounded),
                  ),
                  const SizedBox(width: 6),
                ],
              ),
              body: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: RefreshIndicator(
                      color: _green,
                      onRefresh: () async => _retry(),
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
                        children: [
                          _ProfileHeader(profile: profile),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _DashboardMetric(
                                  label: 'Assigned requests',
                                  value: requestSnapshot.hasError
                                      ? '—'
                                      : '${requests.length}',
                                  icon: Icons.inbox_outlined,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _DashboardMetric(
                                  label: 'Awaiting resolution',
                                  value: requestSnapshot.hasError
                                      ? '—'
                                      : '$openCount',
                                  icon: Icons.mark_chat_unread_outlined,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _SectionTitle(
                            title: 'Inbox',
                            subtitle: 'Requests assigned to your account, updated live.',
                            trailing: requestSnapshot.hasError
                                ? IconButton(
                                    tooltip: 'Retry loading requests',
                                    onPressed: _retry,
                                    icon: const Icon(Icons.refresh_rounded),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 10),
                          if (requestSnapshot.connectionState ==
                                  ConnectionState.waiting &&
                              !requestSnapshot.hasData)
                            const _LoadingCard()
                          else if (requestSnapshot.hasError)
                            _ErrorCard(
                              message: requestSnapshot.error is StateError
                                  ? 'This account is not approved to view expert requests.'
                                  : 'Could not load assigned requests. Verify the Firestore rules and connection.',
                              onRetry: _retry,
                            )
                          else if (requests.isEmpty)
                            const _EmptyCard(
                              icon: Icons.inbox_outlined,
                              title: 'No assigned requests yet',
                              message: 'New requests addressed to you will appear here.',
                            )
                          else
                            ...requests.map(
                              (request) => _RequestTile(
                                request: request,
                                onTap: () =>
                                    _openRequest(request, isExpertView: true),
                              ),
                            ),
                          const SizedBox(height: 24),
                          const _SectionTitle(
                            title: 'Live chat inbox',
                            subtitle: 'Private conversations with members, updated in real time.',
                          ),
                          const SizedBox(height: 10),
                          _ExpertChatInbox(
                            expertId: profile.uid,
                            expertRole: profile.role,
                            chatService: _chatService,
                          ),
                          const SizedBox(height: 24),
                          _SectionTitle(
                            title: 'Recent messages',
                            subtitle: 'Latest activity across your assigned requests.',
                          ),
                          const SizedBox(height: 10),
                          if (requestSnapshot.hasError)
                            const _EmptyCard(
                              icon: Icons.chat_bubble_outline_rounded,
                              title: 'Messages unavailable',
                              message: 'The recent message preview will appear when your inbox is available.',
                            )
                          else if (latest.isEmpty)
                            const _EmptyCard(
                              icon: Icons.forum_outlined,
                              title: 'Nothing to preview',
                              message: 'Replies and request updates will be summarized here.',
                            )
                          else
                            ...latest.map(
                              (request) => _RecentMessageTile(
                                request: request,
                                onTap: () =>
                                    _openRequest(request, isExpertView: true),
                              ),
                            ),
                          const SizedBox(height: 24),
                          _SectionTitle(
                            title: 'Your profile',
                            subtitle: 'Profile and availability status',
                          ),
                          const SizedBox(height: 10),
                          _ProfileDetails(profile: profile),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileError(Object? error) {
    final message = error is StateError
        ? error.message
        : 'The authenticated account profile could not be loaded. Check the Firestore user record and access rules.';
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _ink,
        title: const Text('Expert Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Log out',
            onPressed: _signOut,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: _ErrorCard(message: message, onRetry: _retry, onSignOut: _signOut),
    );
  }

  void _openRequest(SupportRequest request, {required bool isExpertView}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SupportRequestThreadScreen(
          request: request,
          isExpertView: isExpertView,
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final ExpertProfile profile;

  @override
  Widget build(BuildContext context) {
    final initials = profile.name.trim().isEmpty
        ? 'E'
        : profile.name.trim().substring(0, 1).toUpperCase();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF15765A), Color(0xFF0F5B46)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF15765A).withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 31,
            backgroundColor: Colors.white.withValues(alpha: 0.18),
            backgroundImage: profile.photoUrl.isNotEmpty
                ? NetworkImage(profile.photoUrl)
                : null,
            child: profile.photoUrl.isEmpty
                ? Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w800,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, ${profile.name}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  profile.displayRole,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                _AvailabilityBadge(available: profile.isAvailable),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge({required this.available});

  final bool? available;

  @override
  Widget build(BuildContext context) {
    final known = available != null;
    final active = available == true;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: known
            ? (active
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.12))
            : Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            active ? Icons.circle : Icons.circle_outlined,
            size: 9,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            available == null
                ? 'Availability not set'
                : (active ? 'Available' : 'Unavailable'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileDetails extends StatelessWidget {
  const _ProfileDetails({required this.profile});

  final ExpertProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3EBE6)),
      ),
      child: Column(
        children: [
          _ProfileDetailRow(
            icon: Icons.badge_outlined,
            label: 'Role',
            value: profile.displayRole,
          ),
          const Divider(height: 22),
          _ProfileDetailRow(
            icon: Icons.track_changes_outlined,
            label: 'Specialization',
            value: profile.specialization,
          ),
          const Divider(height: 22),
          _ProfileDetailRow(
            icon: Icons.verified_user_outlined,
            label: 'Approval',
            value: profile.isApproved ? 'Approved' : 'Not approved',
          ),
        ],
      ),
    );
  }
}

class _ProfileDetailRow extends StatelessWidget {
  const _ProfileDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF15765A), size: 20),
        const SizedBox(width: 10),
        SizedBox(
          width: 104,
          child: Text(label, style: const TextStyle(color: Color(0xFF66766D))),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Color(0xFF15372C),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ExpertChatInbox extends StatefulWidget {
  const _ExpertChatInbox({
    required this.expertId,
    required this.expertRole,
    required this.chatService,
  });

  final String expertId;
  final String expertRole;
  final SupportChatService chatService;

  @override
  State<_ExpertChatInbox> createState() => _ExpertChatInboxState();
}

class _ExpertChatInboxState extends State<_ExpertChatInbox> {
  late Stream<List<SupportChat>> _chatsStream;

  @override
  void initState() {
    super.initState();
    _chatsStream = _watchChats();
  }

  @override
  void didUpdateWidget(covariant _ExpertChatInbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expertId != widget.expertId ||
        oldWidget.expertRole != widget.expertRole ||
        oldWidget.chatService != widget.chatService) {
      _chatsStream = _watchChats();
    }
  }

  Stream<List<SupportChat>> _watchChats() {
    return widget.chatService.watchExpertChats(
      expertId: widget.expertId,
      expertRole: widget.expertRole,
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SupportChat>>(
      stream: _chatsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const _LoadingCard();
        }
        if (snapshot.hasError) {
          return const _EmptyCard(
            icon: Icons.cloud_off_outlined,
            title: 'Chats unavailable',
            message: 'Could not load your private chat inbox. Check your connection and deployed Firestore rules.',
          );
        }

        final chats = snapshot.data ?? const <SupportChat>[];
        if (chats.isEmpty) {
          return const _EmptyCard(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'No chats yet',
            message: 'When a member messages you from the expert directory, the conversation appears here.',
          );
        }

        return Column(
          children: chats.map((chat) {
            final displayName = chat.userName.trim().isEmpty
                ? 'FitStart member'
                : chat.userName;
            return Card(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 10),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
                side: const BorderSide(color: Color(0xFFE3EBE6)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 5,
                ),
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFE7F5ED),
                  child: Text(
                    displayName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF15765A),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                title: Text(
                  displayName,
                  style: const TextStyle(
                    color: Color(0xFF15372C),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                subtitle: Text(
                  chat.lastMessage.isEmpty
                      ? 'Conversation started — send a reply'
                      : chat.lastMessage,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(height: 1.35),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF8A9890),
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ExpertChatScreen(
                      chatId: chat.id,
                      peerName: displayName,
                      peerRole: 'FitStart member',
                      isExpertView: true,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _DashboardMetric extends StatelessWidget {
  const _DashboardMetric({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3EBE6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF15765A), size: 21),
          const SizedBox(height: 11),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF15372C),
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF66766D), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF15372C),
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(color: Color(0xFF66766D), fontSize: 12),
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class _RequestTile extends StatelessWidget {
  const _RequestTile({required this.request, required this.onTap});

  final SupportRequest request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE3EBE6)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFE7F5ED),
                child: Text(
                  request.userName.trim().isEmpty
                      ? 'M'
                      : request.userName.trim().substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF15765A),
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
                            request.userName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF15372C),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        _RequestStatus(status: request.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.specialization,
                      style: const TextStyle(
                        color: Color(0xFF15765A),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      request.lastMessage.isEmpty
                          ? request.message
                          : request.lastMessage,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF66766D),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(request.activityAt ?? request.createdAt),
                      style: const TextStyle(
                        color: Color(0xFF8A9890),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: Color(0xFF8A9890)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentMessageTile extends StatelessWidget {
  const _RecentMessageTile({required this.request, required this.onTap});

  final SupportRequest request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE3EBE6)),
      ),
      leading: const CircleAvatar(
        backgroundColor: Color(0xFFE7F5ED),
        child: Icon(
          Icons.chat_bubble_outline_rounded,
          color: Color(0xFF15765A),
        ),
      ),
      title: Text(
        request.userName,
        style: const TextStyle(
          color: Color(0xFF15372C),
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        request.lastMessage.isEmpty ? request.message : request.lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        _formatDate(request.activityAt ?? request.createdAt),
        style: const TextStyle(color: Color(0xFF8A9890), fontSize: 10),
      ),
      onTap: onTap,
    );
  }
}

class _RequestStatus extends StatelessWidget {
  const _RequestStatus({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final isResolved = status == 'resolved';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: isResolved ? const Color(0xFFE7F5ED) : const Color(0xFFFFF3DA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        status.replaceAll('_', ' ').toUpperCase(),
        style: TextStyle(
          color: isResolved ? const Color(0xFF15765A) : const Color(0xFF92620A),
          fontWeight: FontWeight.w800,
          fontSize: 9,
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) => const Card(
    color: Colors.white,
    child: Padding(
      padding: EdgeInsets.all(28),
      child: Center(child: CircularProgressIndicator(color: Color(0xFF15765A))),
    ),
  );
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFE3EBE6)),
    ),
    child: Column(
      children: [
        Icon(icon, size: 34, color: const Color(0xFF15765A)),
        const SizedBox(height: 9),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF15372C),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF66766D),
            fontSize: 12,
            height: 1.4,
          ),
        ),
      ],
    ),
  );
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    required this.message,
    required this.onRetry,
    this.onSignOut,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback? onSignOut;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(26),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFB42318),
            size: 42,
          ),
          const SizedBox(height: 12),
          const Text(
            'Dashboard unavailable',
            style: TextStyle(
              color: Color(0xFF15372C),
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            children: [
              OutlinedButton(
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
              if (onSignOut != null)
                FilledButton(
                  onPressed: onSignOut,
                  child: const Text('Sign out'),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}

String _formatDate(DateTime? date) {
  if (date == null) return 'Just now';
  final now = DateTime.now();
  if (now.difference(date).inDays == 0) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
  return '${date.day}/${date.month}/${date.year}';
}
