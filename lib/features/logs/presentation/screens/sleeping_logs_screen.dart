import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tifli/features/trackers/presentation/screens/sleep_tracker_screen.dart';
import 'package:tifli/widgets/custom_app_bar.dart';
import 'package:tifli/features/logs/presentation/cubit/sleep_log_cubit.dart';
import 'package:tifli/features/logs/presentation/cubit/sleep_log_state.dart';
import 'package:tifli/features/logs/data/models/sleep_log_model.dart';
import 'package:tifli/core/config/test_config.dart'; // For test child ID

class SleepingLogsScreen extends StatefulWidget {
  const SleepingLogsScreen({super.key});

  @override
  State<SleepingLogsScreen> createState() => _SleepingLogsScreenState();
}

class _SleepingLogsScreenState extends State<SleepingLogsScreen> {
  @override
  void initState() {
    super.initState();
    // Load sleep logs data when screen is initialized
    // Using test child ID - replace with actual child ID in production
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SleepLogCubit>().loadLogs(TestConfig.testChildId);
    });
  }

  Widget _buildQuickStatsRow(List<SleepLog> logs) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final weeklyLogs = logs
        .where((log) => log.createdAt.isAfter(weekAgo))
        .toList();
    final todayLogs = logs
        .where(
          (log) =>
              log.createdAt.year == now.year &&
              log.createdAt.month == now.month &&
              log.createdAt.day == now.day,
        )
        .toList();

    final totalWeeklyHours = weeklyLogs.fold<double>(
      0.0,
      (sum, log) => sum + log.getDurationInHours(),
    );
    final totalTodayHours = todayLogs.fold<double>(
      0.0,
      (sum, log) => sum + log.getDurationInHours(),
    );

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: "This Week",
            value: "${totalWeeklyHours.toStringAsFixed(1)} hrs",
            icon: Icons.calendar_month,
            color: const Color(0xffe1bee7),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: "Today",
            value: "${totalTodayHours.toStringAsFixed(1)} hrs",
            icon: Icons.nightlight_round,
            color: const Color(0xffffccbc),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f4f8),
      appBar: const CustomAppBar(title: 'Sleeping Tracker'),
      body: SafeArea(
        child: BlocBuilder<SleepLogCubit, SleepLogState>(
          builder: (context, state) {
            if (state is SleepLogLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is SleepLogError) {
              return Center(child: Text('Error: ${state.message}'));
            } else if (state is SleepLogLoaded) {
              final logs = state.logs;

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Sleep Logs",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: const AssetImage('assets/profile.jpg'),
                        backgroundColor: Colors.grey[200],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Pie Chart
                  _buildPieChartSection(logs),
                  const SizedBox(height: 24),

                  // Quick Stats Cards
                  _buildQuickStatsRow(logs),
                  const SizedBox(height: 24),

                  // Logs
                  const Text(
                    "Recent Sleep Logs",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  if (logs.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text('No sleep logs yet'),
                      ),
                    )
                  else
                    ...logs
                        .map((log) => _buildSleepCard(log, context))
                        .toList(),

                  const SizedBox(height: 24),

                  // Weekly Trend
                  const Text(
                    "Weekly Sleep Trend",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  _buildWeeklyBarChart(logs),
                ],
              );
            }

            return const Center(child: Text('No data'));
          },
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xffb03a57),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SleepPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // 🥧 Pie chart for sleep quality
  Widget _buildPieChartSection(List<SleepLog> logs) {
    final qualityData = <String, double>{};

    for (final log in logs) {
      qualityData[log.quality] = (qualityData[log.quality] ?? 0) + 1;
    }

    if (qualityData.isEmpty) {
      qualityData['No Data'] = 1;
    }

    final total = qualityData.values.reduce((a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text(
            "Sleep Quality Distribution",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sections: qualityData.entries.map((entry) {
                  final color = switch (entry.key.toLowerCase()) {
                    "good" => const Color(0xffb2dfdb),
                    "fair" => const Color(0xfffff9c4),
                    "poor" => const Color(0xffffccbc),
                    _ => Colors.grey,
                  };
                  final percentage = (entry.value / total) * 100;
                  return PieChartSectionData(
                    color: color,
                    value: entry.value,
                    title: "${percentage.toStringAsFixed(1)}%",
                    radius: 40,
                    titleStyle: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  );
                }).toList(),
                centerSpaceRadius: 50,
                sectionsSpace: 2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: qualityData.keys.map((key) {
              final color = switch (key.toLowerCase()) {
                "good" => const Color(0xffb2dfdb),
                "fair" => const Color(0xfffff9c4),
                "poor" => const Color(0xffffccbc),
                _ => Colors.grey,
              };
              return Row(
                children: [
                  Container(width: 14, height: 14, color: color),
                  const SizedBox(width: 4),
                  Text(key),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 💤 Sleep logs cards
  Widget _buildSleepCard(SleepLog log, BuildContext context) {
    final color = switch (log.quality.toLowerCase()) {
      "good" => const Color(0xffe0f7fa),
      "fair" => const Color(0xfffff9c4),
      "poor" => const Color(0xffffebee),
      _ => Colors.white,
    };

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
            context.read<SleepLogCubit>().deleteLog(log.id);
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.nightlight_round,
                  color: Color(0xffb03a57),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('MMM d, yyyy').format(log.startTime),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "Duration: ${log.getFormattedDuration()}",
                      style: const TextStyle(color: Colors.pinkAccent),
                    ),
                    if (log.description.isNotEmpty)
                      Text(
                        log.description,
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
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xffb03a57),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        log.quality,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.grey),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SleepPage(
                              //existingLog: log,
                              showTracker: false,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 📊 Weekly bar chart (sleep duration trend)
  Widget _buildWeeklyBarChart(List<SleepLog> logs) {
    final days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    // Calculate daily totals for the past week
    final weeklyHours = List<double>.filled(7, 0.0);

    for (final log in logs) {
      if (log.createdAt.isAfter(weekAgo)) {
        final dayIndex = log.createdAt.weekday % 7;
        weeklyHours[dayIndex] += log.getDurationInHours();
      }
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          height: 220,
          child: BarChart(
            BarChartData(
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      final i = value.toInt();
                      if (i < 0 || i >= days.length)
                        return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          days[i],
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 28),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              barGroups: List.generate(weeklyHours.length, (i) {
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: weeklyHours[i] > 0 ? weeklyHours[i] : 0.1,
                      color: const Color(0xffb03a57),
                      width: 16,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // 🪶 small helper for quick stat cards
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xffb03a57)),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Color(0xffb03a57),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
