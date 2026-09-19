class WallpaperModel {
  final int id;
  final String? title;
  final String imageUrl;
  final String category;
  final int downloadsCount;

  WallpaperModel({
    required this.id,
    this.title,
    required this.imageUrl,
    required this.category,
    required this.downloadsCount,
  });

  factory WallpaperModel.fromJson(Map<String, dynamic> json) {
    return WallpaperModel(
      id: json['id'],
      title: json['title'],
      imageUrl: json['image_url'],
      category: json['category'] ?? 'general',
      downloadsCount: json['downloads_count'] ?? 0,
    );
  }
}