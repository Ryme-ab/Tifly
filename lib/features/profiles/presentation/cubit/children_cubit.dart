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
}
