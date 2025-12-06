import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:tifli/features/logs/data/models/sleep_log_model.dart';
import 'package:tifli/features/logs/presentation/cubit/sleep_log_cubit.dart';
import 'package:tifli/features/logs/presentation/cubit/sleep_log_state.dart';

import 'package:tifli/features/trackers/presentation/screens/sleep_tracker_screen.dart';
import 'package:tifli/widgets/custom_app_bar.dart';

class SleepingLogsScreen extends StatefulWidget {
  const SleepingLogsScreen({super.key});

  @override
  State<SleepingLogsScreen> createState() => _SleepingLogsScreenState();
}

class _SleepingLogsScreenState extends State<SleepingLogsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SleepLogCubit>().loadLogs();
    });
  }

  Widget _buildSleepCard(SleepLog log) {
    final color = switch (log.quality.toLowerCase()) {
      "good" => const Color(0xffe0f7fa),
      "fair" => const Color(0xfffff9c4),
      "poor" => const Color(0xffffebee),
      _ => Colors.white,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: Key(log.id.isEmpty ? log.createdAt.millisecondsSinceEpoch.toString() : log.id),
        direction: DismissDirection.endToStart,
        background: Container(
          decoration: BoxDecoration(color: const Color(0xffb03a57), borderRadius: BorderRadius.circular(12)),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        onDismissed: (_) {
          if (log.id.isNotEmpty) context.read<SleepLogCubit>().deleteLog(log.id);
        },
        child: Container(
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(height: 44, width: 44, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.nightlight_round, color: Color(0xffb03a57))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(DateFormat('MMM d, yyyy').format(log.startTime), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("Duration: ${log.getFormattedDuration()}", style: const TextStyle(color: Colors.pinkAccent)),
                    if (log.description.isNotEmpty)
                      Text(log.description, style: const TextStyle(color: Colors.black54, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.grey),
                onPressed: () async {
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SleepPage(showTracker: false, existingLog: log)),
                  );
                  if (updated is SleepLog) context.read<SleepLogCubit>().updateLog(log.id, updated);
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
    return Scaffold(
      backgroundColor: const Color(0xfff5f4f8),
      appBar: const CustomAppBar(title: 'Sleeping Tracker'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xffb03a57),
        onPressed: () async {
          final added = await Navigator.push(context, MaterialPageRoute(builder: (_) => const SleepPage(showTracker: true)));
          if (added is SleepLog) context.read<SleepLogCubit>().addLog(added);
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<SleepLogCubit, SleepLogState>(
            builder: (context, state) {
              if (state is SleepLogLoading) return const Center(child: CircularProgressIndicator());
              if (state is SleepLogError) return Center(child: Text("Error: ${state.message}"));
              if (state is SleepLogLoaded) {
                final logs = state.logs..sort((a, b) => a.startTime.compareTo(b.startTime));
                return ListView(
                  children: [
                    const Text("Sleep Logs", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                    const SizedBox(height: 16),
                    if (logs.isEmpty)
                      const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text('No sleep logs yet')))
                    else
                      ...logs.map((log) => _buildSleepCard(log)),
                  ],
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
