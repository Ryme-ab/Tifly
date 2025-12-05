import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tifli/features/schedules/data/models/schedules_model.dart';
import 'package:tifli/features/schedules/data/repositories/schedules_repository.dart';
import 'package:tifli/core/state/child_selection_cubit.dart';
import 'checklist_state.dart';

class ChecklistCubit extends Cubit<ChecklistState> {
  final ChecklistRepository repository;
  final SupabaseClient supabase;
  final ChildSelectionCubit childSelectionCubit;
  
  late final StreamSubscription _childSelectionSubscription;

  ChecklistCubit({
    required this.repository,
    required this.supabase,
    required this.childSelectionCubit,
  }) : super(ChecklistInitial()) {
    _childSelectionSubscription = childSelectionCubit.stream.listen((state) {
      if (state is ChildSelected) {
        loadChecklist();
      } else if (state is NoChildSelected) {
        emit(ChecklistInitial());
      }
    });
  }

  Future<void> loadChecklist() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      final childState = childSelectionCubit.state;
      
      if (userId == null || childState is! ChildSelected) {
        emit(ChecklistError('No user or child selected'));
        return;
      }

      emit(ChecklistLoading());
      final items = await repository.fetchChecklist(userId, childState.childId);
      emit(ChecklistLoaded(items));
    } catch (e) {
      emit(ChecklistError(e.toString()));
    }
  }

  Future<void> addItem(ChecklistItem item) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');
      
      await repository.addChecklistItem(item);
      await loadChecklist();
    } catch (e) {
      emit(ChecklistError(e.toString()));
    }
  }

  Future<void> toggleItem(ChecklistItem item) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');
      
      final updatedItem = item.copyWith(done: !item.done);
      await repository.updateChecklistItem(updatedItem, userId);
      await loadChecklist();
    } catch (e) {
      emit(ChecklistError(e.toString()));
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');
      
      await repository.deleteChecklistItem(id, userId);
      await loadChecklist();
    } catch (e) {
      emit(ChecklistError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _childSelectionSubscription.cancel();
    return super.close();
  }
}
