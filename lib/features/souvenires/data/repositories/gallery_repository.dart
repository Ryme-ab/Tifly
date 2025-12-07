import '../data_sources/gallery_remote_data_source.dart';
import '../models/gallery_item.dart';
import 'dart:io';

abstract class GalleryRepository {
  Future<List<GalleryItem>> getGallery(String childId);
  Future<GalleryItem> addMemory({
    required String childId,
    required String uploadedBy,
    required String title,
    required DateTime pictureDate,
    required File picture,
  });
  Future<GalleryItem> updateMemory({
    required String id,
    String? title,
    DateTime? pictureDate,
    File? newPicture,
  });
  Future<void> deleteMemory(GalleryItem item);
}

class GalleryRepositoryImpl implements GalleryRepository {
  final GalleryRemoteDataSource remoteDataSource;

  GalleryRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<GalleryItem>> getGallery(String childId) {
    return remoteDataSource.fetchGallery(childId);
  }

  @override
  Future<GalleryItem> addMemory({
    required String childId,
    required String uploadedBy,
    required String title,
    required DateTime pictureDate,
    required File picture,
  }) {
    return remoteDataSource.insertMemory(
      childId: childId,
      uploadedBy: uploadedBy,
      title: title,
      pictureDate: pictureDate,
      imageFile: picture,
    );
  }

  @override
  Future<GalleryItem> updateMemory({
    required String id,
    String? title,
    DateTime? pictureDate,
    File? newPicture,
  }) {
    return remoteDataSource.updateMemory(
      id: id,
      title: title,
      pictureDate: pictureDate,
      newImageFile: newPicture,
    );
  }

  @override
  Future<void> deleteMemory(GalleryItem item) {
    return remoteDataSource.deleteMemory(item);
  }
}
