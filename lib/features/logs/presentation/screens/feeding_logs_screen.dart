// lib/screens/feeding_logs_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:tifli/core/constants/app_colors.dart';
import 'package:tifli/features/logs/presentation/cubit/feeding_logs_cubit.dart';
import 'package:tifli/features/logs/presentation/cubit/feeding_logs_state.dart';
import 'package:tifli/features/logs/data/models/logs_model.dart';

// import 'add_feeding_log_screen.dart';
import 'package:tifli/features/trackers/presentation/screens/food_tracker_screen.dart';
// If you have a custom app bar widget import it or replace with AppBar
import 'package:tifli/widgets/custom_app_bar.dart'; // optional
// For test child ID

class FeedingLogsScreen extends StatefulWidget {
  const FeedingLogsScreen({super.key});

  @override
  State<FeedingLogsScreen> createState() => _FeedingLogsScreenState();
}

class _FeedingLogsScreenState extends State<FeedingLogsScreen> {
  @override
  void initState() {
    super.initState();
    // Load feeding logs data when screen is initialized
    // Using test child ID - replace with actual child ID in production
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedingLogCubit>().loadLogs();
    });
  }

  // icon mapping helper
  IconData _iconFromMealType(String type) {
    switch (type.toLowerCase()) {
      case 'formula':
        return Icons.local_drink;
      case 'solid':
        return Icons.restaurant;
      case 'breast milk':
        return Icons.local_hospital;
      default:
        return Icons.fastfood;
    }
  }

  Widget _logCard(FeedingLog log, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: Key(
          log.id.isEmpty
              ? log.createdAt.millisecondsSinceEpoch.toString()
              : log.id,
        ),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: const Color(0xffb03a57),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (_) {
          if (log.id.isNotEmpty) {
            context.read<FeedingLogCubit>().deleteLog(log.id);
          }
        },
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _iconFromMealType(log.mealType),
                  color: const Color(0xffb03a57),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.mealType,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      DateFormat('hh:mm a').format(log.mealTime),
                      style: const TextStyle(color: Colors.black54),
                    ),
                    if (log.items.isNotEmpty)
                      Text(
                        log.items,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                '${log.amount}ml',
                style: const TextStyle(
                  color: Colors.pinkAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xffb03a57),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  log.status,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.grey),
                onPressed: () {
                  // Navigate to FoodTrackerScreen in edit mode
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FoodTrackerScreen(
                        showTracker: false,
                        existingEntry: log.feedingLogToMeal(
                          log,
                        ), // <-- pass the existing Meal/FeedingLog here
                      ),
                    ),
                  ).then((_) {
                    // Reload logs when coming back from edit
                    context.read<FeedingLogCubit>().loadLogs();
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // simple summary card building counts per mealtype
  Widget _summaryCard(List<FeedingLog> logs) {
    final counts = <String, int>{};
    for (final l in logs) {
      counts[l.mealType] = (counts[l.mealType] ?? 0) + 1;
    }
    final barData = counts.entries.toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Feeding Summary',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= barData.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            barData[idx].key,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(barData.length, (i) {
                  final val = barData[i].value.toDouble();
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: val,
                        width: 24,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const CustomAppBar(
        title: 'Feeding Tracker',
      ), // replace or use normal AppBar
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Feeding Logs',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  CircleAvatar(radius: 18, backgroundColor: Colors.grey[200]),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocBuilder<FeedingLogCubit, FeedingLogState>(
                  builder: (context, state) {
                    if (state is FeedingLogLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is FeedingLogLoaded) {
                      final logs = state.logs;
                      if (logs.isEmpty) {
                        return const Center(child: Text('No logs yet'));
                      }
                      return ListView(
                        children: [
                          ...logs.map((log) => _logCard(log, context)),
                          const SizedBox(height: 20),
                          _summaryCard(logs),
                        ],
                      );
                    } else if (state is FeedingLogError) {
                      return Center(child: Text('Error: ${state.message}'));
                    }
                    return const Center(child: Text('No data'));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xffb03a57),
        child: const Icon(Icons.add),
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FoodTrackerScreen()),
          );
          if (added != null && added is FeedingLog) {
            // call add on cubit
            context.read<FeedingLogCubit>().addLog(added);
          }
        },
      ),
    );
  }
}
