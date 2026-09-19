import 'package:doaa/auth/splachScreen.dart'; 
import 'package:doaa/component/app_colors.dart';
import 'package:doaa/tranlsation/app_translations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();


  final prefs = await SharedPreferences.getInstance();
   print(prefs.getBool('is_dark_mode'));
  // --- قراءة الثيم المحفوظ (تأكد من اسم المفتاح المناسب) ---
  final bool isDarkMode = prefs.getBool('is_dark_mode') ?? true;

  // --- قراءة اللغة المحفوظة ---
  String? savedLang = prefs.getString('selected_lang');
  Locale initialLocale = savedLang != null 
      ? Locale(savedLang) 
      : Get.deviceLocale ?? const Locale('ar'); 
  
  runApp(FaseehApp(isDarkMode: isDarkMode, initialLocale: initialLocale)); 
}

class FaseehApp extends StatelessWidget {
  final bool isDarkMode;
  final Locale initialLocale; 
  
  const FaseehApp({super.key, required this.isDarkMode, required this.initialLocale});

  @override
  Widget build(BuildContext context) {
    const String myFont = 'MyCustomFont'; 

    return GetMaterialApp(
      title: 'دعاء العمرة دليل المسلم',
      debugShowCheckedModeBanner: false,

      translations: AppTranslations(), 
      locale: initialLocale,           
      fallbackLocale: const Locale('ar'), 

      // ✅ تحديد mode مباشرة وحاسمة
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light, 
      
      // --- الثيم الفاتح ---
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: myFont,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF9FBF7), 
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFE8EEDF),
          foregroundColor: Color(0xFF0C261F), 
          elevation: 0,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0C261F),
          brightness: Brightness.light,
        ),
      ),

      // --- الثيم الداكن ---
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: myFont,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0C261F),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF13322A),
          foregroundColor: Color(0xFFC4A46C), 
          elevation: 0,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFC4A46C),
          surface: Color(0xFF13322A),
        ),
      ),

      home: WelcomeScreen(), 
    );
  }
}