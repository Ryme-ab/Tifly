import 'package:flutter/material.dart';
import '../../data/models/home_model.dart';
import 'package:tifli/core/constants/icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tifli/features/schedules/presentation/screens/checklist_screen.dart';
import 'package:tifli/l10n/app_localizations.dart';

class ScheduleItemWidget extends StatelessWidget {
  final ScheduleEntry entry;
  final VoidCallback? onCheck;
  const ScheduleItemWidget({super.key, required this.entry, this.onCheck});

  @override
  Widget build(BuildContext context) {
    final iconData = _mapStringToIcon(entry.icon);
    final iconColor = Colors.black;
    final bgColor = const Color(0xFFE8F1FF);
    const darkPink = Color(0xFF9B003D);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFFE6F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.pink.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(iconData, color: iconColor, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.title,
                  style: const TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(AppIcons.time, size: 18, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      entry.time,
                      style: const TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Checkbox(
            value: false,
            onChanged: (_) => onCheck?.call(),
            shape: const CircleBorder(),
            activeColor: darkPink,
            checkColor: Colors.white,
          ),
        ],
      ),
    );
  }

  IconData _mapStringToIcon(String s) {
    switch (s) {
      case 'feeding':
        return AppIcons.feeding;
      case 'sleep':
        return AppIcons.sleepNight;
      case 'medication':
        return AppIcons.medication;
      case 'hospital':
        return AppIcons.hospital;
      default:
        return AppIcons.time;
    }
  }
}

class ScheduleSection extends StatefulWidget {
  final List<ScheduleEntry> entries;
  const ScheduleSection({super.key, required this.entries});

  @override
  State<ScheduleSection> createState() => _ScheduleSectionState();
}

class _ScheduleSectionState extends State<ScheduleSection> {
  late List<ScheduleEntry> _today;

  @override
  void initState() {
    super.initState();
    _today = _filterToday(widget.entries);
  }

  @override
  void didUpdateWidget(covariant ScheduleSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entries != widget.entries) {
      setState(() => _today = _filterToday(widget.entries));
    }
  }

  List<ScheduleEntry> _filterToday(List<ScheduleEntry> list) {
    final now = DateTime.now();
    bool isSameDay(DateTime a, DateTime b) =>
        a.year == b.year && a.month == b.month && a.day == b.day;
    return list.where((e) {
      if (e.isoDate == null || e.isoDate!.isEmpty) return false;
      final dt = DateTime.tryParse(e.isoDate!);
      if (dt == null) return false;
      return isSameDay(dt, now);
    }).toList();
  }

  Future<void> _markDoneAndRemove(String checklistId) async {
    try {
      await Supabase.instance.client
          .from('checklist')
          .update({
            'done': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', checklistId);
      setState(() {
        _today.removeWhere((e) => e.id == checklistId);
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to mark done: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasItems = _today.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.todaysSchedule,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: "Poppins",
                color: Colors.black87,
              ),
            ),
            if (hasItems)
              InkWell(
                onTap: () {
                  // Navigate to the same Checklist screen as the drawer
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ChecklistPage()),
                  );
                },
                child: Text(
                  "${l10n.viewAll}  >",
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF9B003D),
                    fontWeight: FontWeight.w600,
                    fontFamily: "Poppins",
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        if (!hasItems)
          _EmptyState(
            title: l10n.noScheduledItems,
            subtitle: "Add a checklist item to keep track",
            buttonText: l10n.checklist,
            icon: Icons.event_note,
            onTap: () {
              // Navigate to the same Checklist screen as the drawer
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ChecklistPage()));
            },
          )
        else
          ..._today.map(
            (e) => Dismissible(
              key: ValueKey('sch_${e.id}'),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => _markDoneAndRemove(e.id),
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(Icons.check, color: Colors.green),
              ),
              child: ScheduleItemWidget(
                entry: e,
                onCheck: () => _markDoneAndRemove(e.id),
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final IconData icon;
  final VoidCallback onTap;
  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE6F0),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(12),
                child: Icon(icon, color: const Color(0xFF9B003D), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9B003D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onTap,
            child: const Text(
              'Open Checklist',
              style: TextStyle(fontFamily: 'Poppins', color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
