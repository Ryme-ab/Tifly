import 'package:tifli/features/profiles/data/repositories/emergency_card_repository_impl.dart';
import 'package:tifli/features/profiles/domain/entities/emergency_card_entity.dart';

class GetEmergencyCardUseCase {
  final EmergencyCardRepository repository;

  GetEmergencyCardUseCase(this.repository);

  Future<EmergencyCard?> call(String childId) {
    return repository.getEmergencyCard(childId);
  }
}
