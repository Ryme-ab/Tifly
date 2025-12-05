import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:tifli/features/logs/presentation/cubit/growth_logs_cubit.dart';
import 'package:tifli/features/logs/presentation/cubit/growth_logs_state.dart';
import 'package:tifli/features/logs/data/models/growth_logs_model.dart';
import 'package:tifli/features/trackers/presentation/screens/growth_tracker_screen.dart';
import 'package:tifli/widgets/custom_app_bar.dart';
import 'package:tifli/core/config/test_config.dart';

class GrowthLogsScreen extends StatefulWidget {
  const GrowthLogsScreen({super.key});

  @override
  State<GrowthLogsScreen> createState() => _GrowthLogsScreenState();
}

class _GrowthLogsScreenState extends State<GrowthLogsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GrowthLogCubit>().loadLogs();
    });
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

  Widget _logCard(GrowthLog log, BuildContext context) {
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
                      "Growth Log",
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GrowthPage(
                        showTracker: false, // existingLog: log
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _growthChart(List<GrowthLog> logs) {
    if (logs.isEmpty) {
      return Container(
        height: 240,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            "No data for charts yet",
            style: TextStyle(color: Colors.black54),
          ),
        ),
      );
    }

    logs.sort((a, b) => a.date.compareTo(b.date));

    final spotsHeight = <FlSpot>[];
    final spotsWeight = <FlSpot>[];
    final spotsHead = <FlSpot>[];

    // Calculate min/max for each metric separately for better scaling
    double minHeight = double.infinity, maxHeight = double.negativeInfinity;
    double minWeight = double.infinity, maxWeight = double.negativeInfinity;
    double minHead = double.infinity, maxHead = double.negativeInfinity;

    for (int i = 0; i < logs.length; i++) {
      spotsHeight.add(FlSpot(i.toDouble(), logs[i].height));
      spotsWeight.add(FlSpot(i.toDouble(), logs[i].weight));
      spotsHead.add(FlSpot(i.toDouble(), logs[i].headCircumference));

      // Track individual ranges
      if (logs[i].height < minHeight) minHeight = logs[i].height;
      if (logs[i].height > maxHeight) maxHeight = logs[i].height;
      if (logs[i].weight < minWeight) minWeight = logs[i].weight;
      if (logs[i].weight > maxWeight) maxWeight = logs[i].weight;
      if (logs[i].headCircumference < minHead)
        minHead = logs[i].headCircumference;
      if (logs[i].headCircumference > maxHead)
        maxHead = logs[i].headCircumference;
    }

    // Use the overall min/max for unified Y-axis
    final minY = [
      minHeight,
      minWeight,
      minHead,
    ].reduce((a, b) => a < b ? a : b);
    final maxY = [
      maxHeight,
      maxWeight,
      maxHead,
    ].reduce((a, b) => a > b ? a : b);

    // Add 10% padding to Y-axis for better visualization
    final yPadding = (maxY - minY) * 0.1;
    final adjustedMinY = (minY - yPadding).floorToDouble();
    final adjustedMaxY = (maxY + yPadding).ceilToDouble();

    // Calculate optimal interval for Y-axis (aim for 4-6 labels)
    final yRange = adjustedMaxY - adjustedMinY;
    final yInterval = (yRange / 5).ceilToDouble();

    // Determine X-axis interval based on number of data points
    final xInterval = logs.length > 10 ? (logs.length / 5).ceilToDouble() : 1.0;

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Growth Chart",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                "${logs.length} records",
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Legend with better styling
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              _buildLegendItem(
                color: const Color(0xff4A90E2),
                label: "Height (cm)",
                value: logs.isNotEmpty
                    ? logs.last.height.toStringAsFixed(1)
                    : "--",
              ),
              _buildLegendItem(
                color: const Color(0xffE24A90),
                label: "Weight (kg)",
                value: logs.isNotEmpty
                    ? logs.last.weight.toStringAsFixed(1)
                    : "--",
              ),
              _buildLegendItem(
                color: const Color(0xff4AE290),
                label: "Head Circ. (cm)",
                value: logs.isNotEmpty
                    ? logs.last.headCircumference.toStringAsFixed(1)
                    : "--",
              ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: LineChart(
              LineChartData(
                minY: adjustedMinY,
                maxY: adjustedMaxY,
                minX: 0,
                maxX: (logs.length - 1).toDouble(),

                // Grid configuration
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: yInterval,
                  verticalInterval: xInterval,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.15),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.1),
                      strokeWidth: 1,
                      dashArray: [5, 5],
                    );
                  },
                ),

                // Border styling
                borderData: FlBorderData(
                  show: true,
                  border: Border(
                    left: BorderSide(
                      color: Colors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                    bottom: BorderSide(
                      color: Colors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                    right: BorderSide.none,
                    top: BorderSide.none,
                  ),
                ),

                // Axis titles
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),

                  // Bottom axis (dates)
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: xInterval,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < logs.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormat("dd/MM").format(logs[index].date),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black54,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),

                  // Left axis (values)
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: yInterval,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(0),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.black54,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Touch interaction
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    tooltipPadding: const EdgeInsets.all(8),
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final index = spot.x.toInt();
                        if (index >= 0 && index < logs.length) {
                          final log = logs[index];
                          String label = '';
                          String value = '';

                          if (spot.barIndex == 0) {
                            label = 'Height';
                            value = '${log.height.toStringAsFixed(1)} cm';
                          } else if (spot.barIndex == 1) {
                            label = 'Weight';
                            value = '${log.weight.toStringAsFixed(1)} kg';
                          } else {
                            label = 'Head';
                            value =
                                '${log.headCircumference.toStringAsFixed(1)} cm';
                          }

                          return LineTooltipItem(
                            '$label\n$value\n${DateFormat("dd MMM").format(log.date)}',
                            const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                        return null;
                      }).toList();
                    },
                  ),
                  handleBuiltInTouches: true,
                ),

                // Line data
                lineBarsData: [
                  // Height line
                  LineChartBarData(
                    spots: spotsHeight,
                    isCurved: true,
                    color: const Color(0xff4A90E2),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: logs.length <= 10,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: const Color(0xff4A90E2),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(show: false),
                  ),

                  // Weight line
                  LineChartBarData(
                    spots: spotsWeight,
                    isCurved: true,
                    color: const Color(0xffE24A90),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: logs.length <= 10,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: const Color(0xffE24A90),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(show: false),
                  ),

                  // Head circumference line
                  LineChartBarData(
                    spots: spotsHead,
                    isCurved: true,
                    color: const Color(0xff4AE290),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: logs.length <= 10,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: const Color(0xff4AE290),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f4f8),
      appBar: const CustomAppBar(title: "Growth Tracker"),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xffb03a57),
        child: const Icon(Icons.add),
        onPressed: () async {
          final added = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => GrowthPage(showTracker: true)),
          );
          if (added is GrowthLog) {
            context.read<GrowthLogCubit>().addLog(added);
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

              if (state is GrowthLogLoaded) {
                final logs = [...state.logs]
                  ..sort((a, b) => a.date.compareTo(b.date));

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Growth Dashboard",
                            style: TextStyle(
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
                              value: logs.isNotEmpty
                                  ? "${logs.last.height} cm"
                                  : "--",
                              icon: Icons.height,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _summaryCard(
                              label: "Weight",
                              value: logs.isNotEmpty
                                  ? "${logs.last.weight} kg"
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
                        value: logs.isNotEmpty
                            ? "${logs.last.headCircumference} cm"
                            : "--",
                        icon: Icons.circle_outlined,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 20),
                      _growthChart(logs),
                      const SizedBox(height: 20),
                      const Text(
                        "Growth Logs",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...logs.map((log) => _logCard(log, context)),
                    ],
                  ),
                );
              }

              if (state is GrowthLogError) {
                return Center(child: Text("Error: ${state.message}"));
              }

              return const Center(child: Text("No data"));
            },
          ),
        ),
      ),
    );
  }
}

class LegendDot extends StatelessWidget {
  final Color color;
  final String text;

  const LegendDot({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
