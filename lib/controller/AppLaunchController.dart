// lib/controller/AppLaunchController.dart
import 'package:doaa/component/general_url.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:doaa/component/ad.dart'; // استيراد متغير الإعلانات

class AppLaunchController extends GetxController {
  // رقم نسخة التطبيق الحالية المبرمجة داخل فلاتر (قم بتحديثها مع كل إصدار)
  final int currentAppVersion = 1; 

  var isLoading = true.obs;
  var isVersionSupported = true.obs;
  
  String googlePlayUrl = "https://play.google.com/store/apps/details?id=com.abdorx.app.amra";
  String appStoreUrl = "";

  @override
  void onInit() {
    super.onInit();
    checkAppSettings();
  }

  Future<void> checkAppSettings() async {
    try {
      isLoading.value = true;

      // قم بوضع رابط السيرفر الخاص بك هنا
      final response = await http.get(Uri.parse('$general_url/app-settings'));
print(response.body);
      if (response.statusCode == 200) {
        
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['status'] == true) {
          final data = responseData['data'];

          // 1. تحديث حالة تفعيل الإعلانات عالمياً في ملف ad.dart
          isadactivitaed = data['show_ads'] ?? true;
          ishadithon=data['show_hadith'] ?? true;
          print("sssssssssssss");
          print("sssssssssssss");
          print(isadactivitaed);
          print("sssssssssssss");print("sssssssssssss");

          // 2. تخزين روابط المتاجر
          googlePlayUrl = data['google_play_url'] ?? "";
          appStoreUrl = data['app_store_url'] ?? "";

          // 3. التأكد من أن نسخة التطبيق الحالية موجودة ضمن النسخ المدعومة [1, 2]
          List<dynamic> supportedVersions = data['development_versions'] ?? [];
          
          if (supportedVersions.contains(currentAppVersion)) {
            isVersionSupported.value = true;
          } else {
            isVersionSupported.value = false; // النسخة قديمة ويجب التحديث إجبارياً
          }
        }
      }
    } catch (e) {
      // في حال فشل الاتصال بالسيرفر، نجعل التطبيق يعمل بالقيم الافتراضية لحين توفر إنترنت
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