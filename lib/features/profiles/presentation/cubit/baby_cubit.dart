import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'baby_state.dart';
import '../../data/models/baby_model.dart';
import '../../data/repositories/baby_repo.dart';

class BabyCubit extends Cubit<BabyState> {
  final BabyRepository repository;

  BabyCubit(this.repository) : super(BabyInitial());

  // ✅ FETCH ALL BABIES (FOR YOUR PAGE)
  Future<void> fetchBabies() async {
    emit(BabyLoading());
    try {
      final babies = await repository.getBabies();
      emit(BabyLoaded(babies));
    } catch (e) {
      emit(BabyError(e.toString()));
    }
  }

  // ✅ PICK + UPLOAD IMAGE (WEB + MOBILE)
  Future<void> pickAndUploadImage(Baby baby) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);

      if (picked == null) return;

      if (kIsWeb) {
        // -------- WEB --------
        final bytes = await picked.readAsBytes();
        await repository.uploadProfileImageBytes(
          baby.id!,
          bytes,
          'baby_profiles',
        );

        emit(BabySuccess(baby));
      } else {
        // -------- MOBILE --------
        final filePath = picked.path;

        await repository.uploadProfileImage(baby.id!, filePath);

        emit(BabySuccess(baby));
      }
    } catch (e) {
      emit(BabyError(e.toString()));
    }
  }
}
