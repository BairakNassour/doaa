import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:doaa/model/PrayerModel.dart';
import 'package:geocoding/geocoding.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrayerController extends ChangeNotifier {
  PrayerModel? prayerModel;
  bool isLoading = true;
  String userCity = "جاري التحديد...";
  String nextPrayerName = "جاري الحساب...";
  String remainingTime = "00:00:00";
  Timer? _timer;

  // مفاتيح الكاش
  final String _cacheKey = "cached_prayer_data";
  final String _cityKey = "cached_city_name";

  Future<Position> _determinePosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) throw 'Permission Denied';
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<void> init() async {
    await fetchPrayerData();
    _startCountdown();
  }

  Future<void> fetchPrayerData() async {
    isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();

    try {
      // محاولة تحديد الموقع وجلب البيانات من الإنترنت
      Position position = await _determinePosition().timeout(const Duration(seconds: 5));
      
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude, 
        position.longitude, 
      );
      
      String detectedCity = placemarks.first.locality ?? "موقع غير معروف";

      final url = 'https://api.aladhan.com/v1/timings?latitude=${position.latitude}&longitude=${position.longitude}&method=4';
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        // حفظ البيانات في الكاش عند النجاح
        await prefs.setString(_cacheKey, response.body);
        await prefs.setString(_cityKey, detectedCity);

        _setupData(response.body, detectedCity);
      } else {
        _loadLocalData(prefs);
      }
    } catch (e) {
      print("خطأ في الشبكة أو الموقع، يتم جلب البيانات المحلية: $e");
      _loadLocalData(prefs);
    }

    isLoading = false;
    notifyListeners();
  }

  // دالة جلب البيانات من الجهاز
  void _loadLocalData(SharedPreferences prefs) {
    String? cachedJson = prefs.getString(_cacheKey);
    String? cachedCity = prefs.getString(_cityKey);

    if (cachedJson != null && cachedCity != null) {
      _setupData(cachedJson, cachedCity);
    } else {
      userCity = "لا يوجد اتصال";
    }
  }

  // دالة وسيطة لضبط البيانات وحساب المواعيد
  void _setupData(String jsonBody, String city) {
    final Map<String, dynamic> jsonData = json.decode(jsonBody);
    prayerModel = PrayerModel.fromJson(jsonData, city);
    userCity = city;
    _calculateRemainingEvents();
    _calculateNextPrayer();
  }

  void _startCountdown() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateNextPrayer();
    });
  }

  // --- بقية الدوال (حساب رمضان، الحج، والوقت المتبقي) تبقى كما هي دون تغيير ---
  
  String daysToRamadan = "..";
  String daysToHajj = "..";

  void _calculateRemainingEvents() {
    if (prayerModel == null) return;
    int currentMonth = prayerModel!.hijriMonth;
    int currentDay = prayerModel!.hijriDay;

    if (currentMonth == 9) {
      daysToRamadan = "نحن في رمضان";
    } else {
      int monthsLeft = (9 - currentMonth - 1);
      if (monthsLeft < 0) monthsLeft += 12;
      int totalDays = (monthsLeft * 30) + (30 - currentDay);
      daysToRamadan = "$totalDays يوم";
    }

    int targetHajjMonth = 12;
    int targetHajjDay = 10;
    int hMonthsLeft = (targetHajjMonth - currentMonth - 1);
    if (hMonthsLeft < 0) hMonthsLeft += 12;
    int totalHajjDays = (hMonthsLeft * 30) + (30 - currentDay) + targetHajjDay;
    daysToHajj = "$totalHajjDays يوم";
    notifyListeners();
  }

  void _calculateNextPrayer() {
    if (prayerModel == null) return;
    final now = DateTime.now();
    final timings = prayerModel!.timings;

    Map<String, String> prayerCheckList = {
      "الفجر": timings['Fajr']!,
      "الظهر": timings['Dhuhr']!,
      "العصر": timings['Asr']!,
      "المغرب": timings['Maghrib']!,
      "العشاء": timings['Isha']!,
    };

    DateTime? nextTime;
    String? nextName;

    for (var entry in prayerCheckList.entries) {
      DateTime pDate = _parseTime(entry.value);
      if (pDate.isAfter(now)) {
        nextTime = pDate;
        nextName = entry.key;
        break;
      }
    }

    if (nextTime == null) {
      nextTime = _parseTime(timings['Fajr']!).add(const Duration(days: 1));
      nextName = "الفجر";
    }

    nextPrayerName = nextName!;
    Duration diff = nextTime.difference(now);
    remainingTime = _formatDuration(diff);
    notifyListeners(); 
  }

  DateTime _parseTime(String timeStr) {
    final now = DateTime.now();
    final List<String> parts = timeStr.split(':');
    return DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(d.inHours)}:${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}