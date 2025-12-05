import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'child_selection_state.dart';

class ChildSelectionCubit extends Cubit<ChildSelectionState> {
  static const String _selectedChildIdKey = 'selected_child_id';
  static const String _selectedChildNameKey = 'selected_child_name';

  ChildSelectionCubit() : super(ChildSelectionInitial()) {
    loadPersistedChild();
  }

  /// Load the persisted child selection from local storage
  Future<void> loadPersistedChild() async {
    try {
      emit(ChildSelectionLoading());
      
      final prefs = await SharedPreferences.getInstance();
      final childId = prefs.getString(_selectedChildIdKey);
      final childName = prefs.getString(_selectedChildNameKey);

      if (childId != null && childName != null) {
        emit(ChildSelected(childId: childId, childName: childName));
      } else {
        emit(NoChildSelected());
      }
    } catch (e) {
      emit(ChildSelectionError('Failed to load child selection: $e'));
    }
  }

  /// Select a child and persist the selection
  Future<void> selectChild(String childId, String childName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_selectedChildIdKey, childId);
      await prefs.setString(_selectedChildNameKey, childName);

      emit(ChildSelected(childId: childId, childName: childName));
    } catch (e) {
      emit(ChildSelectionError('Failed to save child selection: $e'));
    }
  }

  /// Clear the child selection
  Future<void> clearSelection() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_selectedChildIdKey);
      await prefs.remove(_selectedChildNameKey);

      emit(NoChildSelected());
    } catch (e) {
      emit(ChildSelectionError('Failed to clear child selection: $e'));
    }
  }

  /// Get the currently selected child ID (if any)
  String? get selectedChildId {
    final currentState = state;
    if (currentState is ChildSelected) {
      return currentState.childId;
    }
    return null;
  }

  /// Get the currently selected child name (if any)
  String? get selectedChildName {
    final currentState = state;
    if (currentState is ChildSelected) {
      return currentState.childName;
    }
    return null;
  }
}
