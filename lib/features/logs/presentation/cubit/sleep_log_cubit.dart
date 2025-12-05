import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tifli/features/logs/data/models/sleep_log_model.dart';
import 'package:tifli/features/logs/data/repositories/sleep_log_repository.dart';
import 'package:tifli/core/state/child_selection_cubit.dart';
import 'sleep_log_state.dart';

class SleepLogCubit extends Cubit<SleepLogState> {
  final SleepLogRepository repository;
  final SupabaseClient supabase;
  final ChildSelectionCubit childSelectionCubit;
  
  late final StreamSubscription _childSelectionSubscription;

  SleepLogCubit({
    required this.repository,
    required this.supabase,
    required this.childSelectionCubit,
  }) : super(SleepLogInitial()) {
    _childSelectionSubscription = childSelectionCubit.stream.listen((state) {
      if (state is ChildSelected) {
        loadLogs();
      } else if (state is NoChildSelected) {
        emit(SleepLogInitial());
      }
    });
  }

  Future<void> loadLogs() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      final childState = childSelectionCubit.state;
      
      if (userId == null || childState is! ChildSelected) {
        emit(SleepLogError('No user or child selected'));
        return;
      }

      emit(SleepLogLoading());
      final logs = await repository.getLogs(userId, childState.childId);
      emit(SleepLogLoaded(logs));
    } catch (e) {
      emit(SleepLogError(e.toString()));
    }
  }

  Future<void> addLog(SleepLog log) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');
      
      await repository.addLog(log);
      await loadLogs();
    } catch (e) {
      emit(SleepLogError(e.toString()));
    }
  }

  Future<void> updateLog(String id, SleepLog log) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');
      
      await repository.updateLog(id, userId, log);
      await loadLogs();
    } catch (e) {
      emit(SleepLogError(e.toString()));
    }
  }

  Future<void> deleteLog(String id) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');
      
      await repository.deleteLog(id, userId);
      await loadLogs();
    } catch (e) {
      emit(SleepLogError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _childSelectionSubscription.cancel();
    return super.close();
  }
}
