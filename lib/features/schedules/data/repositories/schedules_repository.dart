import '../data_sources/schedules_remote_data_source.dart';
import '../models/schedules_model.dart';

class ChecklistRepository {
  final ChecklistDataSource dataSource;

  ChecklistRepository({required this.dataSource});

  Future<List<ChecklistItem>> fetchChecklist(String childId) =>
      dataSource.getChecklists(childId);

  Future<ChecklistItem> addChecklistItem(ChecklistItem item) =>
      dataSource.addItem(item);

  Future<void> updateChecklistItem(ChecklistItem item) =>
      dataSource.updateItem(item);

  Future<void> deleteChecklistItem(String id) => dataSource.deleteItem(id);
}
