import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tifli/core/config/test_config.dart';
import 'package:tifli/features/logs/presentation/cubit/feeding_logs_cubit.dart';
import 'package:tifli/features/logs/presentation/cubit/sleep_log_cubit.dart';
import 'package:tifli/features/logs/presentation/cubit/medication_log_cubit.dart';

/// Auto-loads test data for all cubits when test mode is enabled
///
/// Wrap your app with this widget to automatically fetch data
/// for the test child ID on startup.
///
/// IMPORTANT: Remove this widget when moving to production!
class TestDataLoader extends StatefulWidget {
  final Widget child;

  const TestDataLoader({super.key, required this.child});

  @override
  State<TestDataLoader> createState() => _TestDataLoaderState();
}

class _TestDataLoaderState extends State<TestDataLoader> {
  @override
  void initState() {
    super.initState();

    // Only load test data if test mode is enabled
    if (TestConfig.enableTestMode) {
      // Use addPostFrameCallback to ensure context is available
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadAllTestData();
      });
    }
  }

  void _loadAllTestData() {
    // All cubits now auto-load based on ChildSelectionCubit
    // Just trigger the loads without parameters

    // Load Feeding Logs
    context.read<FeedingLogCubit>().loadLogs();

    // Load Baby Logs (all types) - may need updating later
    // context.read<BabyLogsCubit>().loadAllLogs(); // Commented out for now

    // Load Sleep Logs
    context.read<SleepLogCubit>().loadLogs();

    // Load Medication Logs
    context.read<MedicationLogCubit>().loadMedicines();

    // Load Statistics - may need updating later
    // context.read<StatisticsCubit>().loadStatistics(); // Commented out for now

    print('🧪 TEST MODE: Auto-loaded data from ChildSelectionCubit');
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
