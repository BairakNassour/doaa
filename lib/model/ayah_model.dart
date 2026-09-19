class Ayah {
  final int number;
  final int numberInSurah;
  final String text;
  final int juz;
  final int page;
  final int hizbQuarter;
  final bool sajda;
  int? surahNumber; // أضفنا هذا الحقل ليتم تعبئته لاحقاً

  Ayah({
    required this.number,
    required this.numberInSurah,
    required this.text,
    required this.juz,
    required this.page,
    required this.hizbQuarter,
    required this.sajda,
    this.surahNumber, 
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      number: json['number'],
      numberInSurah: json['numberInSurah'],
      text: json['text'],
      juz: json['juz'],
      page: json['page'],
      hizbQuarter: json['hizbQuarter'],
      sajda: json['sajda'] is bool ? json['sajda'] : false,
    );
  }
}
class AyahAudio {
  final int numberInSurah;
  final String text;
  final String audioUrl;

  AyahAudio({required this.numberInSurah, required this.text, required this.audioUrl});

  factory AyahAudio.fromJson(Map<String, dynamic> json) {
    return AyahAudio(
      numberInSurah: json['numberInSurah'],
      text: json['text'],
      audioUrl: json['audio'],
    );
  }
}