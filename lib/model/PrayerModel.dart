class PrayerModel {
  final Map<String, String> timings;
  final String hijriDate;
  final String gregorianDate;
  final String city;
  final int hijriDay;
  final int hijriMonth;

  PrayerModel({
    required this.timings,
    required this.hijriDate,
    required this.gregorianDate,
    required this.city,
    required this.hijriDay,
    required this.hijriMonth,
  });

factory PrayerModel.fromJson(Map<String, dynamic> json, String userCity) {
    var data = json['data'];
    var hijri = data['date']['hijri'];
    var greg = data['date']['gregorian'];

    // خارطة لتحويل الأشهر الميلادية للعربي
    const monthAr = {
      'January': 'يناير', 'February': 'فبراير', 'March': 'مارس',
      'April': 'أبريل', 'May': 'مايو', 'June': 'يونيو',
      'July': 'يوليو', 'August': 'أغسطس', 'September': 'سبتمبر',
      'October': 'أكتوبر', 'November': 'نوفمبر', 'December': 'ديسمبر'
    };

    String monthNameEn = greg['month']['en'];
    String monthNameAr = monthAr[monthNameEn] ?? monthNameEn; // إذا ما لقى الاسم بيعرضه متل ما هو

    return PrayerModel(
      timings: Map<String, String>.from(data['timings']),
      
      // التاريخ الهجري (عربي جاهز من الـ API)
      hijriDate: "${hijri['day']} ${hijri['month']['ar']} ${hijri['year']}",
      
      // التاريخ الميلادي (اليوم العربي من الهجري + رقم اليوم + الشهر من الخارطة)
      gregorianDate: "${hijri['weekday']['ar']}، ${greg['day']} $monthNameAr",
      
      city: userCity, 
      hijriDay: int.parse(hijri['day'].toString()),
      hijriMonth: int.parse(hijri['month']['number'].toString()),
    );
}
}