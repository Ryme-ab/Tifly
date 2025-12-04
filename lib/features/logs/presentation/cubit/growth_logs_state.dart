import 'package:tifli/features/logs/data/models/growth_logs_model.dart';

abstract class GrowthLogState {}

class GrowthLogInitial extends GrowthLogState {}

class GrowthLogLoading extends GrowthLogState {}

class GrowthLogLoaded extends GrowthLogState {
  final List<GrowthLog> logs;

  GrowthLogLoaded(this.logs);
}

class GrowthLogError extends GrowthLogState {
  final String message;

  GrowthLogError(this.message);
}
