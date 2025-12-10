import 'package:flutter/material.dart';
import 'package:tifli/l10n/app_localizations.dart';
import 'package:tifli/core/widgets/language_selector.dart';
import 'package:tifli/core/constants/app_colors.dart';

class LanguageDemoScreen extends StatelessWidget {
  const LanguageDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: const [LanguageSelector(), SizedBox(width: 8)],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.language,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildDemoSection(l10n, context),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoSection(AppLocalizations l10n, BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDemoItem(Icons.home, l10n.home),
            _buildDemoItem(Icons.person, l10n.profile),
            _buildDemoItem(Icons.assignment, l10n.logs),
            _buildDemoItem(Icons.calendar_today, l10n.schedules),
            _buildDemoItem(Icons.photo_album, l10n.memories),
            _buildDemoItem(Icons.restaurant, l10n.feeding),
            _buildDemoItem(Icons.bedtime, l10n.sleeping),
            _buildDemoItem(Icons.show_chart, l10n.growth),
            _buildDemoItem(Icons.medication, l10n.medication),
            const Divider(),
            _buildDemoItem(Icons.save, l10n.save),
            _buildDemoItem(Icons.cancel, l10n.cancel),
            _buildDemoItem(Icons.delete, l10n.delete),
            _buildDemoItem(Icons.edit, l10n.edit),
            _buildDemoItem(Icons.add, l10n.add),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
