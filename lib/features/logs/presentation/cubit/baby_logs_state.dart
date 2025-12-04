import 'package:tifli/features/logs/data/models/baby_log_model.dart';

abstract class BabyLogsState {}

class BabyLogsInitial extends BabyLogsState {}

class BabyLogsLoading extends BabyLogsState {}

class BabyLogsLoaded extends BabyLogsState {
  final List<BabyLog> logs;

  BabyLogsLoaded(this.logs);
}

class BabyLogsError extends BabyLogsState {
  final String message;

  BabyLogsError(this.message);
}
