// lib/features/help_about/presentation/screens/help_screen.dart
import 'package:flutter/material.dart';
import 'package:tifli/widgets/custom_app_bar.dart';
import 'package:tifli/core/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int? expandedIndex;
  String searchQuery = '';

  final List<HelpItem> helpItems = [
    HelpItem(
      icon: Icons.edit_note,
      title: 'How do I add a log?',
      content: '''Go to the Logs & Reports screen, tap on the log type you want (Feeding, Sleep, Growth, or Medication), fill in the details, and tap "Save".

You can also use the quick add buttons on the home screen for faster logging!''',
      category: 'Getting Started',
    ),
    HelpItem(
      icon: Icons.child_care,
      title: 'How do I add a new baby?',
      content: '''Tap on the baby selector at the top of the screen, tap "Add New Baby", enter your baby's information (Name, Date of birth, Photo, Gender), and tap "Save".

You can add multiple babies and easily switch between them!''',
      category: 'Getting Started',
    ),
    HelpItem(
      icon: Icons.notifications_active,
      title: 'How do reminders work?',
      content: '''Tifli automatically sends you smart reminders:

• No sleep logged for 18+ hours
• Weight reduction detected
• Missing daily logs (checked after 6 PM)

To enable: Allow notifications when prompted and keep the app running in the background. Reminders check every 6 hours automatically.''',
      category: 'Features',
    ),
    HelpItem(
      icon: Icons.filter_list,
      title: 'How do I filter logs?',
      content: '''Tap the filter icon at the top right of any logs screen, select your filters (Category, Date range, Time of day), and tap "Apply Filters".

Use the quick filter chips below the filter button for instant filtering!''',
      category: 'Features',
    ),
    HelpItem(
      icon: Icons.bar_chart,
      title: 'Understanding charts and analytics',
      content: '''Tifli provides beautiful visual insights:

 Growth: Weight, height, and head circumference trends
 Feeding: Meal frequency and type distribution  
 Sleep: Duration, patterns, and best sleep times

All charts update automatically as you add logs!''',
      category: 'Features',
    ),
    HelpItem(
      icon: Icons.edit,
      title: 'Can I edit or delete logs?',
      content: '''Yes! To edit: Tap the pencil icon on any log, make changes, and save.

To delete: Swipe left on any log and confirm deletion.

 Note: Deleted logs cannot be recovered!''',
      category: 'Managing Logs',
    ),
    HelpItem(
      icon: Icons.cloud_done,
      title: 'Is my data backed up?',
      content: '''Yes! Your data is automatically backed up:

✅ Cloud Storage in Supabase
✅ Real-time sync across devices
✅ Encrypted and secure
✅ Accessible anywhere with your account

Your baby's data is always safe!''',
      category: 'Data & Privacy',
    ),
    HelpItem(
      icon: Icons.security,
      title: 'Is my data private and secure?',
      content: '''Absolutely! We take security seriously:

 End-to-end encryption
 Your data is 100% private
 We never share or sell your data
 Protected by Firebase Auth

Your baby's information is completely secure.''',
      category: 'Data & Privacy',
    ),
    HelpItem(
      icon: Icons.download,
      title: 'Can I export my data?',
      content: '''Yes! Go to Settings → Export Data, choose format (CSV or PDF), select date range, and tap "Export".

Perfect for sharing with your pediatrician or keeping personal records!''',
      category: 'Data & Privacy',
    ),
    HelpItem(
      icon: Icons.language,
      title: 'How do I change the language?',
      content: '''Go to Settings → Language, select your preferred language, and the app will restart.

Supported: English, Arabic, French
(More languages coming soon!)''',
      category: 'Settings',
    ),
    HelpItem(
      icon: Icons.bug_report,
      title: 'Found a bug? Report it!',
      content: '''We appreciate bug reports!

Tap "Report Bug" button below, or email us at support@tifli.app with:
• Description of the issue
• Steps to reproduce
• Screenshots (if possible)

We'll investigate and fix it ASAP!''',
      category: 'Support',
    ),
    HelpItem(
      icon: Icons.contact_support,
      title: 'Need more help?',
      content: '''We're here for you!

 Email: support@tifli.app
 In-App: Tap "Contact Support" below
 Website: www.tifli.app/help
 WhatsApp: +213-123-456-789

Response time: Within 24 hours
We read every message!''',
      category: 'Support',
    ),
  ];

  List<HelpItem> get filteredItems {
    if (searchQuery.isEmpty) return helpItems;
    return helpItems.where((item) {
      return item.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          item.content.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  Future<void> _launchEmail() async {
    final uri = Uri.parse('mailto:support@tifli.app');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWhatsApp() async {
    final uri = Uri.parse('https://wa.me/213123456789');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = <String, List<HelpItem>>{};
    for (var item in filteredItems) {
      categories.putIfAbsent(item.category, () => []).add(item);
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const CustomAppBar(title: 'Help & Support'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card with Search
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6B6BFF), Color(0xFF8E44AD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6B6BFF).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.help_outline, size: 56, color: Colors.white),
                  const SizedBox(height: 16),
                  const Text(
                    'How can we help you?',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find answers to your questions below',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.95),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      onChanged: (value) => setState(() => searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Search for help...',
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF6B6BFF)),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 20),
                                onPressed: () => setState(() => searchQuery = ''),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.email_outlined,
                    title: 'Email Us',
                    subtitle: 'support@tifli.app',
                    color: const Color(0xFF6B6BFF),
                    onTap: _launchEmail,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.bug_report_outlined,
                    title: 'Report Bug',
                    subtitle: 'Help us improve',
                    color: Colors.red,
                    onTap: _launchEmail,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.chat_bubble_outline,
                    title: 'WhatsApp',
                    subtitle: 'Quick support',
                    color: Colors.green,
                    onTap: _launchWhatsApp,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.language,
                    title: 'Website',
                    subtitle: 'www.tifli.app',
                    color: Colors.orange,
                    onTap: () {
                      launchUrl(Uri.parse('https://www.tifli.app'));
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Results count
            if (searchQuery.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  '${filteredItems.length} result${filteredItems.length == 1 ? '' : 's'} found',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            // FAQ by Category
            if (filteredItems.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No results found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try different keywords',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...categories.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12, top: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6B6BFF),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6B6BFF),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...entry.value.map((item) {
                      final globalIndex = helpItems.indexOf(item);
                      return _HelpItemCard(
                        item: item,
                        isExpanded: expandedIndex == globalIndex,
                        searchQuery: searchQuery,
                        onTap: () {
                          setState(() {
                            expandedIndex =
                                expandedIndex == globalIndex ? null : globalIndex;
                          });
                        },
                      );
                    }),
                    const SizedBox(height: 20),
                  ],
                );
              }),

            // Contact Support Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.withOpacity(0.1),
                    Colors.pink.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.support_agent,
                      size: 48,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Still need help?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Our support team is here for you!\nWe typically respond within 24 hours.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _launchEmail,
                    icon: const Icon(Icons.email),
                    label: const Text('Contact Support'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class HelpItem {
  final IconData icon;
  final String title;
  final String content;
  final String category;

  HelpItem({
    required this.icon,
    required this.title,
    required this.content,
    required this.category,
  });
}

class _HelpItemCard extends StatelessWidget {
  final HelpItem item;
  final bool isExpanded;
  final String searchQuery;
  final VoidCallback onTap;

  const _HelpItemCard({
    required this.item,
    required this.isExpanded,
    required this.onTap,
    this.searchQuery = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded
              ? const Color(0xFF6B6BFF).withOpacity(0.3)
              : Colors.grey.withOpacity(0.1),
          width: isExpanded ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isExpanded ? 0.08 : 0.04),
            blurRadius: isExpanded ? 15 : 8,
            offset: Offset(0, isExpanded ? 4 : 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF6B6BFF).withOpacity(0.15),
                          const Color(0xFF8E44AD).withOpacity(0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item.icon,
                      color: const Color(0xFF6B6BFF),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: isExpanded ? const Color(0xFF6B6BFF) : Colors.grey,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B6BFF).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.content.trim(),
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.6,
                  ),
                ),
              ),
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
