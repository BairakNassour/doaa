// lib/auth/splachScreen.dart
import 'package:doaa/auth/onborading.dart';
import 'package:doaa/component/app_colors.dart';
import 'package:doaa/component/generalBoxDecoration.dart';
import 'package:doaa/view/MainNavBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:home_widget/home_widget.dart';
// استيراد الكنترولر الجديد وملف الإعلانات
import 'package:doaa/controller/AppLaunchController.dart';
import 'package:doaa/component/ad.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // ربط واستدعاء الكنترولر الجديد ليفحص السيرفر فوراً عند الدخول
  final AppLaunchController _launchController = Get.put(AppLaunchController());

  static const platform = MethodChannel('com.example.doaa/widget_pin');

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _initializeApp();
  }

  // دالة التهيئة والانتظار حتى انتهاء الفحص من السيرفر
  Future<void> _initializeApp() async {
    // ننتظر حتى ينتهي الفحص من السيرفر تماماً
    while (_launchController.isLoading.value) {
      await Future.delayed(const Duration(milliseconds: 200));
    }

    // إذا كانت النسخة مدعومة وصحيحة، نكمل التوجيه الطبيعي للصفحات التالية
    if (_launchController.isVersionSupported.value) {
      _navigateToNext();
    }
  }

  Future<void> _showWidgetRequestDialog() async {
    final prefs = await SharedPreferences.getInstance();
    bool hasAskedBefore = prefs.getBool('widget_asked') ?? false;
    if (hasAskedBefore) return;
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.secondaryDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.accentGold, width: 1),
        ),
        title: Text(
          "تابع تقدمك".tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.accentGold,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "هل تود إضافة اختصار الإحصائيات للشاشة الرئيسية؟".tr,
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textWhite),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("ليس الآن".tr,
                style: TextStyle(color: AppColors.textWhite)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGold,
              foregroundColor: AppColors.primaryDark,
            ),
            onPressed: () async {
              await HomeWidget.saveWidgetData<int>('total_stars', 0);
              await HomeWidget.saveWidgetData<String>('user_rank', 'مبتدئ');
              await HomeWidget.updateWidget(
                name: 'AppWidgetProvider',
                androidName: 'AppWidgetProvider',
              );
              try {
                await platform.invokeMethod('requestPinWidget');
              } catch (e) {
                debugPrint("faliure: $e");
              }
              if (context.mounted) Navigator.pop(context);
            },
            child: Text("إضافة الآن".tr),
          ),
        ],
      ),
    );
    await prefs.setBool('widget_asked', true);
  }

  Future<void> _navigateToNext() async {
    // انتظار بسيط كـ Delay للشاشة اللطيفة
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    // التحقق مما إذا كان المستخدم قد شاهد الـ Onboarding من قبل
    bool hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;

    if (!hasSeenOnboarding) {
      // حفظ الشرط فوراً لعدم إظهاره ثانية إطلاقاً
      await prefs.setBool('has_seen_onboarding', true);
      await _showWidgetRequestDialog();
      if (!mounted) return;
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => OnboardingPage()),
      );
    } else {
      // الانتقال المباشر للواجهة الرئيسية سواء كان مسجلاً للداخل أم لا
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => MainWrapper()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: getBoxDecoration(),
        child: Obx(() {
          // 1. إذا كان لا يزال يبحث ويحمل من السيرفر
          if (_launchController.isLoading.value) {
            return _buildSplashLoading();
          }

          // 2. إذا انتهى الفحص ووجد أن النسخة قديمة وغير مدعومة (واجهة التحديث الإجباري)
          if (!_launchController.isVersionSupported.value) {
            return _buildUpdateRequiredScreen();
          }

          // 3. العرض الافتراضي أثناء التنقل للنسخة المدعومة
          return _buildSplashLoading();
        }),
      ),
    );
  }

  // ويدجت التحميل العادي للـ Splash
  Widget _buildSplashLoading() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScaleTransition(
          scale: _animation,
          child: Image.asset('assets/firstpagelogo.png', width: 220),
        ),
        const SizedBox(height: 60),
        CircularProgressIndicator(color: AppColors.accentGold),
      ],
    );
  }

  // واجهة التحديث الإجباري الممنوعة من الدخول للتطبيق
  Widget _buildUpdateRequiredScreen() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.system_update_rounded, size: 90, color: AppColors.accentGold),
          const SizedBox(height: 30),
          Text(
            "يتوفر تحديث جديد!".tr,
            style: TextStyle(
              color: AppColors.accentGold,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),
          Text(
            "نأسف، هذه النسخة من التطبيق لم تعد مدعومة. يرجى التحديث للحصول على الميزات الجديدة وإصلاحات الأخطاء لتتمكن من المتابعة.".tr,
            style: TextStyle(color: AppColors.textWhite, fontSize: 14, height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGold,
              foregroundColor: AppColors.primaryDark,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 5,
            ),
            onPressed: () => _launchController.openStore(),
            icon: const Icon(Icons.download, size: 22),
            label: Text(
              "تحديث التطبيق الآن".tr,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}