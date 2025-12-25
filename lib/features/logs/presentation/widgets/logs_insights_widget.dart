import 'package:flutter/material.dart';
import 'package:tifli/features/logs/data/models/baby_log_model.dart';

class LogsInsights extends StatelessWidget {
  final List<BabyLog> logs;

  const LogsInsights({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final feedingCount = logs.where((log) => log.type == LogType.feeding).length;
    final sleepCount = logs.where((log) => log.type == LogType.sleep).length;
    final growthCount = logs.where((log) => log.type == LogType.growth).length;
    final medicationCount =
        logs.where((log) => log.type == LogType.medication).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Logs Insights",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _InsightCard(label: "Feeds", value: feedingCount.toString(), color: Colors.blue),
            _InsightCard(label: "Sleep", value: sleepCount.toString(), color: Colors.green),
            _InsightCard(label: "Growth", value: growthCount.toString(), color: Colors.purple),
            _InsightCard(label: "Medications", value: medicationCount.toString(), color: Colors.red),
          ],
        ),
        const SizedBox(height: 20),
        // Chart placeholder
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[850] : Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(child: Text("Chart goes here")),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InsightCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
