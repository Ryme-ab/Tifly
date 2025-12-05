import 'package:tifli/features/logs/data/models/statistics_model.dart';

abstract class StatisticsState {}

class StatisticsInitial extends StatisticsState {}

class StatisticsLoading extends StatisticsState {}

class StatisticsLoaded extends StatisticsState {
  final Statistics statistics;

  StatisticsLoaded(this.statistics);
}

class StatisticsError extends StatisticsState {
  final String message;

  StatisticsError(this.message);
}
