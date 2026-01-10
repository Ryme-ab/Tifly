import 'package:tifli/features/profiles/data/repositories/emergency_card_repository_impl.dart';
import 'package:tifli/features/profiles/domain/entities/emergency_card_entity.dart';

class SaveEmergencyCardUseCase {
  final EmergencyCardRepository repository;

  SaveEmergencyCardUseCase(this.repository);

  Future<void> call(EmergencyCard card) {
    return repository.saveEmergencyCard(card);
  }
}
