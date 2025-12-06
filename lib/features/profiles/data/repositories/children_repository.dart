import '../data_sources/children_data_source.dart';
import '../models/child_model.dart';

class ChildrenRepository {
  final ChildrenDataSource dataSource;

  ChildrenRepository({required ChildrenDataSource datasource})
    : dataSource = datasource;

  Future<List<ChildModel>> getChildren(String parentId) {
    return dataSource.fetchChildren(parentId);
  }

  Future<void> deleteChild(String childId) {
    return dataSource.deleteChild(childId);
  }

  Future<void> updateChild({
    required String childId,
    required String firstName,
    required DateTime birthDate,
    String? gender,
    String? notes,
    dynamic imageFile,
  }) {
    return dataSource.updateChild(
      childId: childId,
      firstName: firstName,
      birthDate: birthDate,
      gender: gender,
      notes: notes,
      imageFile: imageFile,
    );
  }
}
