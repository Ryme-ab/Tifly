import 'package:bloc/bloc.dart';
import '../../data/models/growth.dart';
import '../../data/repositories/growth_repository.dart';

class GrowthCubit extends Cubit<List<GrowthLog>> {
  final GrowthRepository repository;

  GrowthCubit(this.repository) : super([]);

  Future<void> loadGrowthLogs(String childId) async {
    final logs = await repository.getGrowthLogs(childId);
    emit(logs);
  }

  Future<void> addGrowthLog({
    required String childId,
    required DateTime date,
    required double height,
    required double weight,
    required double headCircumference,
    String? notes,
  }) async {
    try {
      // Check for duplicate
      final isDuplicate = await repository.checkDuplicate(
        childId: childId,
        date: date,
        height: height,
        weight: weight,
        headCircumference: headCircumference,
      );

      if (isDuplicate) {
        throw Exception("This growth log already exists!");
      }

      // Create new growth log
      final growthLog = GrowthLog(
        id: '',
        childId: childId,
        date: date,
        height: height,
        weight: weight,
        headCircumference: headCircumference,
        notes: notes,
        createdAt: DateTime.now(),
      );

      await repository.addGrowth(growthLog);
      await loadGrowthLogs(childId);
    } catch (e) {
      print("Error adding growth log: $e");
      rethrow;
    }
  }

  Future<void> deleteGrowth(String id, String childId) async {
    await repository.deleteGrowth(id);
    await loadGrowthLogs(childId);
  }
}