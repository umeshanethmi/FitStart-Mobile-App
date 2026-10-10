import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/models/support_request.dart';
import 'package:fitstart_mobile_app/services/support_request_service.dart';

class ExpertSupportScreen extends StatefulWidget {
  const ExpertSupportScreen({super.key});

  @override
  State<ExpertSupportScreen> createState() => _ExpertSupportScreenState();
}

class _ExpertSupportScreenState extends State<ExpertSupportScreen> {
  static const Color _blue = Color(0xFF2563EB);
  static const Color _navy = Color(0xFF0F172A);

  final SupportRequestService _service = SupportRequestService();
  late Stream<List<SupportRequest>> _requestsStream;

  static const List<_ExpertRole> _expertRoles = [
    _ExpertRole(
      id: 'fitness_coach',
      name: 'Fitness coach support',
      specialization: 'Beginner home workouts',
      description: 'General guidance for building a comfortable, consistent at-home fitness routine.',
      icon: Icons.fitness_center_rounded,
      color: Color(0xFF2563EB),
      initials: 'FC',
    ),
    _ExpertRole(
      id: 'physical_therapist',
      name: 'Physical therapist support',
      specialization: 'Movement and exercise safety',
      description: 'A place to share questions about movement, comfort, and exercising safely.',
      icon: Icons.health_and_safety_outlined,
      color: Color(0xFF0F766E),
      initials: 'PT',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _requestsStream = _service.watchRequests();
  }

  void _retryLoading() {
    setState(() => _requestsStream = _service.watchRequests());
  }

  Future<void> _openRequestForm(_ExpertRole expert) async {
    final submitted = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) =>
            _SupportRequestFormScreen(expert: expert, service: _service),
      ),
    );
    if (submitted == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your support request was submitted.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openDetails(_ExpertRole expert) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => _ExpertDetailsScreen(
          expert: expert,
          onSendRequest: () => _openRequestForm(expert),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FD),
      appBar: AppBar(
        title: const Text(
          'Expert Support',
          style: TextStyle(
            color: _navy,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color(0xFFF6F8FD),
        foregroundColor: _navy,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              _welcomeCard(),
              const SizedBox(height: 22),
              const _SectionHeading(
                title: 'Choose a support area',
                subtitle:
                    'Explore a role and send a question when you are ready.',
              ),
              const SizedBox(height: 12),
              for (final expert in _expertRoles) ...[
                _ExpertCard(
                  expert: expert,
                  onDetails: () => _openDetails(expert),
                  onRequest: () => _openRequestForm(expert),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 12),
              const _SectionHeading(
                title: 'Your support requests',
                subtitle:
                    'Requests saved to your account and their latest status.',
              ),
              const SizedBox(height: 12),
              _requestHistory(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _welcomeCard() {
    return Container(
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
          const SizedBox(height: 14),
          const Text(
            'A little guidance goes a long way',
            style: TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Welcome to FitStart support. Choose a topic and tell us what you need help with.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.92),
              fontSize: 14,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'These are support categories, not individual practitioner profiles. Requests are stored in your account; live professional replies are not currently available in the app.',
              style: TextStyle(color: Colors.white, fontSize: 12, height: 1.4),
            ),
          ),
        ],
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
              child: Center(child: CircularProgressIndicator(color: _blue)),
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
        final requests = snapshot.data ?? const [];
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
              _RequestCard(request: request),
              const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }
}

class _ExpertRole {
  const _ExpertRole({
    required this.id,
    required this.name,
    required this.specialization,
    required this.description,
    required this.icon,
    required this.color,
    required this.initials,
  });

  final String id;
  final String name;
  final String specialization;
  final String description;
  final IconData icon;
  final Color color;
  final String initials;
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
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade700, height: 1.4),
        ),
      ],
    );
  }
}

class _ExpertCard extends StatelessWidget {
  const _ExpertCard({
    required this.expert,
    required this.onDetails,
    required this.onRequest,
  });

  final _ExpertRole expert;
  final VoidCallback onDetails;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 27,
                  backgroundColor: expert.color.withValues(alpha: 0.12),
                  child: Text(
                    expert.initials,
                    style: TextStyle(
                      color: expert.color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        expert.name,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        expert.specialization,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Tooltip(
                  message: 'Support category placeholder, not a named expert',
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFF64748B),
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              expert.description,
              style: TextStyle(color: Colors.grey.shade800, height: 1.4),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: onDetails,
                  icon: const Icon(Icons.arrow_outward_rounded, size: 18),
                  label: const Text('View details'),
                ),
                FilledButton.icon(
                  onPressed: onRequest,
                  icon: const Icon(Icons.edit_note_rounded, size: 20),
                  label: const Text('Send a request'),
                  style: FilledButton.styleFrom(
                    backgroundColor: expert.color,
                    minimumSize: const Size(48, 48),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpertDetailsScreen extends StatelessWidget {
  const _ExpertDetailsScreen({
    required this.expert,
    required this.onSendRequest,
  });

  final _ExpertRole expert;
  final VoidCallback onSendRequest;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FD),
      appBar: AppBar(
        title: const Text('Support details'),
        backgroundColor: const Color(0xFFF6F8FD),
        foregroundColor: const Color(0xFF0F172A),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: expert.color.withValues(alpha: 0.12),
                        child: Icon(expert.icon, color: expert.color, size: 30),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        expert.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        expert.specialization,
                        style: TextStyle(
                          color: expert.color,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        expert.description,
                        style: const TextStyle(height: 1.5),
                      ),
                      const SizedBox(height: 18),
                      const _NoticeBox(
                        message: 'This is a support topic, not a profile of a specific person. FitStart does not currently have a live expert response workflow.',
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: onSendRequest,
                          icon: const Icon(Icons.edit_note_rounded),
                          label: const Text('Write a support request'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportRequestFormScreen extends StatefulWidget {
  const _SupportRequestFormScreen({
    required this.expert,
    required this.service,
  });

  final _ExpertRole expert;
  final SupportRequestService service;

  @override
  State<_SupportRequestFormScreen> createState() =>
      _SupportRequestFormScreenState();
}

class _SupportRequestFormScreenState extends State<_SupportRequestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      await widget.service.submitRequest(
        expertId: widget.expert.id,
        expertName: widget.expert.name,
        specialization: widget.expert.specialization,
        message: _messageController.text,
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _error = error is FirebaseException
            ? 'Your request could not be saved (${error.code}). Check your connection or access and try again.'
            : 'Your request could not be saved. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FD),
      appBar: AppBar(
        title: const Text('Send a support request'),
        backgroundColor: const Color(0xFFF6F8FD),
        foregroundColor: const Color(0xFF0F172A),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.expert.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.expert.specialization,
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: _messageController,
                          minLines: 5,
                          maxLines: 8,
                          maxLength: 2000,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(
                            labelText: 'How can we help?',
                            hintText: 'Describe your question or the support you are looking for.',
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          validator: (value) {
                            final message = value?.trim() ?? '';
                            if (message.length < 10) {
                              return 'Please enter at least 10 characters.';
                            }
                            if (message.length > 2000) {
                              return 'Please keep your message under 2000 characters.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        const _NoticeBox(
                          message: 'Your message is saved privately to your FitStart account. This app does not currently provide live professional replies.',
                        ),
                        if (_error != null) ...[
                          const SizedBox(height: 12),
                          Semantics(
                            liveRegion: true,
                            child: Text(
                              _error!,
                              style: const TextStyle(color: Color(0xFFB42318)),
                            ),
                          ),
                        ],
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _isSubmitting ? null : _submit,
                            icon: _isSubmitting
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.send_rounded),
                            label: Text(
                              _isSubmitting
                                  ? 'Saving request...'
                                  : 'Submit request',
                            ),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({required this.request});

  final SupportRequest request;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    request.expertName,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _StatusChip(status: request.status),
              ],
            ),
            if (request.specialization.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                request.specialization,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
              ),
            ],
            const SizedBox(height: 10),
            Text(request.message, style: const TextStyle(height: 1.45)),
            if (request.createdAt != null) ...[
              const SizedBox(height: 10),
              Text(
                _formatDate(request.createdAt!),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$month/$day/${local.year} · $hour:$minute';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      'submitted' => 'Submitted',
      'in_review' => 'In review',
      'resolved' => 'Resolved',
      _ => 'Status unavailable',
    };
    return Semantics(
      label: 'Request status: $label',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Color(0xFF1D4ED8),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE2E8F0)),
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
        children: [
          Icon(icon, color: const Color(0xFF64748B), size: 30),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700, height: 1.4),
          ),
          if (actionLabel != null && onPressed != null) ...[
            const SizedBox(height: 8),
            TextButton(onPressed: onPressed, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

class _NoticeBox extends StatelessWidget {
  const _NoticeBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: Color(0xFF334155),
          fontSize: 13,
          height: 1.45,
        ),
      ),
    );
  }
}
