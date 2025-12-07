import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tifli/features/logs/presentation/screens/growth_logs_screen.dart';
import 'package:tifli/widgets/custom_app_bar.dart';

import 'package:tifli/features/logs/presentation/cubit/baby_logs_cubit.dart';
import 'package:tifli/features/logs/presentation/cubit/baby_logs_state.dart';
import 'package:tifli/features/logs/data/models/baby_log_model.dart';

import 'package:tifli/core/state/child_selection_cubit.dart';
// import 'package:tifli/features/profiles/presentation/cubit/children_cubit.dart';

import 'feeding_logs_screen.dart';
import 'sleeping_logs_screen.dart';
import 'medication_logs_screen.dart';
// For test child ID

class BabyLogsReportsPage extends StatefulWidget {
  const BabyLogsReportsPage({super.key});

  @override
  State<BabyLogsReportsPage> createState() => _BabyLogsReportsPageState();
}

class _BabyLogsReportsPageState extends State<BabyLogsReportsPage> {
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
    // If NoChildSelected, the BabyLogsCubit builder in the body will handle showing an empty/prompt state if needed,
    // or we can clear logs here. For now, the builder handles the view.
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF1C1C1E)
          : const Color(0xFFF9F6FA),
      appBar: const CustomAppBar(title: 'Logs & Reports'),

      body: Column(
        children: [
          const SizedBox(height: 12),

          const SizedBox(height: 16),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _LogButton(
                    icon: Icons.local_drink,
                    title: "Feeding Logs",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FeedingLogsScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _LogButton(
                    icon: Icons.child_care,
                    title: "Growth Logs",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const GrowthLogsScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _LogButton(
                    icon: Icons.bedtime,
                    title: "Sleeping Logs",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SleepingLogsScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _LogButton(
                    icon: Icons.medication_liquid,
                    title: "Medication Logs",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MedicationsScreen(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ----------------------
                  // ACTIVITY LOG TABLE
                  // ----------------------
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Activity Logs",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        BlocBuilder<BabyLogsCubit, BabyLogsState>(
                          builder: (context, state) {
                            if (state is BabyLogsLoading) {
                              return const Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            if (state is BabyLogsError) {
                              return Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Center(
                                  child: Text("Error: ${state.message}"),
                                ),
                              );
                            }

                            if (state is BabyLogsLoaded) {
                              return LogTable(logs: state.logs);
                            }

                            // Check global selection state if waiting
                            final selectionState = context
                                .watch<ChildSelectionCubit>()
                                .state;
                            if (selectionState is NoChildSelected) {
                              return const Padding(
                                padding: EdgeInsets.all(32.0),
                                child: Center(
                                  child: Text(
                                    "Please select a baby from the drawer to view logs",
                                  ),
                                ),
                              );
                            }

                            return const Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Center(
                                child: Text("Select a baby to view logs"),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF9F6FA),
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF48484A) : const Color(0xFFE5E5EA),
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.description),
              label: const Text("Generate Report"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF56587),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {},
            ),
          ],
        ),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 28, color: const Color(0xFFF56587)),
            const SizedBox(width: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// TABLE -----------------------------------------------------------
class LogTable extends StatelessWidget {
  final List<BabyLog> logs;

  const LogTable({super.key, required this.logs});

  Color tagColor(LogType type) {
    switch (type) {
      case LogType.feeding:
        return const Color(0xFF6B6BFF);
      case LogType.sleep:
        return Colors.teal;
      case LogType.medication:
        return Colors.redAccent;
      case LogType.growth:
        return Colors.grey;
    }
  }

  String getLogTypeName(LogType type) {
    switch (type) {
      case LogType.feeding:
        return "Feeding";
      case LogType.sleep:
        return "Sleep";
      case LogType.medication:
        return "Medication";
      case LogType.growth:
        return "Growth";
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
        padding: EdgeInsets.all(32.0),
        child: Center(child: Text("No activity logs yet")),
      );
    }

    return Table(
      columnWidths: const {
        0: FixedColumnWidth(90),
        1: FixedColumnWidth(100),
        2: FlexColumnWidth(),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: logs.map((log) {
        final color = tagColor(log.type);

        return TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                formatTime(log.timestamp),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  getLogTypeName(log.type),
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                log.details,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
