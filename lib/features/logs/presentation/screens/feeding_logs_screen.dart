// lib/screens/feeding_logs_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:tifli/core/constants/app_colors.dart';
import 'package:tifli/features/logs/presentation/cubit/feeding_logs_cubit.dart';
import 'package:tifli/features/logs/presentation/cubit/feeding_logs_state.dart';
import 'package:tifli/features/logs/data/models/logs_model.dart';
import 'package:tifli/features/trackers/presentation/screens/food_tracker_screen.dart';
import 'package:tifli/widgets/custom_app_bar.dart';

enum DateFilterOption { today, last7Days, thisMonth, nextMonth }

class FeedingLogsScreen extends StatefulWidget {
  const FeedingLogsScreen({super.key});

  @override
  State<FeedingLogsScreen> createState() => _FeedingLogsScreenState();
}

class _FeedingLogsScreenState extends State<FeedingLogsScreen> {
  DateFilterOption selectedFilter = DateFilterOption.last7Days;
  bool showAllLogs = false; // Show more/less toggle

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedingLogCubit>().loadLogs();
    });
  }

  List<FeedingLog> _filterLogs(List<FeedingLog> logs) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    switch (selectedFilter) {
      case DateFilterOption.today:
        return logs.where((log) {
          final logDate = DateTime(
            log.mealTime.year,
            log.mealTime.month,
            log.mealTime.day,
          );
          return logDate == today;
        }).toList();
      case DateFilterOption.last7Days:
        final cutoff = today.subtract(const Duration(days: 7));
        // Only show logs from past 7 days, exclude future dates
        return logs
            .where(
              (log) =>
                  log.mealTime.isAfter(cutoff) &&
                  log.mealTime.isBefore(tomorrow),
            )
            .toList();
      case DateFilterOption.thisMonth:
        // Show entire current month (including future dates in this month)
        return logs
            .where(
              (log) =>
                  log.mealTime.year == now.year &&
                  log.mealTime.month == now.month,
            )
            .toList();
      case DateFilterOption.nextMonth:
        // Show logs from next month only (future dates)
        final nextMonthDate = DateTime(now.year, now.month + 1, 1);
        final nextMonth = nextMonthDate.month;
        final nextMonthYear = nextMonthDate.year;
        return logs
            .where(
              (log) =>
                  log.mealTime.year == nextMonthYear &&
                  log.mealTime.month == nextMonth,
            )
            .toList();
    }
  }

  String _getFilterLabel(DateFilterOption option) {
    switch (option) {
      case DateFilterOption.today:
        return 'Today';
      case DateFilterOption.last7Days:
        return '7 Days';
      case DateFilterOption.thisMonth:
        return 'This Month';
      case DateFilterOption.nextMonth:
        return 'Next Month';
    }
  }

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
                  color: const Color(0xFFFFF3F5),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      DateFormat('MMM d, yyyy • hh:mm a').format(log.mealTime),
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                    if (log.items.isNotEmpty)
                      Text(
                        log.items,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${log.amount}ml',
                    style: const TextStyle(
                      color: Colors.pinkAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffb03a57),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      log.status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.grey, size: 20),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FoodTrackerScreen(
                        showTracker: false,
                        existingEntry: log.feedingLogToMeal(log),
                      ),
                    ),
                  ).then((_) => context.read<FeedingLogCubit>().loadLogs());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const CustomAppBar(title: 'Feeding Tracker'),
      body: SafeArea(
        child: BlocBuilder<FeedingLogCubit, FeedingLogState>(
          builder: (context, state) {
            if (state is FeedingLogLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is FeedingLogError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            if (state is FeedingLogLoaded) {
              final filteredLogs = _filterLogs(state.logs)
                ..sort((a, b) => b.mealTime.compareTo(a.mealTime));

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: DateFilterOption.values.map((option) {
                        final isSelected = selectedFilter == option;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(_getFilterLabel(option)),
                            selected: isSelected,
                            onSelected: (selected) =>
                                setState(() => selectedFilter = option),
                            selectedColor: const Color(0xffb03a57),
                            backgroundColor: Colors.grey[200],
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header
                  const Text(
                    'Feeding Logs',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 16),

                  // Logs List
                  if (filteredLogs.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.restaurant_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No feeding logs for ${_getFilterLabel(selectedFilter).toLowerCase()}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    // Logs with Show More/Less
                    ...(() {
                      final logsToShow = showAllLogs
                          ? filteredLogs
                          : (filteredLogs.length > 5
                                ? filteredLogs.take(5).toList()
                                : filteredLogs);
                      final hasMoreLogs = filteredLogs.length > 5;

                      return [
                        ...logsToShow.map((log) => _logCard(log, context)),

                        // Show More / Show Less Button
                        if (hasMoreLogs)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    showAllLogs = !showAllLogs;
                                  });
                                },
                                icon: Icon(
                                  showAllLogs
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  color: const Color(0xFF6B6BFF),
                                ),
                                label: Text(
                                  showAllLogs
                                      ? "Show Less"
                                      : "Show More (${filteredLogs.length - 5} more)",
                                  style: const TextStyle(
                                    color: Color(0xFF6B6BFF),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ];
                    })(),

                    const SizedBox(height: 32),
                    const Text(
                      " Feeding Analytics",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    FeedingAnalyticsSection(logs: filteredLogs, isDark: isDark),
                    const SizedBox(height: 100),
                  ],
                ],
              );
            }
            return const Center(child: Text('No data'));
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xffb03a57),
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FoodTrackerScreen()),
          );
          // Reload logs after returning from add screen
          if (mounted) {
            context.read<FeedingLogCubit>().loadLogs();
          }
        },
      ),
    );
  }
}

// ===== FEEDING ANALYTICS SECTION =====
class FeedingAnalyticsSection extends StatelessWidget {
  final List<FeedingLog> logs;
  final bool isDark;

  const FeedingAnalyticsSection({
    super.key,
    required this.logs,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final mealTypeCounts = <String, int>{};
    final amountPerDay = <String, int>{};
    final feedingsByHour = <int, int>{};

    for (var log in logs) {
      mealTypeCounts[log.mealType] = (mealTypeCounts[log.mealType] ?? 0) + 1;
      final dayKey = DateFormat('MM/dd').format(log.mealTime);
      amountPerDay[dayKey] = (amountPerDay[dayKey] ?? 0) + log.amount;
      final hour = log.mealTime.hour;
      feedingsByHour[hour] = (feedingsByHour[hour] ?? 0) + 1;
    }

    final totalAmount = logs.fold<int>(0, (sum, log) => sum + log.amount);
    final avgAmount = logs.isEmpty ? 0 : (totalAmount / logs.length).round();
    final maxAmount = logs.isEmpty
        ? 0
        : logs.map((l) => l.amount).reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        // Stats Cards
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.restaurant,
                title: "Avg Amount",
                value: "${avgAmount}ml",
                color: const Color(0xFFFF9800),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.water_drop,
                title: "Total",
                value: "${totalAmount}ml",
                color: const Color(0xFF2196F3),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.history,
                title: "Feedings",
                value: "${logs.length}",
                color: const Color(0xFF4CAF50),
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Meal Type Distribution
        if (mealTypeCounts.isNotEmpty) ...[
          _ChartCard(
            title: "Feeding Type Distribution",
            isDark: isDark,
            child: SizedBox(
              height: 220,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 50,
                        sections: mealTypeCounts.entries.map((e) {
                          final percentage = (e.value / logs.length * 100)
                              .toStringAsFixed(1);
                          return PieChartSectionData(
                            value: e.value.toDouble(),
                            title: '$percentage%',
                            color: _getMealTypeColor(e.key),
                            radius: 60,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: mealTypeCounts.entries.map((e) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: _getMealTypeColor(e.key),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  e.key,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                              Text(
                                '${e.value}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Amount Over Time
        if (amountPerDay.isNotEmpty) ...[
          _ChartCard(
            title: "Amount Consumed Over Time",
            isDark: isDark,
            child: SizedBox(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.only(right: 16, top: 16),
                child: _buildAmountLineChart(amountPerDay, isDark),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Feeding Times Pattern
        if (feedingsByHour.isNotEmpty) ...[
          _ChartCard(
            title: "Feeding Times Pattern",
            isDark: isDark,
            child: SizedBox(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.only(right: 16, top: 16),
                child: _buildFeedingTimesChart(feedingsByHour, isDark),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAmountLineChart(Map<String, int> amountPerDay, bool isDark) {
    final sortedDays = amountPerDay.keys.toList()..sort();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 100,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              getTitlesWidget: (value, _) => Text(
                '${value.toInt()}ml',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (value, _) {
                final index = value.toInt();
                if (index >= 0 &&
                    index < sortedDays.length &&
                    (index % 2 == 0 || sortedDays.length <= 7)) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      sortedDays[index],
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              sortedDays.length,
              (i) =>
                  FlSpot(i.toDouble(), amountPerDay[sortedDays[i]]!.toDouble()),
            ),
            isCurved: true,
            color: const Color(0xFF2196F3),
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                    radius: 4,
                    color: const Color(0xFF2196F3),
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF2196F3).withOpacity(0.15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedingTimesChart(Map<int, int> feedingsByHour, bool isDark) {
    final blocks = <String, int>{
      'Morning\n(6AM-12PM)': 0,
      'Afternoon\n(12PM-6PM)': 0,
      'Evening\n(6PM-9PM)': 0,
      'Night\n(9PM-6AM)': 0,
    };

    feedingsByHour.forEach((hour, count) {
      if (hour >= 6 && hour < 12) {
        blocks['Morning\n(6AM-12PM)'] = blocks['Morning\n(6AM-12PM)']! + count;
      } else if (hour >= 12 && hour < 18) {
        blocks['Afternoon\n(12PM-6PM)'] =
            blocks['Afternoon\n(12PM-6PM)']! + count;
      } else if (hour >= 18 && hour < 21) {
        blocks['Evening\n(6PM-9PM)'] = blocks['Evening\n(6PM-9PM)']! + count;
      } else {
        blocks['Night\n(9PM-6AM)'] = blocks['Night\n(9PM-6AM)']! + count;
      }
    });

    final entries = blocks.entries.toList();
    final maxValue = entries
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (maxValue + 2).toDouble(),
        barGroups: entries.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.value.toDouble(),
                color: const Color(0xFFFF9800),
                width: 35,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(6),
                ),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: (maxValue + 2).toDouble(),
                  color: Colors.grey.withOpacity(0.1),
                ),
              ),
            ],
          );
        }).toList(),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) =>
              FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              getTitlesWidget: (value, _) => Text(
                value.toInt().toString(),
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              getTitlesWidget: (value, _) {
                final index = value.toInt();
                if (index >= 0 && index < entries.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      entries[index].key,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Color _getMealTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'formula':
        return const Color(0xFF2196F3);
      case 'breast milk':
        return const Color(0xFFE91E63);
      case 'solid':
        return const Color(0xFF4CAF50);
      default:
        return const Color(0xFFFF9800);
    }
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121214) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white60 : Colors.black54,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isDark;

  const _ChartCard({
    required this.title,
    required this.child,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121214) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}
