import 'package:tifli/features/logs/data/data_sources/baby_logs_data_source.dart';
import 'package:tifli/features/logs/data/models/baby_log_model.dart';

class BabyLogsRepository {
  final BabyLogsDataSource dataSource;

  BabyLogsRepository({required this.dataSource});

  // Use the filtered logs method
  Future<List<BabyLog>> getAllLogs(String childId) =>
      dataSource.getFilteredLogs(childId: childId);

  Future<List<BabyLog>> getLogsByType(String childId, LogType type) =>
      dataSource.getFilteredLogs(childId: childId, type: type);

  Future<List<BabyLog>> getLogsByDate(
          String childId, DateTime date, LogType? type) =>
      dataSource.getFilteredLogs(childId: childId, date: date, type: type);

  Future<List<BabyLog>> getLogsByTime(
          String childId, String time, LogType? type) =>
      dataSource.getFilteredLogs(childId: childId, time: time, type: type);
}
