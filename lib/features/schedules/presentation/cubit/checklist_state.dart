part of 'schedules_cubit.dart';

abstract class ChecklistState {}

class ChecklistInitial extends ChecklistState {}

class ChecklistLoading extends ChecklistState {}

class ChecklistLoaded extends ChecklistState {
  final List<ChecklistItem> items;
  ChecklistLoaded(this.items);
}

class ChecklistError extends ChecklistState {
  final String message;
  ChecklistError(this.message);
}
