import 'dart:convert';
import 'package:doaa/model/user_progress_model.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doaa/component/general_url.dart';
import 'package:home_widget/home_widget.dart'; 
import 'package:flutter/foundation.dart';

class ProgressController {
  // مفاتيح الكاش المحلي
  final String _cacheStatsKey = "cached_user_stats_all";
  
  // اسم الـ Provider في أندرويد
  final String androidWidgetName = 'AppWidgetProvider';

  // دالة جلب التوكن
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // --- 1. دالة تحديث الـ Widget الخارجي (تم إضافة وسام ولون الخلفية) ---
  Future<void> _updateHomeScreenWidget({
    String? rank, 
    int? stars, 
    String? lastSurah, 
    String? badge, 
    String? bgColor
  }) async {
    try {
      if (stars != null) await HomeWidget.saveWidgetData<int>('total_stars', stars);
      if (rank != null) await HomeWidget.saveWidgetData<String>('user_rank', rank);
      if (lastSurah != null) await HomeWidget.saveWidgetData<String>('last_surah', lastSurah);
      
      // إضافات جديدة للويدجت
      if (badge != null) await HomeWidget.saveWidgetData<String>('widget_badge_name', badge);
      if (bgColor != null) await HomeWidget.saveWidgetData<String>('widget_bg_color', bgColor);

      await HomeWidget.updateWidget(
        name: androidWidgetName,
        androidName: androidWidgetName,
      );
      debugPrint("✅ تم تحديث الويدجت بنجاح");
    } catch (e) {
      debugPrint("❌ خطأ في تحديث الويدجت: $e");
    }
  }

  // --- دوال مساعدة جديدة للمنطق المطلوب ---
  
  String _calculateBadge(int total) {
    if (total >= 1000) return "نور الهداية";
    if (total >= 500) return "المجتهد";
    if (total >= 100) return "المثابر";
    return "وسام البداية";
  }

  String _calculateBgColor(DateTime? lastActivity) {
    if (lastActivity == null) return "#0C261F";
    final diff = DateTime.now().difference(lastActivity).inHours;
    if (diff < 12) return "#0C261F"; // نشط (أخضر)
    if (diff < 24) return "#1B3A32"; // خامل قليلاً
    if (diff < 48) return "#2C2C2C"; // متوقف (رمادي)
    return "#3E1F1F"; // منقطع (بني محمر)
  }

  // --- 2. إرسال تقدم جديد للسيرفر ---
  Future<bool> updateRemoteProgress(String category, Map<String, dynamic> details) async {
    try {
      final token = await _getToken();
      if (token == null) return false;

      final response = await http.post(
        Uri.parse("$general_url/update-progress"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'category': category,
          'details': details,
        }),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        // نحدث الإحصائيات فوراً ليعكس الويدجت التغيير
        await getAllStats();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Network Error in updateRemoteProgress: $e");
      return false;
    }
  }

  // --- 3. جلب كافة الإحصائيات ---
  Future<List<UserProgressModel>> getAllStats() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final token = await _getToken();
      if (token == null) return [];

      final response = await http.get(
        Uri.parse("$general_url/user-stats"),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 8));
      print(response.body);
      if (response.statusCode == 200) {
        return _processAndReturnStats(response.body);
      }
    } catch (e) {
      debugPrint("Offline Mode: تحميل من الكاش");
    }

    String? localData = prefs.getString(_cacheStatsKey);
    return localData != null ? _processAndReturnStats(localData) : [];
  }

  // --- 4. معالجة البيانات وتحديث الويدجت (التعديل الأساسي هنا) ---
 Future<List<UserProgressModel>> _processAndReturnStats(String rawJson) async {
  final Map<String, dynamic> decodedData = jsonDecode(rawJson);
  final prefs = await SharedPreferences.getInstance();
  
  // 1. حفظ البيانات الخام في الكاش المحلي
  await prefs.setString(_cacheStatsKey, rawJson);

  // 2. استخراج السجلات وتحويلها لموديلات
  final List data = decodedData['all_records'] ?? [];
  final List<UserProgressModel> models = data.map((item) => UserProgressModel.fromJson(item)).toList();

  // --- ⚠️ التعديل الجوهري: ترتيب القائمة من الأحدث للأقدم ---
  if (models.isNotEmpty) {
    models.sort((a, b) {
      // جلب التاريخ من تفاصيل السجل، وإذا لم يوجد نضع تاريخاً قديماً جداً للفرز
      DateTime dateA = DateTime.tryParse(a.details['timestamp']?.toString() ?? "") ?? DateTime(2000);
      DateTime dateB = DateTime.tryParse(b.details['timestamp']?.toString() ?? "") ?? DateTime(2000);
      return dateB.compareTo(dateA); // ترتيب تنازلي (الأحدث في البداية)
    });
  }

  // 3. حساب إجمالي الطاعات (عدد السجلات الكلي)
  int totalDeeds = models.length;

  // 4. حساب الاستمرارية والرتبة
  int streak = await updateAndGetStreak();
  String rank = "🔥: $streak يوم";

  // 5. حساب اسم الوسام
  String badge = _calculateBadge(totalDeeds);

  // 6. تحديد لون الخلفية بناءً على آخر طاعة (بعدما ضمنا أنها أول عنصر بالترتيب)
  DateTime? lastDate;
  if (models.isNotEmpty) {
    lastDate = DateTime.tryParse(models.first.details['timestamp']?.toString() ?? "");
  }
  
  // استدعاء دالة الألوان (ستعطي الأخضر الآن لأن الفرق بين "الآن" و "lastDate" أصبح دقيقاً)
  String bgColor = _calculateBgColor(lastDate);

  // 7. إرسال البيانات المحدثة للويدجت
  await _updateHomeScreenWidget(
    rank: rank,
    stars: totalDeeds, 
    badge: badge,
    bgColor: bgColor,
  );

  return models;
}

  // --- 5. جلب تقدم قسم معين ---
  Future<Map<String, dynamic>?> getRemoteProgress(String category) async {
    try {
      final token = await _getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse("$general_url/user-stats"), 
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 8));
     
      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);
        final List stats = decodedData['stats'] ?? [];
        return _findCategoryInList(stats, category);
      }
    } catch (e) {
      debugPrint("Fetch Error");
    }
    
    final prefs = await SharedPreferences.getInstance();
    String? localData = prefs.getString(_cacheStatsKey);
    if (localData != null) {
      final decodedData = jsonDecode(localData);
      return _findCategoryInList(decodedData['stats'] ?? [], category);
    }
    return null;
  }

  Map<String, dynamic>? _findCategoryInList(List stats, String category) {
    for (var item in stats) {
      if (item['category'] == category) return item;
    }
    return null;
  }

  // --- 6. نظام الاستمرارية (Streak) ---
  Future<int> updateAndGetStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final String? lastVisit = prefs.getString('last_visit_date');
    int streak = prefs.getInt('daily_streak') ?? 0;

    if (lastVisit != today) {
      if (lastVisit != null) {
        DateTime lastDate = DateTime.parse(lastVisit);
        DateTime todayDate = DateTime.parse(today);
        if (todayDate.difference(lastDate).inDays == 1) {
          streak++;
        } else if (todayDate.difference(lastDate).inDays > 1) {
          streak = 1;
        }
      } else {
        streak = 1;
      }
      await prefs.setInt('daily_streak', streak);
      await prefs.setString('last_visit_date', today);
    }
    return streak;
  }
 Future<List<dynamic>> fetchLeaderboard() async {
  try {
    final token = await _getToken();
    // استبدل URL بالرابط الخاص بـ API تطبيقك
    var response = await http.get(
      Uri.parse('$general_url/tasbih/leaderboard'),
      headers: {'Authorization': 'Bearer $token'},
    );
    print(response.body);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data['leaderboard'] ?? [];
    }
  } catch (e) {
    print("Error fetching leaderboard: $e");
  }
  return [];
}
}