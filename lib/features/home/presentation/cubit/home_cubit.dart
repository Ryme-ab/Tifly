import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/home_models.dart';
import '../../data/repositories/home_repository.dart';

abstract class HomeState {}
class HomeInitial extends HomeState {}
class HomeLoading extends HomeState {}
class HomeLoaded extends HomeState {
  final HomeData data;
  HomeLoaded(this.data);
}
class HomeError extends HomeState {
  final String message;
  HomeError(this.message);
}

class HomeCubit extends Cubit<HomeState> {
  final HomeRepository repository;
  HomeCubit({required this.repository}) : super(HomeInitial());

  Future<void> load({String? parentId}) async {
    emit(HomeLoading());
    try {
      final data = await repository.getHomeDataForCurrentUser(parentId: parentId);
      emit(HomeLoaded(data));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }

  Future<void> refresh({String? parentId}) async {
    await load(parentId: parentId);
  }

  Future<void> loadForChild(String childId, {String? parentId}) async {
    emit(HomeLoading());
    try {
      final data = await repository.getHomeDataForChild(childId, parentId: parentId);
      emit(HomeLoaded(data));
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}