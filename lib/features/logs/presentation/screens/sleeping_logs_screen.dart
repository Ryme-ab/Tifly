import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:tifli/core/constants/app_colors.dart';
import 'package:tifli/features/logs/data/models/sleep_log_model.dart';
import 'package:tifli/features/logs/presentation/cubit/sleep_log_cubit.dart';
import 'package:tifli/features/logs/presentation/cubit/sleep_log_state.dart';
import 'package:tifli/l10n/app_localizations.dart';
import 'package:tifli/core/state/child_selection_cubit.dart';

import 'package:tifli/features/trackers/presentation/screens/sleep_tracker_screen.dart';
import 'package:tifli/widgets/custom_app_bar.dart';

enum DateFilterOption {
  today,
  last7Days,
  thisMonth,
  
}

class SleepingLogsScreen extends StatefulWidget {
  const SleepingLogsScreen({super.key});

  @override
  State<SleepingLogsScreen> createState() => _SleepingLogsScreenState();
}

class _SleepingLogsScreenState extends State<SleepingLogsScreen> {
  DateFilterOption selectedFilter = DateFilterOption.last7Days;
  bool showAllLogs = false; // Show more/less toggle

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SleepLogCubit>().loadLogs();
    });
  }

  // Filter logs based on selected date range
  List<SleepLog> _filterLogs(List<SleepLog> logs) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    switch (selectedFilter) {
      case DateFilterOption.today:
        return logs.where((log) {
          final logDate = DateTime(
            log.startTime.year,
            log.startTime.month,
            log.startTime.day,
          );
          return logDate == today;
        }).toList();

      case DateFilterOption.last7Days:
        final cutoff = today.subtract(const Duration(days: 7));
        // Only show logs from past 7 days, exclude future dates
        return logs.where((log) => 
          log.startTime.isAfter(cutoff) && 
          log.startTime.isBefore(tomorrow)
        ).toList();

      case DateFilterOption.thisMonth:
        // Show entire current month (including future dates in this month)
        return logs.where((log) {
          return log.startTime.year == now.year &&
              log.startTime.month == now.month;
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

  Widget _buildSleepCard(SleepLog log) {
    final l10n = AppLocalizations.of(context)!;
    
    // Quality-based colors
    final qualityColor = switch (log.quality.toLowerCase()) {
      "good" || "excellent" => const Color(0xFF4CAF50),
      "fair" => const Color(0xFFFFA726),
      "poor" || "not_good" => const Color(0xFFEF5350),
      _ => Colors.grey,
    };

    final cardColor = switch (log.quality.toLowerCase()) {
      "good" || "excellent" => const Color(0xFFF1F8F4),
      "fair" => const Color(0xFFFFF8E1),
      "poor" || "not_good" => const Color(0xFFFFEBEE),
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
            color: const Color(0xFFEF5350),
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EAF6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.nightlight_round,
                  color: Color(0xFF5C6BC0),
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
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      "${DateFormat('hh:mm a').format(log.startTime)} - ${DateFormat('hh:mm a').format(log.endTime)}",
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    log.getFormattedDuration(),
                    style: const TextStyle(
                      color: Color(0xFF5C6BC0),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: qualityColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _capitalizeFirst(log.quality),
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
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          SleepPage(showTracker: false, existingEntry: log),
                    ),
                  );
                  // Reload logs after returning from edit screen
                  if (mounted) {
                    context.read<SleepLogCubit>().loadLogs();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _exportSleepLogsPDF(BuildContext context) async {
    final state = context.read<SleepLogCubit>().state;
    if (state is! SleepLogLoaded) return;

    final logs = _filterLogs(state.logs);
    if (logs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No sleep logs to export')),
      );
      return;
    }

    try {
      final pdf = pw.Document();
      final childState = context.read<ChildSelectionCubit>().state;
      String childName = 'Baby';
      if (childState is ChildSelected) {
        childName = childState.childName;
      }

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Sleep Logs Report', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.green700)),
                  pw.SizedBox(height: 8),
                  pw.Text('Child: $childName', style: pw.TextStyle(fontSize: 16, color: PdfColors.grey800)),
                  pw.Text('Generated: ${DateFormat('MMMM dd, yyyy hh:mm a').format(DateTime.now())}', style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600)),
                  pw.Divider(thickness: 2),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Total Logs: ${logs.length}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 16),
            pw.Table.fromTextArray(
              headers: ['Start Time', 'End Time', 'Duration', 'Quality', 'Notes'],
              data: logs.map((log) {
                final duration = log.endTime.difference(log.startTime);
                final hours = duration.inHours;
                final minutes = duration.inMinutes % 60;
                return [
                  DateFormat('MMM dd, hh:mm a').format(log.startTime),
                  DateFormat('MMM dd, hh:mm a').format(log.endTime),
                  '${hours}h ${minutes}m',
                  log.quality,
                  log.description.isEmpty ? '-' : log.description,
                ];
              }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.green500),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.all(8),
            ),
          ],
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => pdf.save(),
        name: 'sleep_logs_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF exported successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting PDF: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: CustomAppBar(
        title: l10n.sleepingTracker,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Color(0xFF4FB783)),
            onPressed: () => _exportSleepLogsPDF(context),
            tooltip: 'Export PDF',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF5C6BC0),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SleepPage(showTracker: true),
            ),
          );
          // Reload logs after returning from add screen
          if (mounted) {
            context.read<SleepLogCubit>().loadLogs();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: BlocBuilder<SleepLogCubit, SleepLogState>(
          builder: (context, state) {
            if (state is SleepLogLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is SleepLogError) {
              return Center(child: Text("${l10n.error}: ${state.message}"));
            }
            if (state is SleepLogLoaded) {
              // Apply date filter
              final filteredLogs = _filterLogs(state.logs)
                ..sort((a, b) => b.startTime.compareTo(a.startTime));

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ✨ Cute Filter Chips (matching feeding screen)
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
                            onSelected: (selected) => setState(() => selectedFilter = option),
                            selectedColor: const Color(0xFF5C6BC0),
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
                  const SizedBox(height: 20),

                  // Sleep Log List
                  if (filteredLogs.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.nightlight_round,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.noSleepLogsYet,
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
                    // Logs with Show More/Less
                    ...(() {
                      final logsToShow = showAllLogs 
                          ? filteredLogs 
                          : (filteredLogs.length > 5 ? filteredLogs.take(5).toList() : filteredLogs);
                      final hasMoreLogs = filteredLogs.length > 5;
                      
                      return [
                        ...logsToShow.map((log) => _buildSleepCard(log)),
                        
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
                                  color: const Color(0xFF7E57C2),
                                ),
                                label: Text(
                                  showAllLogs 
                                      ? "Show Less" 
                                      : "Show More (${filteredLogs.length - 5} more)",
                                  style: const TextStyle(
                                    color: Color(0xFF7E57C2),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ];
                    })(),
                  ],

                  const SizedBox(height: 20),

                  // Statistics Section
                  if (filteredLogs.isNotEmpty) ..._buildStatistics(filteredLogs, isDark),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  List<Widget> _buildStatistics(List<SleepLog> logs, bool isDark) {
    // Calculate statistics
    final totalMinutes = logs.fold<int>(
      0,
      (sum, log) => sum + log.endTime.difference(log.startTime).inMinutes,
    );
    final avgMinutes = (totalMinutes / logs.length).round();
    final avgHours = avgMinutes ~/ 60;
    final avgMins = avgMinutes % 60;

    // Quality distribution
    final qualityCounts = <String, int>{};
    for (var log in logs) {
      qualityCounts[log.quality] = (qualityCounts[log.quality] ?? 0) + 1;
    }
    final mostCommonQuality = qualityCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // Duration per day
    final durationPerDay = <String, int>{};
    for (var log in logs) {
      final key = DateFormat('M/d').format(log.startTime);
      final minutes = log.endTime.difference(log.startTime).inMinutes;
      durationPerDay[key] = (durationPerDay[key] ?? 0) + minutes;
    }

    // Sleep start times
    final sleepsByHour = <int, int>{};
    for (var log in logs) {
      final hour = log.startTime.hour;
      sleepsByHour[hour] = (sleepsByHour[hour] ?? 0) + 1;
    }

    return [
      // Statistics Header
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Sleep Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          Text(
            _getFilterLabel(selectedFilter),
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),

      // Stats Grid - 3 cards in one row
      GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.95,
        children: [
          _StatCard(
            icon: Icons.star,
            title: 'Most Common',
            value: _capitalizeFirst(mostCommonQuality),
            color: _getQualityColor(mostCommonQuality),
            isDark: isDark,
          ),
          _StatCard(
            icon: Icons.nights_stay,
            title: 'Total Sleep',
            value: '${(totalMinutes / 60).toStringAsFixed(1)}h',
            color: const Color(0xFF7E57C2),
            isDark: isDark,
          ),
          _StatCard(
            icon: Icons.history,
            title: 'Sleep Logs',
            value: logs.length.toString(),
            color: const Color(0xFF26A69A),
            isDark: isDark,
          ),
        ],
      ),
      const SizedBox(height: 20),

      // Duration Chart
      if (durationPerDay.length > 1) ...[
        _ChartCard(
          title: 'Sleep Duration Over Time',
          isDark: isDark,
          child: SizedBox(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, top: 16),
              child: _buildDurationLineChart(durationPerDay, isDark),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],

      // Quality Distribution
      if (qualityCounts.length > 1) ...[
        _ChartCard(
          title: 'Sleep Quality Distribution',
          isDark: isDark,
          child: SizedBox(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, top: 16),
              child: _buildQualityPieChart(qualityCounts, isDark),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],

      // Sleep Times Pattern
      if (sleepsByHour.isNotEmpty) ...[
        _ChartCard(
          title: 'Sleep Start Times Pattern',
          isDark: isDark,
          child: SizedBox(
            height: 200,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, top: 16),
              child: _buildSleepTimesChart(sleepsByHour, isDark),
            ),
          ),
        ),
      ],
    ];
  }

  Widget _buildDurationLineChart(Map<String, int> durationPerDay, bool isDark) {
    final sortedDays = durationPerDay.keys.toList()..sort();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 60,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              getTitlesWidget: (value, _) => Text(
                '${(value / 60).toStringAsFixed(0)}h',
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
                if (index >= 0 && index < sortedDays.length && (index % 2 == 0 || sortedDays.length <= 7)) {
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
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              sortedDays.length,
              (i) => FlSpot(i.toDouble(), durationPerDay[sortedDays[i]]!.toDouble()),
            ),
            isCurved: true,
            color: const Color(0xFF5C6BC0),
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                radius: 4,
                color: const Color(0xFF5C6BC0),
                strokeWidth: 2,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF5C6BC0).withOpacity(0.15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualityPieChart(Map<String, int> qualityCounts, bool isDark) {
    final total = qualityCounts.values.reduce((a, b) => a + b);
    
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: qualityCounts.entries.map((entry) {
          final percentage = (entry.value / total * 100).toStringAsFixed(1);
          return PieChartSectionData(
            value: entry.value.toDouble(),
            title: '$percentage%',
            color: _getQualityColor(entry.key),
            radius: 70,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            badgeWidget: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                _capitalizeFirst(entry.key),
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ),
            badgePositionPercentageOffset: 1.3,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSleepTimesChart(Map<int, int> sleepsByHour, bool isDark) {
    final blocks = <String, int>{
      'Night\n(9PM-12AM)': 0,
      'Late Night\n(12AM-3AM)': 0,
      'Early Morning\n(3AM-6AM)': 0,
      'Morning\n(6AM-9AM)': 0,
      'Day\n(9AM-9PM)': 0,
    };

    sleepsByHour.forEach((hour, count) {
      if (hour >= 21 || hour < 0) {
        blocks['Night\n(9PM-12AM)'] = blocks['Night\n(9PM-12AM)']! + count;
      } else if (hour >= 0 && hour < 3) {
        blocks['Late Night\n(12AM-3AM)'] = blocks['Late Night\n(12AM-3AM)']! + count;
      } else if (hour >= 3 && hour < 6) {
        blocks['Early Morning\n(3AM-6AM)'] = blocks['Early Morning\n(3AM-6AM)']! + count;
      } else if (hour >= 6 && hour < 9) {
        blocks['Morning\n(6AM-9AM)'] = blocks['Morning\n(6AM-9AM)']! + count;
      } else {
        blocks['Day\n(9AM-9PM)'] = blocks['Day\n(9AM-9PM)']! + count;
      }
    });

    final entries = blocks.entries.toList();
    final maxValue = entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

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
                color: const Color(0xFF7E57C2),
                width: 35,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
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
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Color _getQualityColor(String quality) {
    switch (quality.toLowerCase()) {
      case 'good':
      case 'excellent':
        return const Color(0xFF4CAF50);
      case 'fair':
        return const Color(0xFFFFA726);
      case 'poor':
      case 'not_good':
        return const Color(0xFFEF5350);
      default:
        return Colors.grey;
    }
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    if (text == 'not_good') return 'Not Good';
    if (text == 'excellent') return 'Excellent';
    return text[0].toUpperCase() + text.substring(1);
  }
}

// ===== HELPER WIDGETS =====

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