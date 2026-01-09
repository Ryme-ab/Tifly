import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tifli/core/state/locale_cubit.dart';
import 'package:tifli/features/profiles/presentation/screens/parent_profile_screen.dart';
import 'package:tifli/features/theme/presentation/cubit/theme_cubit.dart';
import 'package:tifli/features/theme/presentation/cubit/theme_state.dart';
import 'package:tifli/l10n/app_localizations.dart';
import 'package:tifli/widgets/custom_app_bar.dart';
import 'package:tifli/features/settings/presentation/screens/notification_settings_screen.dart';
import 'package:tifli/features/settings/presentation/screens/privacy_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CustomAppBar(title: l10n.settings),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // General Section
          _buildSectionCard(
            context,
            title: 'General',
            icon: Icons.settings,
            children: [
              _buildNavigationOption(
                context,
                title: l10n.account,
                icon: Icons.person_outline,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ParentProfileScreen(),
                  ),
                ),
              ),
              _buildNavigationOption(
                context,
                title: l10n.notifications,
                icon: Icons.notifications_none,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const NotificationSettingsScreen(),
                  ),
                ),
              ),
              _buildNavigationOption(
                context,
                title: l10n.privacy,
                icon: Icons.lock_outline,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PrivacySettingsScreen(),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),



          const SizedBox(height: 16),

          // Language Section
          _buildSectionCard(
            context,
            title: l10n.language,
            icon: Icons.language,
            children: [_buildLanguageSelector(context, l10n)],
          ),

          const SizedBox(height: 16),

          // Other Section
          _buildSectionCard(
            context,
            title: 'Other',
            icon: Icons.more_horiz,
            children: [
              _buildNavigationOption(
                context,
                title: 'Manage Doctors',
                icon: Icons.medical_services_outlined,
                onTap: () => Navigator.pushNamed(context, '/add-doctor'),
              ),
              _buildNavigationOption(
                context,
                title: l10n.helpAndSupport,
                icon: Icons.help_outline,
                onTap: () {
                  // Navigate to help or show dialog
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // About Section
          _buildSectionCard(
            context,
            title: 'About',
            icon: Icons.info_outline,
            children: [
              ListTile(
                title: Text(
                  'Version',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                subtitle: Text(
                  '1.0.0',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }



  Widget _buildLanguageSelector(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, locale) {
        return Column(
          children: [
            _buildLanguageOption(
              context,
              code: 'en',
              currentCode: locale.languageCode,
              title: l10n.english,
              flag: '🇬🇧',
            ),
            _buildLanguageOption(
              context,
              code: 'fr',
              currentCode: locale.languageCode,
              title: l10n.french,
              flag: '🇫🇷',
            ),
          ],
        );
      },
    );
  }

  Widget _buildLanguageOption(
    BuildContext context, {
    required String code,
    required String currentCode,
    required String title,
    required String flag,
  }) {
    final isSelected = code == currentCode;

    return RadioListTile<String>(
      value: code,
      groupValue: currentCode,
      onChanged: (value) {
        if (value != null) {
          context.read<LocaleCubit>().changeLocale(value);
        }
      },
      title: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
      activeColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildNavigationOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Theme.of(context).iconTheme.color,
      ),
      onTap: onTap,
    );
  }
}
