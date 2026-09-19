import 'package:doaa/component/app_colors.dart';
import 'package:doaa/controller/AuthController.dart';
import 'package:doaa/view/MainNavBar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
   LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // تعريف كلاس الخدمة

  @override
  void initState() {
    super.initState();

   
  }

  Future<void> _handleLoginSuccess(Map<String, dynamic> data) async {
    // 1. استخراج التوكن من رد اللارافيل
    String? token = data['access_token'];

    if (token != null) {
      // 2. حفظ التوكن في ذاكرة الجهاز
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      // أضف هذا داخل دالة _handleLoginSuccess في LoginPage
      await prefs.setString('user_name', data['user']['name']);
      await prefs.setString('user_email', data['user']['email']);
      await prefs.setString('user_avatar', data['user']['avatar'] ?? '');
      // 3. إظهار رسالة نجاح (SnackBar)
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("أهلاً بك مجدداً، ${data['user']['name']}"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // 4. الانتقال لصفحة الـ MainNavbar وحذف صفحة اللوجن من الـ Stack
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainWrapper()),
        (route) => false, // حذف كل الصفحات السابقة
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Column(
        children: [
          // الهيدر واللوغو
          _buildHeader(),

           Spacer(), // دفع المحتوى للأسفل ليعطي توازن بصري

          Padding(
            padding:  EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                 Text(
                  'تسجيل الدخول'.tr,
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                 SizedBox(height: 10),
                 Text(
                  'مرحباً بك في تطبيق دعاء\nسجل دخولك للمتابعة'.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textWhite, fontSize: 16),
                ),

                 SizedBox(height: 50),

                // أزرار تسجيل الدخول الاجتماعي
                _buildSocialButtons(),

                 SizedBox(height: 20),
                _buildSocialButton(
                  label: 'الدخول كزائر',
                  icon: Icons.arrow_forward_rounded,
                  color: AppColors.accentGold,
                  textColor: AppColors.primaryDark,
                  onTap: () => _startApp(),
                ),
                 Text(
                  "بإكمال تسجيل الدخول، أنت توافق على شروط الخدمة".tr,
                  style: TextStyle(color: AppColors.textGrey, fontSize: 11),
                ),
              ],
            ),
          ),

           SizedBox(height: 60), // مسافة من الأسفل
        ],
      ),
    );
  }

  // الجزء العلوي (اللوغو)
  Widget _buildHeader() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      width: double.infinity,
      decoration:  BoxDecoration(
        color: AppColors.secondaryDark,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(50)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/logo.jpeg', height: 140),
           SizedBox(height: 20),
           Text(
            'دُعاء'.tr,
            style: TextStyle(
              color: AppColors.accentGold,
              fontSize: 35,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              fontFamily: 'QuranFont', // إذا كان متوفر لديك
            ),
          ),
        ],
      ),
    );
  }

  // أزرار تسجيل الدخول الاجتماعي
  Widget _buildSocialButtons() {
    return Column(
      children: [
        // زر جوجل العريض
        // _socialButton(
        //   label: "المتابعة باستخدام جوجل",
        //   img: 'assets/google.png',
        //   color: AppColors.accentGold,
        //   textColor: Colors.black87,
        //   onTap: () => _socialAuthService.signInWithGoogle(),
        // ),

         SizedBox(height: 15),

        // زر أبل العريض
        _socialButton(
          label: "المتابعة باستخدام أبل",
          img: 'assets/iphone.png',
          color: AppColors.secondaryDark,
          textColor: AppColors.textWhite,
          onTap: () {
            // _socialAuthService.signInWithApple((user, data) {
            //   if (user != null && data != null) _handleLoginSuccess(data);
            // });
          },
        ),
      ],
    );
  }

  // ويدجت زر اجتماعي مخصص (شكل عريض وأكثر حداثة)
  Widget _socialButton({
    required String label,
    required String img,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 55,
        padding:  EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset:  Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(img, height: 24),
             SizedBox(width: 15),
            Text(
              label.tr,
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
   Widget _buildSocialButton({required String label, required IconData icon, required Color color, required Color textColor, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: textColor, size: 28),
        label: Text(label.tr, style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 2,
        ),
      ),
    );
  }
void _startApp() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) =>  MainWrapper()),
    );
  }
}
