import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:tifli/core/constants/app_colors.dart';
import 'package:tifli/features/logs/data/models/growth_logs_model.dart';
import 'package:tifli/features/logs/presentation/cubit/growth_logs_cubit.dart';
import 'package:tifli/features/logs/presentation/cubit/growth_logs_state.dart';
import 'package:tifli/l10n/app_localizations.dart';

import 'package:tifli/features/trackers/presentation/screens/growth_tracker_screen.dart';
import 'package:tifli/widgets/custom_app_bar.dart';

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
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          GrowthPage(showTracker: false, existingLog: log),
                    ),
                  );
                  if (updated is GrowthLog) {
                    context.read<GrowthLogCubit>().updateLog(log.id, updated);
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
          final added = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const GrowthPage(showTracker: true),
            ),
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
              if (state is GrowthLogError) {
                return Center(child: Text("${l10n.error}: ${state.message}"));
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
                      const Text(
                        "Growth Logs",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...logs.map((log) => _logCard(log)),
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
