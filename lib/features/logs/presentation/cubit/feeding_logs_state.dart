import 'package:tifli/features/logs/data/models/logs_model.dart';

abstract class FeedingLogState {}

class FeedingLogInitial extends FeedingLogState {}

class FeedingLogLoading extends FeedingLogState {}

class FeedingLogLoaded extends FeedingLogState {
  final List<FeedingLog> logs;

  FeedingLogLoaded(this.logs);
}

class FeedingLogError extends FeedingLogState {
  final String message;

  FeedingLogError(this.message);
}
