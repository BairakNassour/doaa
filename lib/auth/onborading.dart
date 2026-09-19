import 'package:doaa/auth/LoginPage.dart';
import 'package:doaa/view/MainNavBar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:doaa/component/app_colors.dart';

class OnboardingPage extends StatefulWidget {
  OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  void _changeLanguage(String langCode) async {
    Locale locale = Locale(langCode);
    Get.updateLocale(locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_lang', langCode);
  }

  // 🔥 مصفوفة البيانات المحدثة لتشرح الشروط الدقيقة للتقدم والتسبيح وحساب النجوم والأيام المتتالية
  final List<Map<String, String>> onboardingData = [
    {
      'title': 'القرآن الكريم والأوراد اليومية',
      'subtitle': 'تصفح المصحف الإلكتروني لقراءة وردك اليومي، أو استمع إلى تلاوات خاشعة بأصوات أشهر القراء. قراءة الأوراد بانتظام هي حجر الأساس لتقدمك الإيماني.',
      'image': 'assets/onboraing (1).png',
    },
    {
      'title': 'مواقيت الصلاة والقبلة الصحيحة',
      'subtitle': 'تابع مواقيت الصلاة بدقة بحسب موقعك الحالي، وتعرف على المساجد القريبة منك، وحدد اتجاه القبلة الصحيح أينما كنت لتبقى صلواتك في مواقيتها.',
      'image': 'assets/onboraing (2).png',
    },
    {
      'title': 'آلية التسبيح الذكي وكسب الأعداد',
      'subtitle': 'استخدم المسبحة الإلكترونية المرنة؛ حيث تسجل كل نقرة عدداً إضافياً في رصيدك. عند إتمام الحِلقات، يقوم التطبيق بمزامنة أعداد التسبيح مع خادم البيانات فوراً لحساب تقدمك.',
      'image': 'assets/onboraing (3).png',
    },
    {
      'title': 'شروط النجوم والأيام المتتالية (Streak)',
      'subtitle': 'الاستمرارية هي السر! كرر الذكر يومياً لرفع عداد (الأيام المتتالية). سيؤدي انقطاعك يوماً واحداً إلى إعادة العداد للصفر. كلما أنجزت ورداً أو ذكراً، تكسب نجوماً ترفع رتبتك الإيمانية.',
      'image': 'assets/onboraing (1).png',
    },
    {
      'title': 'تقارير دقيقة: يومية، أسبوعية، وشهرية',
      'subtitle': 'يحلل التطبيق أوقات تسجيل أذكارك بالتوقيت المحلي لجهازك بدقة متناهية. يمكنك تصفية مجموع تسبيحاتك لرؤية إنجازك الفعلي خلال اليوم، أو تتبع نموك التراكمي أسبوعياً وشهرياً.',
      'image': 'assets/onboraing (3).png',
    },
    {
      'title': 'مزامنة وحفظ تقدمك الإيماني',
      'subtitle': 'سجل دخولك الآن عبر حسابك لضمان عدم ضياع إنجازاتك، وحفظ نجومك، وأيامك المتتالية، وتقاريرك الإحصائية، ومزامنتها عبر جميع أجهزتك الذكية فورا، أو تابع كزائر.',
      'image': 'assets/google.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: onboardingData.length,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildOnboardingItem(
                onboardingData[index]['title']!,
                onboardingData[index]['subtitle']!,
                onboardingData[index]['image']!,
                isLoginPage: index == onboardingData.length - 1,
              );
            },
          ),

          // زر تغيير اللغة
          Positioned(
            top: 50,
            right: Get.locale?.languageCode == 'ar' ? 20 : null,
            left: Get.locale?.languageCode == 'en' ? 20 : null,
            child: InkWell(
              onTap: () {
                if (Get.locale?.languageCode == 'ar') {
                  _changeLanguage('en');
                } else {
                  _changeLanguage('ar');
                }
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.accentGold.withOpacity(0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.language, color: AppColors.accentGold, size: 18),
                    SizedBox(width: 8),
                    Text(
                      Get.locale?.languageCode == 'ar' ? "English" : "العربية",
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // شريط التحكم السفلي
          Container(
            alignment: Alignment(0, 0.9),
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // زر تخطي يظهر فقط إذا لم نكن في الصفحة الأخيرة
                currentIndex == onboardingData.length - 1
                    ? SizedBox(width: 48) // مساحة فارغة للتوازن البصري
                    : TextButton(
                        onPressed: () => _handleSkip(), // استدعاء دالة التوجيه لصفحة تسجيل الدخول
                        child: Text(
                          'تخطي'.tr,
                          style: TextStyle(color: AppColors.textWhite, fontSize: 16),
                        ),
                      ),
                
                SmoothPageIndicator(
                  controller: _controller,
                  count: onboardingData.length,
                  effect: ExpandingDotsEffect(
                    activeDotColor: AppColors.accentGold,
                    dotColor: AppColors.textWhite.withOpacity(0.2),
                    dotHeight: 8,
                    dotWidth: 8,
                    expansionFactor: 4,
                  ),
                ),

                currentIndex == onboardingData.length - 1
                    ? SizedBox(width: 48) // مساحة فارغة للتوازن
                    : _buildNextButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingItem(String title, String subtitle, String imagePath, {bool isLoginPage = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Navigator.canPop(context) ? SizedBox(height: 10) : SizedBox(height: 40),
          Container(
            height: MediaQuery.of(context).size.height * 0.32,
            decoration: BoxDecoration(
              color: AppColors.secondaryDark.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
              image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.contain),
            ),
          ),
          SizedBox(height: 30),
          Text(
            title.tr,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textWhite, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 15),
          Text(
            subtitle.tr,
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textWhite, fontSize: 15, height: 1.5),
          ),
          SizedBox(height: 35),
          if (isLoginPage) _buildLoginSection() else SizedBox(height: 126),
        ],
      ),
    );
  }

  // تظهر الأزرار بالكامل في الصفحة الأخيرة (تسجيل الدخول أو زائر)
  Widget _buildLoginSection() {
    return Column(
      children: [
        // _buildSocialButton(
        //   label: 'تسجيل الدخول',
        //   icon: Icons.login,
        //   color: AppColors.textWhite,
        //   textColor: Colors.black,
        //   onTap: () => _gotologinApp(),
        // ),
        SizedBox(height: 16),
        _buildSocialButton(
          label: 'الدخول كزائر',
          icon: Icons.arrow_forward_rounded,
          color: AppColors.accentGold,
          textColor: AppColors.primaryDark,
          onTap: () => _startApp(),
        ),
      ],
    );
  }

  Widget _buildSocialButton({required String label, required IconData icon, required Color color, required Color textColor, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, color: textColor, size: 28),
        label: Text(label.tr, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return GestureDetector(
      onTap: () => _controller.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.accentGold.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.accentGold.withOpacity(0.5), width: 1.5),
        ),
        child: Icon(Icons.arrow_forward_ios_rounded, color: AppColors.accentGold, size: 20),
      ),
    );
  }

  void _handleSkip() {
    _controller.animateToPage(
      onboardingData.length - 1,
      duration: Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  void _startApp() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainWrapper()));
  }

  void _gotologinApp() {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
  }
}