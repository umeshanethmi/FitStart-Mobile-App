import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fitstart_mobile_app/screens/login_screen.dart';
import 'package:fitstart_mobile_app/services/auth_service.dart';
import 'package:fitstart_mobile_app/services/user_settings_service.dart';

class SettingsPrivacyScreen extends StatefulWidget {
  const SettingsPrivacyScreen({super.key});

  @override
  State<SettingsPrivacyScreen> createState() => _SettingsPrivacyScreenState();
}

class _SettingsPrivacyScreenState extends State<SettingsPrivacyScreen> {
  static const Color _navy = Color(0xFF0F172A);
  static const Color _background = Color(0xFFF6F8FD);

  final AuthService _authService = AuthService();
  final UserSettingsService _settingsService = UserSettingsService();

  bool _isLoading = true;
  bool _isSavingReminder = false;
  bool _isSendingDeletionRequest = false;
  bool _workoutReminders = false;
  String? _loadError;

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }
    try {
      final enabled = await _settingsService.loadWorkoutReminders();
      if (!mounted) return;
      setState(() {
        _workoutReminders = enabled;
        _isLoading = false;
      });
    } on StateError catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError = error.message;
        _isLoading = false;
      });
    } on FirebaseException catch (error) {
      if (!mounted) return;
      setState(() {
        _loadError =
            'Could not load your saved settings (${error.code}). Please try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _setWorkoutReminders(bool enabled) async {
    final previousValue = _workoutReminders;
    setState(() {
      _workoutReminders = enabled;
      _isSavingReminder = true;
    });
    try {
      await _settingsService.saveWorkoutReminders(enabled);
      if (!mounted) return;
      _showMessage('Reminder preference saved.');
    } on StateError catch (error) {
      if (!mounted) return;
      setState(() => _workoutReminders = previousValue);
      _showMessage(error.message, isError: true);
    } on FirebaseException catch (error) {
      if (!mounted) return;
      setState(() => _workoutReminders = previousValue);
      _showMessage(
        'Could not save your preference (${error.code}). Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isSavingReminder = false);
    }
  }

  Future<void> _editProfile() async {
    final user = _currentUser;
    if (user == null) {
      _showMessage('Sign in to edit your profile.', isError: true);
      return;
    }
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _EditProfileDialog(initialName: user.displayName ?? ''),
    );
    if (name == null || !mounted) return;

    try {
      final signedInUser = FirebaseAuth.instance.currentUser;
      if (signedInUser == null) {
        throw StateError('Sign in to edit your profile.');
      }
      await signedInUser.updateDisplayName(name);
      await signedInUser.reload();
      if (!mounted) return;
      setState(() {});
      _showMessage('Profile name updated.');
    } on StateError catch (error) {
      if (!mounted) return;
      _showMessage(error.message, isError: true);
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      _showMessage(
        'Could not update your profile (${error.code}). Please try again.',
        isError: true,
      );
    }
  }

  Future<void> _sendPasswordReset() async {
    final user = _currentUser;
    final email = user?.email;
    if (user == null || email == null || email.isEmpty) {
      _showMessage(
        'No email address is available for this account.',
        isError: true,
      );
      return;
    }
    final usesPassword = user.providerData.any(
      (provider) => provider.providerId == 'password',
    );
    if (!usesPassword) {
      _showMessage(
        'This account does not use an email and password sign-in.',
        isError: true,
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        _showMessage('Password reset instructions were sent to $email.');
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      _showMessage(
        'Could not send password reset instructions (${error.code}).',
        isError: true,
      );
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You can sign back in whenever you are ready.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await _authService.signOut();
      if (!mounted) return;
      await Navigator.of(context).pushAndRemoveUntil<void>(
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        _showMessage(
          'Could not log out (${error.code}). Please try again.',
          isError: true,
        );
      }
    }
  }

  Future<void> _requestAccountDeletion() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.delete_outline_rounded,
          color: Color(0xFFB42318),
        ),
        title: const Text('Request account deletion?'),
        content: const Text(
          'This records a deletion request in your account. It does not delete your account or data, and FitStart does not currently have an automated review or deletion workflow.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB42318),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Submit request'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isSendingDeletionRequest = true);
    try {
      await _settingsService.requestAccountDeletion();
      if (mounted) {
        _showMessage(
          'Your account deletion request was submitted. Your account has not been deleted.',
        );
      }
    } on StateError catch (error) {
      if (mounted) _showMessage(error.message, isError: true);
    } on FirebaseException catch (error) {
      if (mounted) {
        _showMessage(
          'Could not submit the deletion request (${error.code}). Please try again.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingDeletionRequest = false);
    }
  }

  void _showStoredData() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Information FitStart stores'),
        content: const SingleChildScrollView(
          child: Text(
            'Your account: authentication email and display name.\n\n'
            'Your profile: fitness goal and the physical profile fields you provide (such as age, height, and weight), saved under your own user document.\n\n'
            'Your activity: workout plans and workout progress associated with your account.\n\n'
            'Your app activity: achievement records and any support requests you submit.\n\n'
            'Settings: the workout reminder preference saved in your user document. This is only a saved preference; FitStart does not schedule notifications.\n\n'
            'This screen does not enable an external data-sharing feature. Access to your account data is governed by Firebase Authentication and Firestore Security Rules.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? const Color(0xFFB42318) : null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final user = _currentUser;
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Go back',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Settings & Privacy',
          style: TextStyle(
            color: _navy,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: _background,
        foregroundColor: _navy,
        elevation: 0,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              const Text(
                'Make FitStart work for you',
                style: TextStyle(
                  color: _navy,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Manage your account, preferences, and personal data.',
                style: TextStyle(color: Colors.grey.shade700, height: 1.4),
              ),
              const SizedBox(height: 22),
              _sectionTitle('Account'),
              const SizedBox(height: 10),
              _SettingsCard(
                child: Column(
                  children: [
                    ListTile(
                      leading: const _LeadingIcon(
                        icon: Icons.person_outline_rounded,
                      ),
                      title: Text(
                        user?.displayName?.trim().isNotEmpty == true
                            ? user!.displayName!
                            : 'Name not set',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(user?.email ?? 'No signed-in account'),
                      isThreeLine: user?.email == null,
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _ActionTile(
                      icon: Icons.edit_outlined,
                      title: 'Edit profile name',
                      subtitle: 'Update your Firebase account display name',
                      onTap: _editProfile,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              _sectionTitle('Preferences'),
              const SizedBox(height: 10),
              _SettingsCard(
                child: Column(
                  children: [
                    SwitchListTile(
                      secondary: const _LeadingIcon(
                        icon: Icons.notifications_none_rounded,
                      ),
                      title: const Text(
                        'Workout reminder preference',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        _isLoading ? 'Loading your saved preference...' : 'Saved to your account only. This does not schedule notifications.',
                      ),
                      value: _workoutReminders,
                      onChanged:
                          _isLoading || _loadError != null || _isSavingReminder
                          ? null
                          : _setWorkoutReminders,
                    ),
                    if (_isLoading)
                      const LinearProgressIndicator(minHeight: 2)
                    else if (_loadError != null)
                      _InlineError(message: _loadError!, onRetry: _loadSettings)
                    else if (_isSavingReminder)
                      const LinearProgressIndicator(minHeight: 2),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              _sectionTitle('Privacy & Data'),
              const SizedBox(height: 10),
              _SettingsCard(
                child: Column(
                  children: [
                    _ActionTile(
                      icon: Icons.shield_outlined,
                      title: 'Your data and privacy',
                      subtitle:
                          'Review what FitStart stores about your account',
                      onTap: _showStoredData,
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _LeadingIcon(icon: Icons.lock_outline_rounded),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Data sharing',
                                  style: TextStyle(
                                    color: _navy,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'No external data-sharing preference is available because the app has no data-sharing feature.',
                                  style: TextStyle(height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              _sectionTitle('Account security'),
              const SizedBox(height: 10),
              _SettingsCard(
                child: _ActionTile(
                  icon: Icons.password_rounded,
                  title: 'Change password',
                  subtitle: 'Send a secure password reset link to your email',
                  onTap: _sendPasswordReset,
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              ),
              const SizedBox(height: 22),
              _sectionTitle('Account actions'),
              const SizedBox(height: 10),
              _SettingsCard(
                child: Column(
                  children: [
                    _ActionTile(
                      icon: Icons.logout_rounded,
                      title: 'Log out',
                      subtitle: 'Sign out of this FitStart account',
                      onTap: _logout,
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _ActionTile(
                      icon: Icons.delete_outline_rounded,
                      title: 'Request account deletion',
                      subtitle: 'Submit a request; this does not immediately delete data',
                      onTap: _isSendingDeletionRequest
                          ? null
                          : _requestAccountDeletion,
                      trailing: _isSendingDeletionRequest
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.chevron_right_rounded),
                      iconColor: const Color(0xFFB42318),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Theme switching and language selection are not currently supported.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
    title,
    style: const TextStyle(
      color: _navy,
      fontSize: 17,
      fontWeight: FontWeight.w700,
    ),
  );
}

class _EditProfileDialog extends StatefulWidget {
  const _EditProfileDialog({required this.initialName});

  final String initialName;

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit display name'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          maxLength: 60,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            final trimmed = value?.trim() ?? '';
            if (trimmed.isEmpty) return 'Enter your name.';
            if (trimmed.length > 60) return 'Use 60 characters or fewer.';
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _nameController.text.trim());
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

  final Widget child;

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
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: const Color(0xFFEFF6FF),
      child: Icon(icon, color: const Color(0xFF2563EB), size: 21),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
    this.iconColor = const Color(0xFF2563EB),
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minVerticalPadding: 12,
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: iconColor.withValues(alpha: 0.1),
        child: Icon(icon, color: iconColor, size: 21),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Color(0xFFB42318)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Color(0xFFB42318)),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
