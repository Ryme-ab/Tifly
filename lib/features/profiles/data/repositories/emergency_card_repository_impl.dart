import 'package:tifli/features/profiles/data/data_sources/emergency_card_local_data_source.dart';
import 'package:tifli/features/profiles/data/data_sources/emergency_card_remote_data_source.dart';
import 'package:tifli/features/profiles/data/models/emergency_card_model.dart';
import 'package:tifli/features/profiles/domain/entities/emergency_card_entity.dart';

abstract class EmergencyCardRepository {
  Future<EmergencyCard?> getEmergencyCard(String childId);
  Future<void> saveEmergencyCard(EmergencyCard card);
  Future<void> syncPendingCards();
}

class EmergencyCardRepositoryImpl implements EmergencyCardRepository {
  final EmergencyCardLocalDataSource localDataSource;
  final EmergencyCardRemoteDataSource remoteDataSource;

  EmergencyCardRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<EmergencyCard?> getEmergencyCard(String childId) async {
    // 1. Always try local first (Emergency requirement)
    final localCard = await localDataSource.getEmergencyCard(childId);

    // 2. Fetch remote in background or on startup to sync
    // For now, return local instantly. Syncing can happen separately.
    // However, if local is null, try fetching from remote and cache it.
    if (localCard == null) {
      final remoteCard = await remoteDataSource.getEmergencyCard(childId);
      if (remoteCard != null) {
        await localDataSource.saveEmergencyCard(remoteCard);
        return remoteCard;
      }
    }

    return localCard;
  }

  @override
  Future<void> saveEmergencyCard(EmergencyCard card) async {
    final model = EmergencyCardModel.fromEntity(card);
    
    // 1. Save locally immediately with pending status
    // ignore: unused_local_variable
    final pendingModel = EmergencyCardModel(
      id: model.id,
      childId: model.childId,
      fullName: model.fullName,
      dateOfBirth: model.dateOfBirth,
      photoUrl: model.photoUrl,
      bloodType: model.bloodType,
      allergies: model.allergies,
      chronicConditions: model.chronicConditions,
      medications: model.medications,
      medicalContacts: model.medicalContacts,
      emergencyContacts: model.emergencyContacts,
      vaccinationSummary: model.vaccinationSummary,
      medicalNotes: model.medicalNotes,
      healthIdentifiers: model.healthIdentifiers,
      updatedAt: model.updatedAt,
      syncStatus: 'pending',
    );
    // Actually, model.syncStatus is already 'pending' by default in Entity or I can specify it.
    // Let's use a explicit copyWith if I had implemented it, but I'll craft it.
    
    final toSave = EmergencyCardModel(
      id: model.id,
      childId: model.childId,
      fullName: model.fullName,
      dateOfBirth: model.dateOfBirth,
      photoUrl: model.photoUrl,
      bloodType: model.bloodType,
      allergies: model.allergies,
      chronicConditions: model.chronicConditions,
      medications: model.medications,
      medicalContacts: model.medicalContacts,
      emergencyContacts: model.emergencyContacts,
      vaccinationSummary: model.vaccinationSummary,
      medicalNotes: model.medicalNotes,
      healthIdentifiers: model.healthIdentifiers,
      updatedAt: model.updatedAt,
      syncStatus: 'pending',
    );

    await localDataSource.saveEmergencyCard(toSave);

    // 2. Attempt remote sync in background
    try {
      await remoteDataSource.upsertEmergencyCard(toSave);
      await localDataSource.updateSyncStatus(toSave.id, 'synced');
    } catch (e) {
      // Keep as pending for later sync
    }
  }

  @override
  Future<void> syncPendingCards() async {
    final pendingCards = await localDataSource.getPendingSyncCards();
    for (final card in pendingCards) {
      try {
        await remoteDataSource.upsertEmergencyCard(card);
        await localDataSource.updateSyncStatus(card.id, 'synced');
      } catch (e) {
        // Continue to next one, will retry later
      }
    }
  }
}
