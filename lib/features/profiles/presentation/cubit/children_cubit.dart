import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/child_model.dart';
import '../../data/repositories/children_repository.dart';

part 'children_state.dart';

class ChildrenCubit extends Cubit<ChildrenState> {
  final ChildrenRepository repository;

  // Use a single positional argument
  ChildrenCubit(this.repository) : super(ChildrenInitial());

  Future<void> loadChildren(String parentId) async {
    emit(ChildrenLoading());

    try {
      final children = await repository.getChildren(parentId);
      emit(ChildrenLoaded(children));
    } catch (e) {
      emit(ChildrenError("Failed to load children"));
    }
  }

  Future<void> deleteChild(String childId) async {
    try {
      await repository.deleteChild(childId);
    } catch (e) {
      emit(ChildrenError("Failed to delete child"));
      rethrow;
    }
  }

  Future<void> updateChild({
    required String childId,
    required String firstName,
    required DateTime birthDate,
    String? gender,
    String? notes,
    dynamic imageFile,
  }) async {
    try {
      await repository.updateChild(
        childId: childId,
        firstName: firstName,
        birthDate: birthDate,
        gender: gender,
        notes: notes,
        imageFile: imageFile,
      );
    } catch (e) {
      emit(ChildrenError("Failed to update child"));
      rethrow;
    }
  }
}
