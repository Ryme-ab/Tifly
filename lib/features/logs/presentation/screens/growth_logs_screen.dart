import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:tifli/core/constants/app_colors.dart';
import 'package:tifli/features/logs/data/models/growth_logs_model.dart';
import 'package:tifli/features/logs/presentation/cubit/growth_logs_cubit.dart';
import 'package:tifli/features/logs/presentation/cubit/growth_logs_state.dart';
import 'package:tifli/l10n/app_localizations.dart';

import 'package:tifli/features/trackers/presentation/screens/growth_tracker_screen.dart';
import 'package:tifli/widgets/custom_app_bar.dart';

enum DateFilterOption {
  today,
  last7Days,
  thisMonth,
}

class GrowthLogsScreen extends StatefulWidget {
  const GrowthLogsScreen({super.key});

  @override
  State<GrowthLogsScreen> createState() => _GrowthLogsScreenState();
}

class _GrowthLogsScreenState extends State<GrowthLogsScreen> {
  DateFilterOption selectedFilter = DateFilterOption.last7Days;
  bool showAllLogs = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GrowthLogCubit>().loadLogs();
    });
  }

  // Filter logs based on selected date range
  List<GrowthLog> _filterLogs(List<GrowthLog> logs) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    switch (selectedFilter) {
      case DateFilterOption.today:
        return logs.where((log) {
          final logDate = DateTime(
            log.date.year,
            log.date.month,
            log.date.day,
          );
          return logDate == today;
        }).toList();

      case DateFilterOption.last7Days:
        final cutoff = today.subtract(const Duration(days: 7));
        return logs.where((log) => 
          log.date.isAfter(cutoff) && 
          log.date.isBefore(tomorrow)
        ).toList();

      case DateFilterOption.thisMonth:
        return logs.where((log) {
          return log.date.year == now.year &&
              log.date.month == now.month;
        }).toList();
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
    }
  }

  Widget _summaryCard({
    required String label,
    required String value,
    required IconData icon,
    Color color = Colors.pink,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _logCard(GrowthLog log) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Dismissible(
        key: Key(log.id),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(
            color: Colors.redAccent,
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.only(right: 20),
          alignment: Alignment.centerRight,
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (_) {
          context.read<GrowthLogCubit>().deleteLog(log.id);
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.monitor_weight,
                size: 30,
                color: Color(0xffb03a57),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.growthLog,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat("dd MMM, hh:mm a").format(log.date),
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.grey),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          GrowthPage(showTracker: false, existingLog: log),
                    ),
                  );
                  // Reload logs after returning
                  if (mounted) {
                    context.read<GrowthLogCubit>().loadLogs();
                  }
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: CustomAppBar(title: l10n.growthTracker),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xffb03a57),
        child: const Icon(Icons.add),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const GrowthPage(showTracker: true),
            ),
          );
          // Reload logs after returning
          if (mounted) {
            context.read<GrowthLogCubit>().loadLogs();
          }
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<GrowthLogCubit, GrowthLogState>(
            builder: (context, state) {
              if (state is GrowthLogLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is GrowthLogError) {
                return Center(child: Text("${l10n.error}: ${state.message}"));
              }
              if (state is GrowthLogLoaded) {
                final allLogs = [...state.logs]
                  ..sort((a, b) => a.date.compareTo(b.date));
                
                // Apply date filter
                final filteredLogs = _filterLogs(allLogs)
                  ..sort((a, b) => b.date.compareTo(a.date));
                
                // Determine how many logs to show
                final logsToShow = showAllLogs ? filteredLogs : (filteredLogs.length > 5 ? filteredLogs.take(5).toList() : filteredLogs);
                final hasMoreLogs = filteredLogs.length > 5;
                
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.growthDashboard,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                CircleAvatar(
                                  backgroundImage: const AssetImage(
                                    "assets/profile.jpg",
                                  ),
                                  backgroundColor: Colors.grey[200],
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: _summaryCard(
                                    label: "Height",
                                    value: allLogs.isNotEmpty
                                        ? "${allLogs.last.height} cm"
                                        : "--",
                                    icon: Icons.height,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _summaryCard(
                                    label: "Weight",
                                    value: allLogs.isNotEmpty
                                        ? "${allLogs.last.weight} kg"
                                        : "--",
                                    icon: Icons.monitor_weight,
                                    color: Colors.pink,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _summaryCard(
                              label: "Head Circumference",
                              value: allLogs.isNotEmpty
                                  ? "${allLogs.last.headCircumference} cm"
                                  : "--",
                              icon: Icons.circle_outlined,
                              color: Colors.green,
                            ),
                            const SizedBox(height: 24),
                            
                            // ✨ Filter Chips
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
                                      onSelected: (selected) => setState(() {
                                        selectedFilter = option;
                                        showAllLogs = false; // Reset show more when filter changes
                                      }),
                                      selectedColor: const Color(0xffb03a57),
                                      backgroundColor: Colors.grey[200],
                                      labelStyle: TextStyle(
                                        color: isSelected ? Colors.white : Colors.black87,
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                      ),
                                      elevation: isSelected ? 2 : 0,
                                      pressElevation: 4,
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            const Text(
                              "Growth Logs",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                      
                      // Growth Logs List
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            if (filteredLogs.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.monitor_weight,
                                        size: 64,
                                        color: Colors.grey[300],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        "No growth logs yet",
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else ...[
                              ...logsToShow.map((log) => _logCard(log)),
                              
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
                                        showAllLogs ? Icons.expand_less : Icons.expand_more,
                                        color: const Color(0xffb03a57),
                                      ),
                                      label: Text(
                                        showAllLogs ? "Show Less" : "Show More (${filteredLogs.length - 5} more)",
                                        style: const TextStyle(
                                          color: Color(0xffb03a57),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                      
                      // Growth Charts Section (AFTER logs)
                      if (filteredLogs.length > 1) ...[
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              const Text(
                                "Growth Analytics",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _GrowthChartsSection(logs: filteredLogs),
                            ],
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 100),
                    ],
                  ),
                );
              }
              return const Center(child: Text("No data"));
            },
          ),
        ),
      ),
    );
  }
}

// ===== GROWTH CHARTS SECTION =====

class _GrowthChartsSection extends StatelessWidget {
  final List<GrowthLog> logs;

  const _GrowthChartsSection({required this.logs});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        // Weight Progress Chart
        _ChartCard(
          title: "Weight Progress",
          isDark: isDark,
          child: SizedBox(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, top: 16),
              child: _buildWeightChart(isDark),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Height Progress Chart
        _ChartCard(
          title: "Height Progress",
          isDark: isDark,
          child: SizedBox(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, top: 16),
              child: _buildHeightChart(isDark),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Head Circumference Chart
        _ChartCard(
          title: "Head Circumference",
          isDark: isDark,
          child: SizedBox(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, top: 16),
              child: _buildHeadCircumferenceChart(isDark),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Combined Growth Chart
        _ChartCard(
          title: "All Measurements",
          isDark: isDark,
          child: SizedBox(
            height: 250,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, top: 16),
              child: _buildCombinedChart(isDark),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeightChart(bool isDark) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, _) => Text(
                '${value.toInt()} kg',
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
                if (index >= 0 && index < logs.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('MMM d').format(logs[index].date),
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
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              logs.length,
              (i) => FlSpot(i.toDouble(), logs[i].weight),
            ),
            isCurved: true,
            color: Colors.pink,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 4,
                color: Colors.pink,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.pink.withOpacity(0.15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeightChart(bool isDark) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 5,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, _) => Text(
                '${value.toInt()} cm',
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
                if (index >= 0 && index < logs.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('MMM d').format(logs[index].date),
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
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              logs.length,
              (i) => FlSpot(i.toDouble(), logs[i].height),
            ),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 4,
                color: Colors.blue,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeadCircumferenceChart(bool isDark) {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 2,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, _) => Text(
                '${value.toInt()} cm',
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
                if (index >= 0 && index < logs.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('MMM d').format(logs[index].date),
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
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              logs.length,
              (i) => FlSpot(i.toDouble(), logs[i].headCircumference),
            ),
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 4,
                color: Colors.green,
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.green.withOpacity(0.15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCombinedChart(bool isDark) {
    // Normalize data for better visualization
    final maxWeight = logs.map((e) => e.weight).reduce((a, b) => a > b ? a : b);
    final maxHeight = logs.map((e) => e.height).reduce((a, b) => a > b ? a : b);
    final maxHead = logs.map((e) => e.headCircumference).reduce((a, b) => a > b ? a : b);
    
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 35,
              getTitlesWidget: (value, _) => Text(
                '${(value * 100).toInt()}%',
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
                if (index >= 0 && index < logs.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('MMM d').format(logs[index].date),
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
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          // Weight line (normalized)
          LineChartBarData(
            spots: List.generate(
              logs.length,
              (i) => FlSpot(i.toDouble(), logs[i].weight / maxWeight),
            ),
            isCurved: true,
            color: Colors.pink,
            barWidth: 2.5,
            dotData: FlDotData(show: false),
          ),
          // Height line (normalized)
          LineChartBarData(
            spots: List.generate(
              logs.length,
              (i) => FlSpot(i.toDouble(), logs[i].height / maxHeight),
            ),
            isCurved: true,
            color: Colors.blue,
            barWidth: 2.5,
            dotData: FlDotData(show: false),
          ),
          // Head circumference line (normalized)
          LineChartBarData(
            spots: List.generate(
              logs.length,
              (i) => FlSpot(i.toDouble(), logs[i].headCircumference / maxHead),
            ),
            isCurved: true,
            color: Colors.green,
            barWidth: 2.5,
            dotData: FlDotData(show: false),
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