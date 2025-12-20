import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tifli/core/state/child_selection_cubit.dart';
import 'package:tifli/features/profiles/domain/entities/emergency_card_entity.dart';
import 'package:tifli/features/profiles/domain/usecases/get_emergency_card_usecase.dart';
import 'package:tifli/features/profiles/domain/usecases/save_emergency_card_usecase.dart';

// --- States ---
abstract class EmergencyCardState extends Equatable {
  const EmergencyCardState();
  @override
  List<Object?> get props => [];
}

class EmergencyCardInitial extends EmergencyCardState {}

class EmergencyCardLoading extends EmergencyCardState {}

class EmergencyCardLoaded extends EmergencyCardState {
  final EmergencyCard? card;
  const EmergencyCardLoaded(this.card);
  @override
  List<Object?> get props => [card];
}

class EmergencyCardError extends EmergencyCardState {
  final String message;
  const EmergencyCardError(this.message);
  @override
  List<Object?> get props => [message];
}

// --- Cubit ---
class EmergencyCardCubit extends Cubit<EmergencyCardState> {
  final GetEmergencyCardUseCase getUseCase;
  final SaveEmergencyCardUseCase saveUseCase;
  final ChildSelectionCubit childSelectionCubit;

  EmergencyCardCubit({
    required this.getUseCase,
    required this.saveUseCase,
    required this.childSelectionCubit,
  }) : super(EmergencyCardInitial()) {
    // Listen to child selection changes
    childSelectionCubit.stream.listen((selectionState) {
      if (selectionState is ChildSelected) {
        loadEmergencyCard(selectionState.childId);
      }
    });
    
    // Initial load if child already selected
    final currentId = childSelectionCubit.selectedChildId;
    if (currentId != null) {
      loadEmergencyCard(currentId);
    }
  }

  Future<void> loadEmergencyCard(String childId) async {
    emit(EmergencyCardLoading());
    try {
      final card = await getUseCase(childId);
      emit(EmergencyCardLoaded(card));
    } catch (e) {
      emit(EmergencyCardError(e.toString()));
    }
  }

  Future<void> saveEmergencyCard(EmergencyCard card) async {
    emit(EmergencyCardLoading());
    try {
      await saveUseCase(card);
      emit(EmergencyCardLoaded(card));
    } catch (e) {
      emit(EmergencyCardError(e.toString()));
    }
  }
}
