import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tifli/core/constants/app_colors.dart';
import 'package:tifli/l10n/app_localizations.dart';

import 'package:tifli/features/logs/presentation/screens/growth_logs_screen.dart';
import 'package:tifli/features/logs/presentation/screens/feeding_logs_screen.dart';
import 'package:tifli/features/logs/presentation/screens/sleeping_logs_screen.dart';
import 'package:tifli/features/logs/presentation/screens/medication_logs_screen.dart';

import 'package:tifli/widgets/custom_app_bar.dart';
import 'package:tifli/features/logs/presentation/cubit/baby_logs_cubit.dart';
import 'package:tifli/features/logs/presentation/cubit/baby_logs_state.dart';
import 'package:tifli/features/logs/data/models/baby_log_model.dart';
import 'package:tifli/core/state/child_selection_cubit.dart';

class BabyLogsReportsPage extends StatefulWidget {
  const BabyLogsReportsPage({super.key});

  @override
  State<BabyLogsReportsPage> createState() => _BabyLogsReportsPageState();
}

class _BabyLogsReportsPageState extends State<BabyLogsReportsPage> {
  LogType? selectedType;
  DateTime? selectedDate;
  String? selectedTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFromCubit();
    });
  }

  void _initializeFromCubit() {
    final cubit = context.read<ChildSelectionCubit>();
    cubit.stream.listen(_handleChildSelectionState);
    _handleChildSelectionState(cubit.state);
  }

  void _handleChildSelectionState(ChildSelectionState state) {
    if (!mounted) return;
    if (state is ChildSelected) {
      context.read<BabyLogsCubit>().loadAllLogs(state.childId);
    }
  }

  void _showFilterDialog() {
  LogType? tempType = selectedType;
  DateTime? tempDate = selectedDate;
  String? tempTime = selectedTime;

  final cubit = context.read<BabyLogsCubit>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, controller) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          controller: controller,
          child: StatefulBuilder(
            builder: (context, setState) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  "Filter Logs",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Log Type ChoiceChips
                Wrap(
                  spacing: 8,
                  children: LogType.values.map((e) {
                    final isSelected = tempType == e;
                    return ChoiceChip(
                      label: Text(e.toString().split('.').last),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => tempType = e);
                        cubit.applyFilter(type: tempType, date: tempDate, time: tempTime);
                      },
                      selectedColor: Colors.blue.withOpacity(0.2),
                      backgroundColor: Colors.grey[200],
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.blue : Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // Date Picker
                Row(
                  children: [
                    const Text("Date:"),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: tempDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => tempDate = picked);
                          cubit.applyFilter(type: tempType, date: tempDate, time: tempTime);
                        }
                      },
                      child: Text(
                        tempDate == null
                            ? "Select Date"
                            : "${tempDate!.year}-${tempDate!.month.toString().padLeft(2, '0')}-${tempDate!.day.toString().padLeft(2, '0')}",
                      ),
                    ),
                    if (tempDate != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() => tempDate = null);
                          cubit.applyFilter(type: tempType, date: tempDate, time: tempTime);
                        },
                      ),
                  ],
                ),

                // Time Picker
                Row(
                  children: [
                    const Text("Time:"),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: tempTime != null
                              ? TimeOfDay(
                                  hour: int.parse(tempTime!.split(':')[0]),
                                  minute: int.parse(tempTime!.split(':')[1]),
                                )
                              : TimeOfDay.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            tempTime =
                                "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
                          });
                          cubit.applyFilter(type: tempType, date: tempDate, time: tempTime);
                        }
                      },
                      child: Text(tempTime ?? "Select Time"),
                    ),
                    if (tempTime != null)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() => tempTime = null);
                          cubit.applyFilter(type: tempType, date: tempDate, time: tempTime);
                        },
                      ),
                  ],
                ),

                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            tempType = null;
                            tempDate = null;
                            tempTime = null;
                          });
                          cubit.applyFilter(type: null, date: null, time: null);
                        },
                        child: const Text("Reset"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Done"),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF0F1113) : const Color(0xFFF6F4F8);
    final panelColor = isDark ? const Color(0xFF121214) : Colors.white;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: CustomAppBar(
        title: l10n.logsAndReports,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _LogButton(
                          icon: Icons.local_drink,
                          title: l10n.feedingLogs,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const FeedingLogsScreen()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _LogButton(
                          icon: Icons.child_care,
                          title: l10n.growthLogs,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const GrowthLogsScreen()),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _LogButton(
                          icon: Icons.bedtime,
                          title: l10n.sleepingLogs,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SleepingLogsScreen()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _LogButton(
                          icon: Icons.medication_liquid,
                          title: l10n.medicationLogs,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const MedicationsScreen()),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: panelColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.45 : 0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withOpacity(0.02)
                            : Colors.transparent,
                        width: 0.5,
                      ),
                    ),
                    child: BlocBuilder<BabyLogsCubit, BabyLogsState>(
                      builder: (context, state) {
                        if (state is BabyLogsLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (state is BabyLogsError) {
                          return Center(
                              child: Text("Error: ${state.message}"));
                        }
                        if (state is BabyLogsLoaded) {
                          return LogTable(logs: state.logs);
                        }
                        return const Center(
                          child: Text("Select a baby to view logs."),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _LogButton({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  Color mapColor(String title) {
    switch (title) {
      case "Feeding Logs":
        return const Color(0xFF6B6BFF);
      case "Growth Logs":
        return const Color(0xFF4FB783);
      case "Sleeping Logs":
        return const Color(0xFF8E44AD);
      case "Medication Logs":
        return const Color(0xFFE74C3C);
      default:
        return const Color(0xFFF56587);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = mapColor(title);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.16), Colors.transparent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.02)
                : color.withOpacity(0.06),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.22),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15.8,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: isDark ? Colors.white70 : Colors.black45,
            ),
          ],
        ),
      ),
    );
  }
}

class LogTable extends StatelessWidget {
  final List<BabyLog> logs;

  const LogTable({super.key, required this.logs});

  Color tagColor(LogType type) {
    switch (type) {
      case LogType.feeding:
        return const Color(0xFF6B6BFF);
      case LogType.sleep:
        return const Color(0xFF4FB783);
      case LogType.medication:
        return const Color(0xFFE74C3C);
      case LogType.growth:
        return const Color(0xFF8E44AD);
    }
  }

  IconData typeIcon(LogType type) {
    switch (type) {
      case LogType.feeding:
        return Icons.local_drink;
      case LogType.sleep:
        return Icons.bedtime;
      case LogType.medication:
        return Icons.medication_liquid;
      case LogType.growth:
        return Icons.child_care;
    }
  }

  String formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final logDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (logDate == today) {
      return DateFormat('hh:mm a').format(timestamp);
    } else if (logDate == yesterday) {
      return "Yesterday\n${DateFormat('hh:mm a').format(timestamp)}";
    } else {
      return DateFormat('MMM d\nhh:mm a').format(timestamp);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (logs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: Text("No activity logs yet")),
      );
    }

    return Column(
      children: logs.map((log) {
        final color = tagColor(log.type);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: isDark ? const Color(0xFF0F1113) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: color.withOpacity(isDark ? 0.06 : 0.03),
              width: 0.6,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 6,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.6)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(typeIcon(log.type), size: 20, color: color),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.type.toString().split('.').last,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      log.details,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.35,
                        color: isDark ? Colors.grey[300] : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 78,
                child: Text(
                  formatTime(log.timestamp),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black54,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
