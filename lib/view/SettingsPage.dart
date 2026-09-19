import 'package:doaa/auth/LoginPage.dart';
import 'package:doaa/component/app_colors.dart';
import 'package:doaa/component/generalBoxDecoration.dart';
import 'package:doaa/controller/AuthController.dart';
import 'package:doaa/controller/ProgressController.dart';
import 'package:doaa/view/MainNavBar.dart';
import 'package:doaa/view/StatisticsPage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isDarkMode = true;
  String? _userName;
  bool _isLoggedIn = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    // قراءة الثيم المحفوظ (افتراضياً داكن)
    final savedTheme = prefs.getBool('is_dark_mode') ?? true;

    setState(() {
      _isLoggedIn = token != null;
      _userName = prefs.getString('user_name') ?? 'زائر العزيز';
      _isDarkMode = savedTheme;
      _isLoading = false;
    });
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  // Future<void> _handleLogout() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.clear();
  //   await SocialAuthService().signOut();

  //   if (!mounted) return;
  //   Navigator.pushAndRemoveUntil(
  //     context,
  //     MaterialPageRoute(builder: (context) => LoginPage()),
  //     (route) => false,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accentGold),
        ),
      );
    }

    String firstLetter = _userName!.trim().isNotEmpty
        ? _userName!.trim().substring(0, 1).toUpperCase()
        : 'ز';

    return Scaffold(
      backgroundColor: AppColors.secondaryDark,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryDark,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'الإعدادات'.tr,
          style: TextStyle(
            color: AppColors.accentGold,
            fontWeight: FontWeight.bold,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Container(
        decoration: getBoxDecoration(),
        child: ListView(
          padding: EdgeInsets.all(20),
          children: [
            _buildSectionTitle('الحساب الشخصي'),
            _buildSettingsCard(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.accentGold,
                  child: Text(
                    firstLetter.tr,
                    style: TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                title: Text(
                  _userName!,
                  style: TextStyle(color: AppColors.textWhite),
                ),
                subtitle: Text(
                  _isLoggedIn
                      ? 'تم تسجيل الدخول بنجاح'.tr
                      : 'سجل دخولك لحفظ بياناتك'.tr,
                  style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                ),
                trailing: _isLoggedIn
                    ? null
                    : Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.accentGold,
                        size: 16,
                      ),
                onTap: _isLoggedIn
                    ? null
                    : () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
              ),
            ),
            SizedBox(height: 25),
            _buildSettingsCard(
              child: _buildSettingsTile(
                'عن المطور',
                Icons.build,
                'Inch Code',
                () => _showCompanyAboutDialog(context),
              ),
            ),

            if (_isLoggedIn) ...[
              const SizedBox(height: 25),
              _buildSectionTitle('user_stats_title'.tr),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Get.to(() => const StatisticsPage()),
                child: FutureBuilder<Map<String, dynamic>>(
                  // سنقوم بجلب البيانات من الدالة التي تتعامل مع العدادات الجديدة
                  future: _getUserStatsLocalAndRemote(),
                  builder: (context, snapshot) {
                    // 1. استخراج الـ Streak (الأيام المتتالية)
                    int streak = snapshot.data?['streak'] ?? 0;
                    // 2. استخراج آخر سورة
                    String surah = snapshot.data?['surah'] ?? '...';
                    // 3. استخراج إجمالي العدادات (بدل النجوم)
                    int totalDeeds = snapshot.data?['total_deeds'] ?? 0;

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.secondaryDark,
                            AppColors.secondaryDark.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.accentGold.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          children: [
                            // خلفية فنية خفيفة (أيقونة النار للدلالة على الاستمرارية)
                            Positioned(
                              left: -10,
                              bottom: -10,
                              child: Icon(
                                Icons.local_fire_department_rounded,
                                size: 80,
                                color: Colors.orangeAccent.withOpacity(0.05),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  // قسم الاستمرارية (Streak) - الأهم حالياً
                                  _buildModernStatItem(
                                    label: 'استمرارية'.tr,
                                    value: '$streak يوم',
                                    icon: Icons.local_fire_department_rounded,
                                    color: Colors.orangeAccent,
                                  ),

                                  Container(
                                    height: 30,
                                    width: 1,
                                    color: Colors.white10,
                                  ),

                                  // قسم آخر سورة
                                  _buildModernStatItem(
                                    label: 'آخر سورة'.tr,
                                    value: surah,
                                    icon: Icons.auto_stories_rounded,
                                    color: Colors.blueAccent,
                                  ),

                                  Container(
                                    height: 30,
                                    width: 1,
                                    color: Colors.white10,
                                  ),

                                  // قسم إجمالي الطاعات (العدد الكلي)
                                  _buildModernStatItem(
                                    label: 'إجمالي الطاعات'.tr,
                                    value: '$totalDeeds',
                                    icon: Icons.done,
                                    color: AppColors.accentGold,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            SizedBox(height: 25),
            _buildSectionTitle('إعدادات التطبيق'),
            _buildSettingsTile(
              'لغة التطبيق',
              Icons.language,
              Get.locale?.languageCode == 'ar'
                  ? 'العربية'
                  : 'English', // يعرض اللغة المختارة حالياً
              () => _showLanguagePicker(context),
            ),
            SizedBox(height: 10),
            SizedBox(height: 25),
            _buildSectionTitle('تواصل معنا'),
            _buildSettingsCard(
              child: Column(
                children: [
                  _buildSettingsTile(
                    'واتساب',
                    Icons.chat_bubble_outline,
                    '',
                    () => _launchUrl(
                      'https://whatsapp.com/channel/0029Vb6HtHdIyPtPrsi4m131',
                    ), // ضع رقمك هنا
                  ),
                  Divider(
                    color: AppColors.accentGold.withOpacity(0.1),
                    height: 1,
                  ),
                  _buildSettingsTile(
                    'التلغرام',
                    Icons.telegram,
                    '',
                    () => _launchUrl('https://t.me/Umrah_Duas'), // رابط صفحتك
                  ),
                  Divider(
                    color: AppColors.accentGold.withOpacity(0.1),
                    height: 1,
                  ),
                  _buildSettingsTile(
                    'تيك توك',
                    Icons.tiktok,
                    '',
                    () => _launchUrl(
                      'https://www.tiktok.com/@umrah_duas?_r=1&_t=ZS-98Hnrb1L7Uj',
                    ), // رابط صفحتك
                  ),
                  Divider(
                    color: AppColors.accentGold.withOpacity(0.1),
                    height: 1,
                  ),
                  _buildSettingsTile(
                    'إنستغرام',
                    Icons.camera_alt_outlined,
                    '',
                    () => _launchUrl(
                      'https://www.instagram.com/umrah_duas?igsh=MXRndTRiN21mMWhqeg==',
                    ), // رابط حسابك
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            SizedBox(height: 25),

            _buildSettingsCard(
              child: SwitchListTile(
                secondary: Icon(
                  _isDarkMode
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  color: AppColors.accentGold,
                ),
                title: Text(
                  'الوضع الداكن'.tr,
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  _isDarkMode
                      ? 'تفعيل الوضع الليلي المريح'.tr
                      : 'تفعيل الوضع الفاتح'.tr,
                  style: TextStyle(color: AppColors.textGrey, fontSize: 11),
                ),
                activeColor: AppColors.accentGold,
                activeTrackColor: AppColors.accentGold.withOpacity(0.3),
                value: _isDarkMode,
                onChanged: (bool value) async {
                  // 1. تحديث الحالة في الواجهة فوراً
                  setState(() => _isDarkMode = value);

                  // 2. حفظ القيمة في SharedPreferences لضمان بقائها عند إغلاق التطبيق
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('is_dark_mode', value);

                  // 3. تغيير الثيم باستخدام GetX
                  Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);

                  // 4. رسالة تأكيد خفيفة (اختياري)
                  Get.snackbar(
                    "تم التغيير",
                    value ? "تم تفعيل الوضع الداكن" : "تم تفعيل الوضع الفاتح",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.secondaryDark,
                    colorText: AppColors.accentGold,
                    duration: Duration(seconds: 1),
                  );

                  // 5. الانتقال للهوم بيج وإغلاق كل الصفحات السابقة لضمان تحديث الألوان
                  // تأكد من استبدال 'HomePage' باسم الكلاس الحقيقي لصفحتك الرئيسية
                  Future.delayed(Duration(milliseconds: 500), () {
                    // نستخدم offAll عشان نصفر المكدس ونحدث الثيم في كل التطبيق
                    // إذا كان عندك BottomNavigationBar، هاد الخيار الأفضل
                    Get.offAll(MainWrapper());
                  });
                },
              ),
            ),

            SizedBox(height: 25),
            _buildSectionTitle('الدعم والمساعدة'),
            _buildSettingsCard(
              child: Column(
                children: [
                  _buildSettingsTile(
                    'تقييم التطبيق',
                    Icons.star_border,
                    '',
                    () => _launchUrl(
                      'https://play.google.com/store/apps/details?id=com.abdorx.app.amra',
                    ),
                  ),
                  Divider(color: AppColors.accentGold, height: 1),
                  // ⭐ زر مشاركة التطبيق
                  _buildSettingsTile(
                    'مشاركة التطبيق',
                    Icons.share_outlined,
                    '',
                    () => _shareApp(),
                  ),
                  Divider(color: AppColors.accentGold, height: 1),
                  _buildSettingsTile(
                    'سياسة الخصوصية',
                    Icons.privacy_tip_outlined,
                    '',
                    () => _launchUrl(
                      'https://doaa.inchcode.com/doaa/doaa/public/privacy-policy',
                    ), // يمكنك استبدال هذا برابط سياسة الخصوصية الخاص بك
                  ),
                  Divider(color: AppColors.accentGold, height: 1),
                  _buildSettingsTile(
                    'عن التطبيق',
                    Icons.info_outline,
                    'إصدار 1.0.0',
                    () {},
                  ),
                ],
              ),
            ),

            SizedBox(height: 40),
            // _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  void _shareApp() {
    const String appLink =
        'https://play.google.com/store/apps/details?id=com.abdorx.app.amra'; // استبدل بـ package name الخاص بتطبيقك
    Share.share(
      'حمل تطبيق الأذكار والدعاء واستفد من الأذكار اليومية:\n$appLink',
      subject: 'تطبيق الأذكار والدعاء',
    );
  }

  // Widget _buildLogoutButton() {
  //   return Center(
  //     child: Column(
  //       children: [
  //         TextButton.icon(
  //           onPressed: _isLoggedIn
  //               ? _handleLogout
  //               : () {
  //                   Navigator.push(
  //                     context,
  //                     MaterialPageRoute(builder: (context) => LoginPage()),
  //                   );
  //                 },
  //           icon: Icon(
  //             _isLoggedIn ? Icons.logout : Icons.login,
  //             color: _isLoggedIn ? Colors.redAccent : AppColors.accentGold,
  //           ),
  //           label: Text(
  //             _isLoggedIn ? 'تسجيل الخروج'.tr : 'تسجيل الدخول'.tr,
  //             style: TextStyle(
  //               color: _isLoggedIn ? Colors.redAccent : AppColors.accentGold,
  //             ),
  //           ),
  //         ),
  //         SizedBox(height: 10),
  //         Text(
  //           'صنع بكل حب لخدمة ضيوف الرحمن'.tr,
  //           style: TextStyle(color: AppColors.textGrey, fontSize: 10),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(right: 10, bottom: 10),
      child: Text(
        title.tr,
        style: TextStyle(
          color: AppColors.accentGold,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryDark,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.accentGold),
      ),
      child: child,
    );
  }

  Widget _buildSettingsTile(
    String title,
    IconData icon,
    String trailingText,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.accentGold),
      title: Text(
        title.tr,
        style: TextStyle(color: AppColors.textWhite, fontSize: 14),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText.isNotEmpty)
            Text(
              trailingText.tr,
              style: TextStyle(color: AppColors.textGrey, fontSize: 12),
            ),
          SizedBox(width: 10),
          Icon(Icons.arrow_forward_ios, color: AppColors.textWhite, size: 14),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildStatColumn(
    String label,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: 24),
        SizedBox(height: 4),
        Text(
          value.tr,
          style: TextStyle(
            color: AppColors.textWhite,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        Text(
          label.tr,
          style: TextStyle(color: AppColors.textGrey, fontSize: 10),
        ),
      ],
    );
  }

  void _showLanguagePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.secondaryDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'اختر لغة التطبيق'.tr,
                style: TextStyle(
                  color: AppColors.accentGold,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // خيار اللغة العربية
              ListTile(
                leading: Icon(Icons.language, color: AppColors.accentGold),
                title: Text(
                  'العربية'.tr,
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: Get.locale?.languageCode == 'ar'
                    ? Icon(Icons.check_circle, color: AppColors.accentGold)
                    : null,
                onTap: () async {
                  Get.updateLocale(const Locale('ar')); // تغيير اللغة للعربية
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString(
                    'selected_lang',
                    "ar",
                  ); // حفظ الاختيار للمرات القادمة

                  Navigator.pop(context);
                },
              ),
              // خيار اللغة الإنجليزية
              ListTile(
                leading: Icon(Icons.language, color: AppColors.accentGold),
                title: const Text(
                  'English',
                  style: TextStyle(color: Colors.white),
                ),
                trailing: Get.locale?.languageCode == 'en'
                    ? Icon(Icons.check_circle, color: AppColors.accentGold)
                    : null,
                onTap: () async {
                  Get.updateLocale(
                    const Locale('en'),
                  ); // تغيير اللغة للإنجليزية
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString(
                    'selected_lang',
                    "en",
                  ); // حفظ الاختيار للمرات القادمة

                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _getUserStatsLocalAndRemote() async {
    final prefs = await SharedPreferences.getInstance();
    final progressController = ProgressController();

    int totalDeeds = 0; // إجمالي الطاعات (بديل النجوم)
    String lastSurah = 'لم تبدأ';
    String rank = "مبتدئ";
    int streak = 0;

    try {
      // 1. جلب قائمة الإنجازات (التي أصبحت الآن تعيد all_records)
      final stats = await progressController.getAllStats();

      if (stats.isNotEmpty) {
        // 2. حساب إجمالي الطاعات (العدد الكلي للسجلات)
        totalDeeds = stats.length;

        // 3. تحديث الرتبة بناءً على عدد الإنجازات الحقيقي
        if (totalDeeds >= 1000)
          rank = "سابق بالخيرات";
        else if (totalDeeds >= 500)
          rank = "مُجتهد";
        else if (totalDeeds >= 100)
          rank = "ساعٍ للخير";
        else
          rank = "مبتدئ";
      }

      // 4. جلب عداد الاستمرارية (Streak) من الدالة التي أضفناها للكنترولر
      streak = await progressController.updateAndGetStreak();
    } catch (e) {
      debugPrint("Error fetching stats: $e");
      // في حالة الخطأ نحاول جلب القيم المخزنة محلياً كاحتياط
      totalDeeds = prefs.getInt('total_stars') ?? 0;
      streak = prefs.getInt('daily_streak') ?? 0;
    }

    // 5. جلب اسم آخر سورة
    lastSurah = prefs.getString('last_surah_name') ?? 'لم تبدأ';

    return {
      'surah': lastSurah,
      'total_deeds':
          totalDeeds, // تأكد أن هذا المفتاح يطابق ما استخدمناه في الويدجت
      'rank': rank,
      'streak': streak,
    };
  }

  void _showCompanyAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.secondaryDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: BorderSide(color: AppColors.accentGold.withOpacity(0.3)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.accentGold.withOpacity(0.5),
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset(
                    'assets/companylogo.jpeg',
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.code, color: AppColors.accentGold, size: 40),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Text(
                "InchCode".tr,
                style: TextStyle(
                  color: AppColors.accentGold,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Software Solutions & Development".tr,
                style: TextStyle(
                  color: AppColors.textGrey,
                  fontSize: 10,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 15),
              Divider(color: AppColors.accentGold, thickness: 1),
              SizedBox(height: 15),
              Text(
                "نحن فخورون بتطوير هذا التطبيق صدقة جارية.\nإذا كنت ترغب في بناء مشروعك الخاص، يسعدنا أن نكون شريكك التقني."
                    .tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
              SizedBox(height: 25),
              _buildContactCard(
                Icons.language,
                "الموقع الإلكتروني",
                "https://companyshow.inchcode.com/",
              ),
              _buildContactCard(
                Icons.chat_bubble_outline,
                "فرع دبي (واتساب)",
                "https://wa.me/971565991072",
              ),
              _buildContactCard(
                Icons.chat_bubble_outline,
                "فرع سوريا (واتساب)",
                "https://wa.me/963936979261",
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentGold,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  "إغلاق".tr,
                  style: TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContactCard(IconData icon, String label, String url) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () async {
          final Uri uri = Uri.parse(url);
          if (await canLaunchUrl(uri))
            await launchUrl(uri, mode: LaunchMode.externalApplication);
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.textWhite.withOpacity(0.05),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.accentGold, size: 20),
              SizedBox(width: 15),
              Expanded(
                child: Text(
                  label.tr,
                  style: TextStyle(color: AppColors.textWhite, fontSize: 13),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textWhite,
                size: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
