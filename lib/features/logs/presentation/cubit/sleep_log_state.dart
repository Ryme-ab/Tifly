import 'package:tifli/features/logs/data/models/sleep_log_model.dart';

abstract class SleepLogState {}

class SleepLogInitial extends SleepLogState {}

class SleepLogLoading extends SleepLogState {}

class SleepLogLoaded extends SleepLogState {
  final List<SleepLog> logs;

  SleepLogLoaded(this.logs);
}

class SleepLogError extends SleepLogState {
  final String message;

  SleepLogError(this.message);
}
