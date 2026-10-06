import 'package:doaa/component/general_url.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:doaa/component/ad.dart'; // استيراد متغير الإعلانات

class AppLaunchController extends GetxController {
  // رقم نسخة التطبيق الحالية المبرمجة داخل فلاتر
  final int currentAppVersion = 2; 

  var isLoading = true.obs;
  var isVersionSupported = true.obs;
  
  // متغيرا الوضع الداكن واللغة
  var isDarkMode = true.obs;
  var currentLocale = const Locale('ar').obs;

  String googlePlayUrl = "https://play.google.com/store/apps/details?id=com.abdorx.app.amra";
  String appStoreUrl = "";

  @override
  void onInit() {
    super.onInit();
    initAppThemeAndLanguage(); // تحميل إعدادات اللغة والثيم أولاً
    checkAppSettings();
  }

  /// قراءة الثيم واللغة من SharedPreferences أو تعيين القيم الافتراضية (داكن وعربي)
  Future<void> initAppThemeAndLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    // 1. قراءة الثيم (الافتراضي: true أي داكن)
    isDarkMode.value = prefs.getBool('is_dark_mode') ?? true;

    // 2. قراءة اللغة (الافتراضي: 'ar' العربية)
    String? savedLang = prefs.getString('selected_lang');
    if (savedLang != null) {
      currentLocale.value = Locale(savedLang);
    } else {
      currentLocale.value = const Locale('ar');
    }

    // تطبيق اللغة والثيم على GetX فوراً
    Get.updateLocale(currentLocale.value);
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  /// دالة تغيير الثيم
  Future<void> toggleTheme(bool isDark) async {
    isDarkMode.value = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', isDark);
    Get.changeThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);
  }

  /// دالة تغيير اللغة
  Future<void> changeLanguage(String langCode) async {
    currentLocale.value = Locale(langCode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_lang', langCode);
    Get.updateLocale(currentLocale.value);
  }

  Future<void> checkAppSettings() async {
    try {
      isLoading.value = true;

      final response = await http.get(Uri.parse('$general_url/app-settings'));
      print(response.body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['status'] == true) {
          final data = responseData['data'];

          // 1. تحديث حالة تفعيل الإعلانات عالمياً
          isadactivitaed = data['show_ads'] ?? true;
          ishadithon = data['show_hadith'] ?? true;

          // 2. تخزين روابط المتاجر
          googlePlayUrl = data['google_play_url'] ?? "";
          appStoreUrl = data['app_store_url'] ?? "";

          // 3. التأكد من دعم الإصدار
          List<dynamic> supportedVersions = data['development_versions'] ?? [];
          
          if (supportedVersions.contains(currentAppVersion)) {
            isVersionSupported.value = true;
          } else {
            isVersionSupported.value = false;
          }
        }
      }
    } catch (e) {
      isVersionSupported.value = true; 
      isadactivitaed = true; 
    } finally {
      isLoading.value = false;
    }
  }

  // دالة توجيه المستخدم للمتجر لتحديث التطبيق
  Future<void> openStore() async {
    String urlToOpen = Platform.isAndroid ? googlePlayUrl : appStoreUrl;
    if (urlToOpen.isNotEmpty) {
      final Uri url = Uri.parse(urlToOpen);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    }
  }
}