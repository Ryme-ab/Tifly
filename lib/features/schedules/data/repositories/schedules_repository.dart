import '../data_sources/schedules_remote_data_source.dart';
import '../models/schedules_model.dart';

class ChecklistRepository {
  final ChecklistDataSource dataSource;

  ChecklistRepository({required this.dataSource});

  Future<List<ChecklistItem>> fetchChecklist(String userId, String childId) =>
      dataSource.getChecklists(userId, childId);

  Future<ChecklistItem> addChecklistItem(ChecklistItem item) =>
      dataSource.addItem(item);

  Future<void> updateChecklistItem(ChecklistItem item, String userId) =>
      dataSource.updateItem(item, userId);

  Future<void> deleteChecklistItem(String id, String userId) => dataSource.deleteItem(id, userId);
}
