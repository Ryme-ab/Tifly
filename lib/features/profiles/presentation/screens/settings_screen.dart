import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tifli/core/config/supabaseClient.dart';
import 'package:tifli/core/utils/user_context.dart';
import 'package:tifli/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:tifli/features/navigation/app_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SupabaseClient _supabase = SupabaseClientManager().client;
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _soundEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userId = UserContext.getCurrentUserId();
      if (userId == null) return;

      final profile = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (mounted && profile != null) {
        setState(() {
          _userProfile = profile;
          // Load saved preferences
          _notificationsEnabled = profile['notifications_enabled'] ?? true;
          _darkModeEnabled = profile['dark_mode_enabled'] ?? false;
          _soundEnabled = profile['sound_enabled'] ?? true;
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updatePreference(String key, bool value) async {
    try {
      final userId = UserContext.getCurrentUserId();
      if (userId == null) return;

      await _supabase.from('profiles').update({key: value}).eq('id', userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Settings updated'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await context.read<AuthCubit>().signOut();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Logout failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBE185D),
            ),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _deleteAccount();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    try {
      final userId = UserContext.getCurrentUserId();
      if (userId == null) return;

      // Delete user profile
      await _supabase.from('profiles').delete().eq('id', userId);

      // Logout and navigate to login
      if (mounted) {
        await context.read<AuthCubit>().signOut();
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting account: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Change Password'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: obscureCurrent,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureCurrent
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () =>
                          setState(() => obscureCurrent = !obscureCurrent),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: obscureNew,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureNew ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => obscureNew = !obscureNew),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirm
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () =>
                          setState(() => obscureConfirm = !obscureConfirm),
                    ),
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (newPasswordController.text !=
                    confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Passwords do not match'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                if (newPasswordController.text.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password must be at least 6 characters'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  await _supabase.auth.updateUser(
                    UserAttributes(password: newPasswordController.text),
                  );

                  if (context.mounted) {
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password changed successfully'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error changing password: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFBE185D),
              ),
              child: const Text(
                'Change',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const primaryColor = Color(0xFFBE185D);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Section
                  _buildSection(
                    title: 'Profile',
                    isDark: isDark,
                    children: [
                      _buildSettingTile(
                        icon: Icons.person_outline,
                        title: 'Edit Profile',
                        subtitle:
                            _userProfile?['full_name'] ??
                            'Update your information',
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.parentProfile,
                        ),
                        isDark: isDark,
                      ),
                      _buildSettingTile(
                        icon: Icons.child_care_outlined,
                        title: 'Baby Profiles',
                        subtitle: 'Manage your babies',
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.myBabies);
                        },
                        isDark: isDark,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Preferences Section
                  _buildSection(
                    title: 'Preferences',
                    isDark: isDark,
                    children: [
                      _buildSwitchTile(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        subtitle: 'Receive app notifications',
                        value: _notificationsEnabled,
                        onChanged: (value) {
                          setState(() => _notificationsEnabled = value);
                          _updatePreference('notifications_enabled', value);
                        },
                        isDark: isDark,
                      ),
                      _buildSwitchTile(
                        icon: Icons.dark_mode_outlined,
                        title: 'Dark Mode',
                        subtitle: 'Enable dark theme',
                        value: _darkModeEnabled,
                        onChanged: (value) {
                          setState(() => _darkModeEnabled = value);
                          _updatePreference('dark_mode_enabled', value);
                        },
                        isDark: isDark,
                      ),
                      _buildSwitchTile(
                        icon: Icons.volume_up_outlined,
                        title: 'Sound',
                        subtitle: 'Enable app sounds',
                        value: _soundEnabled,
                        onChanged: (value) {
                          setState(() => _soundEnabled = value);
                          _updatePreference('sound_enabled', value);
                        },
                        isDark: isDark,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Security & Privacy Section
                  _buildSection(
                    title: 'Security & Privacy',
                    isDark: isDark,
                    children: [
                      _buildSettingTile(
                        icon: Icons.lock_outline,
                        title: 'Change Password',
                        subtitle: 'Update your password',
                        onTap: () {
                          _showChangePasswordDialog();
                        },
                        isDark: isDark,
                      ),
                      _buildSettingTile(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        subtitle: 'Read our privacy policy',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Privacy Policy coming soon'),
                            ),
                          );
                        },
                        isDark: isDark,
                      ),
                      _buildSettingTile(
                        icon: Icons.security_outlined,
                        title: 'Data Security',
                        subtitle: 'Your data is encrypted and secure',
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Data Security'),
                              content: const Text(
                                'Your data is encrypted using industry-standard encryption. '
                                'We never share your personal information with third parties.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        },
                        isDark: isDark,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Support Section
                  _buildSection(
                    title: 'Support',
                    isDark: isDark,
                    children: [
                      _buildSettingTile(
                        icon: Icons.help_outline,
                        title: 'Help & FAQ',
                        subtitle: 'Get help and answers',
                        onTap: () {
                          // TODO: Navigate to help screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Help & FAQ coming soon'),
                            ),
                          );
                        },
                        isDark: isDark,
                      ),
                      _buildSettingTile(
                        icon: Icons.feedback_outlined,
                        title: 'Send Feedback',
                        subtitle: 'Share your thoughts',
                        onTap: () {
                          // TODO: Open feedback form
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Feedback form coming soon'),
                            ),
                          );
                        },
                        isDark: isDark,
                      ),
                      _buildSettingTile(
                        icon: Icons.info_outline,
                        title: 'About',
                        subtitle: 'App version and info',
                        onTap: () {
                          showAboutDialog(
                            context: context,
                            applicationName: 'Tifli',
                            applicationVersion: '1.0.0',
                            applicationIcon: const Icon(
                              Icons.child_care,
                              size: 48,
                              color: primaryColor,
                            ),
                            children: [
                              const Text(
                                'Tifli is your comprehensive baby care companion, '
                                'helping you track and manage every aspect of your baby\'s growth and development.',
                              ),
                            ],
                          );
                        },
                        isDark: isDark,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Account Actions Section
                  _buildSection(
                    title: 'Account',
                    isDark: isDark,
                    children: [
                      _buildSettingTile(
                        icon: Icons.logout,
                        title: 'Logout',
                        subtitle: 'Sign out of your account',
                        onTap: _showLogoutConfirmation,
                        isDark: isDark,
                        iconColor: Colors.orange,
                      ),
                      _buildSettingTile(
                        icon: Icons.delete_outline,
                        title: 'Delete Account',
                        subtitle: 'Permanently delete your account',
                        onTap: _showDeleteAccountConfirmation,
                        isDark: isDark,
                        iconColor: Colors.red,
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildSection({
    required String title,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.grey[300] : Colors.grey[700],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[900] : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? const Color(0xFFBE185D)).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: iconColor ?? const Color(0xFFBE185D),
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDark ? Colors.grey[400] : Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFBE185D).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFFBE185D), size: 24),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFFBE185D),
      ),
    );
  }
}
