part of 'child_selection_cubit.dart';

abstract class ChildSelectionState {}

class ChildSelectionInitial extends ChildSelectionState {}

class ChildSelectionLoading extends ChildSelectionState {}

class ChildSelected extends ChildSelectionState {
  final String childId;
  final String childName;

  ChildSelected({
    required this.childId,
    required this.childName,
  });
}

class NoChildSelected extends ChildSelectionState {}

class ChildSelectionError extends ChildSelectionState {
  final String message;

  ChildSelectionError(this.message);
}
