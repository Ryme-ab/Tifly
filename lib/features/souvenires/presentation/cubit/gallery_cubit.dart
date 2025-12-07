import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/gallery_item.dart';
import '../../data/repositories/gallery_repository.dart';
import 'dart:io';

class GalleryState {
  final bool loading;
  final String? error;
  final List<GalleryItem> items;

  GalleryState({required this.loading, required this.items, this.error});

  factory GalleryState.initial() => GalleryState(loading: false, items: []);
}

class GalleryCubit extends Cubit<GalleryState> {
  final GalleryRepository repo;

  GalleryCubit(this.repo) : super(GalleryState.initial());

  Future<void> loadGallery(String childId) async {
    emit(GalleryState(loading: true, items: state.items));

    try {
      final items = await repo.getGallery(childId);
      emit(GalleryState(loading: false, items: items));
    } catch (e) {
      emit(GalleryState(loading: false, items: [], error: e.toString()));
    }
  }

  Future<void> addMemory({
    required String childId,
    required String uploadedBy,
    required String title,
    required DateTime pictureDate,
    required File picture,
  }) async {
    emit(GalleryState(loading: true, items: state.items));

    try {
      print('=== CUBIT: ADDING MEMORY ===');
      print('Child ID: $childId');
      print('Uploaded by: $uploadedBy');
      print('Title: $title');

      final newItem = await repo.addMemory(
        childId: childId,
        uploadedBy: uploadedBy,
        title: title,
        pictureDate: pictureDate,
        picture: picture,
      );

      print('=== CUBIT: MEMORY ADDED SUCCESSFULLY ===');
      print('New item ID: ${newItem.id}');

      final updated = [...state.items, newItem];
      emit(GalleryState(loading: false, items: updated));
    } catch (e) {
      print('=== CUBIT: ERROR ADDING MEMORY ===');
      print('Error: $e');
      print('Stack: ${StackTrace.current}');
      emit(
        GalleryState(
          loading: false,
          items: state.items,
          error: 'Failed to add memory: $e',
        ),
      );
    }
  }

  Future<void> updateMemory({
    required String id,
    String? title,
    DateTime? pictureDate,
    File? newPicture,
  }) async {
    emit(GalleryState(loading: true, items: state.items));
    try {
      final updatedItem = await repo.updateMemory(
        id: id,
        title: title,
        pictureDate: pictureDate,
        newPicture: newPicture,
      );
      final updatedList = state.items
          .map((e) => e.id == id ? updatedItem : e)
          .toList();
      emit(GalleryState(loading: false, items: updatedList));
    } catch (e) {
      emit(
        GalleryState(
          loading: false,
          items: state.items,
          error: 'Failed to update memory: $e',
        ),
      );
    }
  }

  Future<void> deleteMemory(GalleryItem item) async {
    emit(GalleryState(loading: true, items: state.items));
    try {
      await repo.deleteMemory(item);
      final filtered = state.items.where((e) => e.id != item.id).toList();
      emit(GalleryState(loading: false, items: filtered));
    } catch (e) {
      emit(
        GalleryState(
          loading: false,
          items: state.items,
          error: 'Failed to delete memory: $e',
        ),
      );
    }
  }
}
