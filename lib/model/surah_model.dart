class Surah {
  final int number;
  final String name;
  final String englishName;
  final String revelationType;
  final int numberOfAyahs;

  Surah({
    required this.number,
    required this.name,
    required this.englishName,
    required this.revelationType,
    required this.numberOfAyahs,
  });

  // تحويل الـ JSON إلى Object
  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'],
      name: json['name'],
      englishName: json['englishName'],
      revelationType: json['revelationType'],
      numberOfAyahs: json['numberOfAyahs'],
    );
  }
}

