class AllahName {
  final int id;
  final String nameAr;
  final String nameEn;
  final String descriptionAr;
  final String descriptionEn;

  AllahName({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.descriptionAr,
    required this.descriptionEn,
  });

  factory AllahName.fromJson(Map<String, dynamic> json) {
    return AllahName(
      id: json['id'],
      nameAr: json['name_ar'],
      nameEn: json['name_en'],
      descriptionAr: json['description_ar'],
      descriptionEn: json['description_en'],
    );
  }
}