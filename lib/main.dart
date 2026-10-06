import 'package:doaa/auth/splachScreen.dart'; 
import 'package:doaa/controller/AppLaunchController.dart';
import 'package:doaa/tranlsation/app_translations.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FaseehApp()); 
}

class FaseehApp extends StatelessWidget {
  const FaseehApp({super.key});

  @override
  Widget build(BuildContext context) {
    const String myFont = 'MyCustomFont'; 
    // تهيئة الـ Controller لجلب القيم والتحكم بها من أي مكان في التطبيق
    final AppLaunchController launchController = Get.put(AppLaunchController());

    return Obx(() => GetMaterialApp(
      title: 'دعاء العمرة دليل المسلم',
      debugShowCheckedModeBanner: false,

      translations: AppTranslations(), 
      locale: launchController.currentLocale.value,          
      fallbackLocale: const Locale('ar'), 

      themeMode: launchController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light, 
      
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
    ));
  }
}