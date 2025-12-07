import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tifli/features/logs/data/models/growth_logs_model.dart';
import 'package:tifli/features/logs/data/repositories/growth_logs_repository.dart';
import 'package:tifli/core/state/child_selection_cubit.dart';
import 'growth_logs_state.dart';

class GrowthLogCubit extends Cubit<GrowthLogState> {
  final GrowthLogRepository repository;
  final SupabaseClient supabase;
  final ChildSelectionCubit childSelectionCubit;

  late final StreamSubscription _childSelectionSubscription;

  GrowthLogCubit({
    required this.repository,
    required this.supabase,
    required this.childSelectionCubit,
  }) : super(GrowthLogInitial()) {
    _childSelectionSubscription = childSelectionCubit.stream.listen((state) {
      if (state is ChildSelected) {
        loadLogs();
      } else if (state is NoChildSelected) {
        emit(GrowthLogInitial());
      }
    });
  }

  Future<void> loadLogs() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      final childState = childSelectionCubit.state;

      if (userId == null || childState is! ChildSelected) {
        emit(GrowthLogError('No user or child selected'));
        return;
      }

      emit(GrowthLogLoading());
      final logs = await repository.getLogs(userId, childState.childId);
      emit(GrowthLogLoaded(logs));
    } catch (e) {
      emit(GrowthLogError(e.toString()));
    }
  }

  Future<void> addLog(GrowthLog log) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await repository.addLog(log);
      await loadLogs();
    } catch (e) {
      emit(GrowthLogError(e.toString()));
    }
  }

  Future<void> updateLog(String id, GrowthLog log) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await repository.updateLog(id, userId, log);
      await loadLogs();
    } catch (e) {
      emit(GrowthLogError(e.toString()));
    }
  }

  Future<void> deleteLog(String id) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await repository.deleteLog(id, userId);
      await loadLogs();
    } catch (e) {
      emit(GrowthLogError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _childSelectionSubscription.cancel();
    return super.close();
  }
}
