import 'dart:convert';
import 'package:doaa/model/ayah_model.dart';
import 'package:doaa/model/surah_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class QuranController {
  static const String _baseUrl = "https://api.alquran.cloud/v1";
  
  final String _surahListKey = "cached_surah_list";
  final String _surahDetailKeyPrefix = "cached_surah_";
  final String _surahAudioKeyPrefix = "cached_audio_";
  
  // متغير لمنع تشغيل عملية التكييش أكثر من مرة في نفس الوقت
  static bool _isCachingInProgress = false;

  Future<List<Surah>> fetchSurahList() async {
    final prefs = await SharedPreferences.getInstance();
    
    String? cachedData = prefs.getString(_surahListKey);
    if (cachedData != null) {
      // إذا وجدنا القائمة، نعيدها ونبدأ بتكييش المحتوى في الخلفية
      List<Surah> surahs = _parseSurahList(cachedData);
      _startBackgroundCaching(surahs); 
      return surahs;
    }

    try {
      final response = await http.get(Uri.parse("$_baseUrl/surah")).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        await prefs.setString(_surahListKey, response.body);
        List<Surah> surahs = _parseSurahList(response.body);
        _startBackgroundCaching(surahs);
        return surahs;
      }
    } catch (e) {
      print("Error fetching surah list: $e");
    }
    
    throw Exception("لا توجد بيانات مخزنة ويرجى الاتصال بالإنترنت.");
  }

  Future<List<Ayah>> fetchSurahAyahs(int surahNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final String cacheKey = "$_surahDetailKeyPrefix$surahNumber";

    // 1. الأولوية للكاش
    String? cachedData = prefs.getString(cacheKey);
    if (cachedData != null) {
      return _parseAyahs(cachedData);
    }

    // 2. تحميل فوري للسورة المطلوبة
    try {
      final response = await http.get(Uri.parse("$_baseUrl/surah/$surahNumber")).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        await prefs.setString(cacheKey, response.body);
        return _parseAyahs(response.body);
      }
    } catch (e) {
      print("Network error for Surah $surahNumber: $e");
    }

    throw Exception("يرجى الاتصال بالإنترنت لتحميل السورة لأول مرة");
  }

  /// وظيفة تكييش القرآن كاملاً في الخلفية
  Future<void> _startBackgroundCaching(List<Surah> surahs) async {
    if (_isCachingInProgress) return; // منع التكرار
    _isCachingInProgress = true;

    final prefs = await SharedPreferences.getInstance();

    // تشغيل حلقة التكييش بعيداً عن الـ Main Thread (UI)
    Future.microtask(() async {
      print("بدء عملية تكييش القرآن كاملاً في الخلفية...");
      
      for (var surah in surahs) {
        final String cacheKey = "$_surahDetailKeyPrefix${surah.number}";
        
        // إذا السورة غير موجودة، قم بتحميلها
        if (!prefs.containsKey(cacheKey)) {
          try {
            final response = await http.get(Uri.parse("$_baseUrl/surah/${surah.number}"));
            if (response.statusCode == 200) {
              await prefs.setString(cacheKey, response.body);
              print("تم تكييش سورة: ${surah.name}");
              // تأخير بسيط جداً لضمان عدم استهلاك موارد الشبكة بالكامل
              await Future.delayed(const Duration(milliseconds: 500));
            }
          } catch (e) {
            print("خطأ أثناء تكييش سورة ${surah.name}: $e");
            // في حال حدوث خطأ، نتوقف مؤقتاً ونكمل الباقي لاحقاً
            break; 
          }
        }
      }
      _isCachingInProgress = false;
      print("انتهت عملية تكييش القرآن.");
    });
  }

  // --- بقية الدوال (Audio & Parsing) كما هي في كودك ---

 /// جلب الصوت بناءً على رقم السورة ومعرّف القارئ المختار
  Future<List<AyahAudio>> fetchSurahAudio(int surahNumber) async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. جلب القارئ المختار من الكاش، وإذا لم يوجد نضع العفاسي كافتراضي
    String selectedReciter = prefs.getString('selected_reciter_id') ?? 'ar.alafasy';
    
    // 2. الكاش الآن يجب أن يحتوي على رقم السورة + معرف القارئ (لأن كل قارئ له ملفاته الصوتية المنفصلة)
    final String cacheKey = "${_surahAudioKeyPrefix}${surahNumber}_$selectedReciter";
    
    String? cachedData = prefs.getString(cacheKey);
    if (cachedData != null) return _parseAudio(cachedData);

    try {
      // 3. استدعاء الرابط ديناميكياً باستخدام متغير القارئ المختار 👇
      final response = await http.get(
        Uri.parse("$_baseUrl/surah/$surahNumber/$selectedReciter")
      ).timeout(const Duration(seconds: 15));
      
      if (response.statusCode == 200) {
        await prefs.setString(cacheKey, response.body);
        return _parseAudio(response.body);
      }
    } catch (e) { 
      print("Audio error for reciter $selectedReciter: $e"); 
    }
    throw Exception("الروابط الصوتية غير متوفرة لهذا القارئ.");
  }

  /// دالة جديدة لتحديث القارئ المختار عندما يقوم المستخدم بتغييره من الواجهة
  Future<void> updateSelectedReciter(String reciterIdentifier) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_reciter_id', reciterIdentifier);
    print("تم حفظ القارئ الجديد بنجاح: $reciterIdentifier");
  }

  List<Surah> _parseSurahList(String jsonString) {
    final Map<String, dynamic> decodedData = json.decode(jsonString);
    final List<dynamic> surahsJson = decodedData['data'];
    return surahsJson.map((json) => Surah.fromJson(json)).toList();
  }

List<Ayah> _parseAyahs(String jsonString) {
    final data = json.decode(jsonString);
    int surahNum = data['data']['number']; // استخراج رقم السورة من الـ JSON
    List ayahsJson = data['data']['ayahs'];
    
    return ayahsJson.map((a) {
      Ayah ayah = Ayah.fromJson(a);
      ayah.surahNumber = surahNum; // حقن رقم السورة هنا
      return ayah;
    }).toList();
  }

  List<AyahAudio> _parseAudio(String jsonString) {
    final data = json.decode(jsonString);
    List ayahsJson = data['data']['ayahs'];
    return ayahsJson.map((a) => AyahAudio.fromJson(a)).toList();
  }
  // أضف هذه الدالة داخل كلاس QuranController في ملفه
Future<List<Ayah>> fetchMultipleSurahs(List<int> surahNumbers) async {
  List<Ayah> allAyahs = [];
  for (int num in surahNumbers) {
    if (num < 1 || num > 114) continue;
    try {
      final ayahs = await fetchSurahAyahs(num);
      allAyahs.addAll(ayahs);
    } catch (e) {
      print("Error fetching surah $num: $e");
    }
  }
  return allAyahs;
}
}