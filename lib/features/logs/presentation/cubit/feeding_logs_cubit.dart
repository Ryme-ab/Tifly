import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tifli/features/logs/data/models/logs_model.dart';
import 'package:tifli/features/logs/data/repositories/feeding_logs_repo.dart';
import 'package:tifli/core/state/child_selection_cubit.dart';
import 'feeding_logs_state.dart';

class FeedingLogCubit extends Cubit<FeedingLogState> {
  final FeedingLogRepository repository;
  final SupabaseClient supabase;
  final ChildSelectionCubit childSelectionCubit;

  late final StreamSubscription _childSelectionSubscription;

  FeedingLogCubit({
    required this.repository,
    required this.supabase,
    required this.childSelectionCubit,
  }) : super(FeedingLogInitial()) {
    _childSelectionSubscription = childSelectionCubit.stream.listen((state) {
      if (state is ChildSelected) {
        loadLogs();
      } else if (state is NoChildSelected) {
        emit(FeedingLogInitial());
      }
    });
  }

  Future<void> loadLogs() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      final childState = childSelectionCubit.state;

      if (userId == null || childState is! ChildSelected) {
        emit(FeedingLogError('No user or child selected'));
        return;
      }

      emit(FeedingLogLoading());
      final logs = await repository.getLogs(userId, childState.childId);
      emit(FeedingLogLoaded(logs));
    } catch (e) {
      emit(FeedingLogError(e.toString()));
    }
  }

  Future<void> addLog(FeedingLog log) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await repository.addLog(log);
      await loadLogs();
    } catch (e) {
      emit(FeedingLogError(e.toString()));
    }
  }

  Future<void> updateLog(String id, FeedingLog log) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await repository.updateLog(id, userId, log);
      await loadLogs();
    } catch (e) {
      emit(FeedingLogError(e.toString()));
    }
  }

  Future<void> deleteLog(String id) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await repository.deleteLog(id, userId);
      await loadLogs();
    } catch (e) {
      emit(FeedingLogError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _childSelectionSubscription.cancel();
    return super.close();
  }
}
