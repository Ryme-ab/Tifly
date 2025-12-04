import 'package:tifli/features/logs/data/data_sources/sleep_log_data_source.dart';
import 'package:tifli/features/logs/data/models/sleep_log_model.dart';

class SleepLogRepository {
  final SleepLogDataSource dataSource;

  SleepLogRepository({required this.dataSource});

  Future<List<SleepLog>> getLogs(String childId) => dataSource.getLogs(childId);

  Future<SleepLog> addLog(SleepLog log) => dataSource.addLog(log);

  Future<SleepLog> updateLog(String id, SleepLog log) =>
      dataSource.updateLog(id, log);

  Future<void> deleteLog(String id) => dataSource.deleteLog(id);
}
