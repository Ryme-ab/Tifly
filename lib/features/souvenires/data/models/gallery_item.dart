class GalleryItem {
  final String id;
  final String? childId;
  final String? uploadedBy;
  final String filePath; // a remote storage URL
  final String? mediaType;
  final String? title;
  final DateTime? pictureDate;
  final DateTime createdAt;

  GalleryItem({
    required this.id,
    required this.filePath,
    required this.createdAt,
    this.childId,
    this.uploadedBy,
    this.mediaType,
    this.title,
    this.pictureDate,
  });

  factory GalleryItem.fromJson(Map<String, dynamic> json) {
    return GalleryItem(
      id: json['id'],
      childId: json['child_id'],
      uploadedBy: json['uploaded_by'],
      filePath: json['file_path'],
      mediaType: json['media_type'],
      title: json['title'],
      pictureDate: json['picture_date'] != null
          ? DateTime.parse(json['picture_date'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'child_id': childId,
      'uploaded_by': uploadedBy,
      'file_path': filePath,
      'media_type': mediaType,
      'title': title,
      'picture_date': pictureDate?.toIso8601String(),
    };
  }
}
