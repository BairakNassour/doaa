import 'package:doaa/component/ad.dart';
import 'package:doaa/component/app_colors.dart';
import 'package:doaa/component/generalBoxDecoration.dart';
import 'package:doaa/controller/PrayerController.dart';
import 'package:doaa/controller/dua_controller.dart';
import 'package:doaa/model/dua_model.dart';
import 'package:doaa/view/HomePage/AyatAudio.dart';
import 'package:doaa/view/HomePage/EventPage.dart';
import 'package:doaa/view/HomePage/NamesOfAllahPage.dart';
import 'package:doaa/view/HomePage/NearbyMosquesPage.dart';
import 'package:doaa/view/HomePage/PrayerTimesPage.dart';
import 'package:doaa/view/HomePage/QiblaPage.dart';
import 'package:doaa/view/HomePage/QuranPage.dart';
import 'package:doaa/view/HomePage/TasbihPage.dart';
import 'package:doaa/view/HomePage/UmrahDetailsPage.dart';
import 'package:doaa/view/HomePage/wallpaper_page.dart';
import 'package:doaa/view/ManasikPage.dart';
import 'package:doaa/view/dua_flip_view.dart';
import 'package:doaa/view/widget/clock.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PrayerController _prayerController = PrayerController();
  DuaController duaController = DuaController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _prayerController.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryDark,
      body: Container(
        decoration: getBoxDecoration(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),

              ListenableBuilder(
                listenable: _prayerController,
                builder: (context, child) {
                  // 1. إذا لم تكن هناك بيانات نهائياً (وفشل التحميل تماماً بدون كاش)
                  if (!_prayerController.isLoading &&
                      _prayerController.prayerModel == null) {
                    return Center(
                      child: Text(
                        "تعذر جلب مواقيت الصلاة".tr,
                        style: TextStyle(color: AppColors.textWhite),
                      ),
                    );
                  }

                  // 2. تمرير الكنترولر مباشرة وبناء الكارت
                  return _buildPrayerAndHijriCard(_prayerController);
                },
              ),
              _buildModernQuickAccess(context),

              // _buildEventCounters(),
              // _buildSpecialHadithCard('أحاديث نبوية','hadith','جوامع كلم النبي ﷺ وصحيح السنة', context),
              // _buildSpecialHadithCard('دعاء الحج','hajj','كل ما تحتاجه من أدعية أثناء الحج', context),
              // _buildSpecialHadithCard('دعاء المدينة','madina','ادعية المدينة كاملة', context),
              FutureBuilder<List<dynamic>>(
                future: duaController
                    .fetchCategoryTypes(), // استدعاء الدالة الجديدة
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return SizedBox(); // أو رسالة خطأ
                  }

                  // الفلترة: استثناء الصباح، المساء، والعام
                  final filteredList = snapshot.data!.where((type) {
                    final slug = type['slug'];
                    return slug != 'morning' &&
                        slug != 'evening' &&
                        slug != 'general';
                  }).toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final category = filteredList[index];
                      print(category['name']);

                      // قراءة حالة التفعيل ديناميكياً من البيانات القادمة من الـ API
                      // يدعم كلاً من الموديل (DuaCategory) أو الـ Map الداخلي
                      final bool isActive = category is DuaCategory
                          ? category.isActive
                          : (category['is_active'] == true ||
                                category['is_active'] == 1);

                      return !(category['name'] == "عمرة" ||
                              category['name'] == "حج" ||
                              category['name'] == "دعاء المدينة")
                          ? _buildSpecialHadithCard(
                              category['name'], // الاسم من القاعدة
                              category['slug'] ??
                                  category['type'] ??
                                  '', // الـ type أو slug
                              "كل ما تحتاجه من أدعية الـ ${category['name']}",
                              isActive, // تمرير حالة التفعيل ديناميكياً
                              context,
                            )
                          : const SizedBox();
                    },
                  );
                },
              ),
              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToFlip(
    BuildContext context,
    String title,
    String type, {
    String? categoryName,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DuaFlipView(
          type: type,
          title: title,
          categoryName: categoryName, // نمرر الاسم للصفحة التالية
        ),
      ),
    );
  }

  void _showDuaSelectorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: AppColors.secondaryDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: AppColors.accentGold.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'اختر أدعية المناسك'.tr,
                  style: GoogleFonts.amiri(
                    color: AppColors.accentGold,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildDialogOption(
                  context: dialogContext,
                  title: 'دعاء العمرة والزيارة'.tr,
                  icon: Icons.brightness_3_rounded,
                  type: 'omra',
                ),
                const SizedBox(height: 10),
                _buildDialogOption(
                  context: dialogContext,
                  title: 'أدعية الحج'.tr,
                  icon: Icons.square_outlined, // رمز يعبر عن الكعبة الشريفة
                  type: 'hajj',
                ),
                const SizedBox(height: 10),
                _buildDialogOption(
                  context: dialogContext,
                  title: 'أدعية المدينة كاملة'.tr,
                  icon: Icons.location_city_rounded,
                  type: 'madina',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDialogOption({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String type,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.pop(context); // إغلاق البوب آب أولاً
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OmraFlipPage(type: type)),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.accentGold.withOpacity(0.12)),
            color: AppColors.accentGold.withOpacity(0.04),
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.accentGold, size: 24),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.amiri(
                    color: AppColors.textWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.chevron_left_rounded
                    : Icons.chevron_right_rounded,
                color: AppColors.accentGold.withOpacity(0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ويدجت البطاقة بتصميم ديناميكي بحسب حالة التفعيل
  Widget _buildSpecialHadithCard(
    String title,
    String type,
    String subtitle,
    bool isActive, // استلام حالة التفعيل الديناميكية
    BuildContext context,
  ) {
    // تكتسب حالة التعطيل إذا كانت is_active = false من الـ API
    final bool isDisabled = !isActive;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.secondaryDark, // الخلفية الداكنة الأساسية
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: () {
            if (isDisabled) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('قسم $title سيكون متاحاً قريباً إن شاء الله'),
                  duration: const Duration(seconds: 2),
                ),
              );
            } else {
              _navigateToFlip(context, title, type);
            }
          },
          child: Stack(
            children: [
              Positioned(
                top: -20,
                left: -20,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.accentGold.withOpacity(0.05),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.accentGold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.menu_book_rounded,
                        color: AppColors.accentGold,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 18),

                    // النصوص والشارات
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  title.tr,
                                  style: GoogleFonts.amiri(
                                    color: AppColors.accentGold,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                              ),
                              if (isDisabled) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.orange.withOpacity(0.5),
                                      width: 1,
                                    ),
                                  ),
                                  child: const Text(
                                    'متاح قريباً',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isDisabled
                                ? 'سيكون متاحاً قريباً في التحديث القادم'
                                : subtitle.tr,
                            style: TextStyle(
                              color: AppColors.textWhite.withOpacity(0.7),
                              fontSize: 14,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // أيقونة السهم / القفل
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accentGold.withOpacity(0.05),
                      ),
                      child: Icon(
                        isDisabled
                            ? Icons.lock_clock_rounded
                            : Icons.chevron_left_rounded,
                        color: isDisabled
                            ? Colors.orange.withOpacity(0.7)
                            : AppColors.accentGold,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernQuickAccess(BuildContext context) {
    late PrayerController prayerController = PrayerController();
    return Column(
      children: [
        // 1. زر دعاء العمرة والزيارة (البانر الكبير)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.secondaryDark,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.accentGold.withOpacity(0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              onTap: () => _showDuaSelectorDialog(context),
              splashColor: AppColors.accentGold.withOpacity(0.1),
              highlightColor: Colors.transparent,
              child: Stack(
                children: [
                  Positioned(
                    top: -25,
                    left: -25,
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: AppColors.accentGold.withOpacity(0.03),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.accentGold.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.accentGold.withOpacity(0.15),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.mosque_rounded,
                            color: AppColors.accentGold,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Text(
                            'أدعية الحج والعمرة والمدينة'.tr,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.amiri(
                              color: AppColors.textWhite,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accentGold.withOpacity(0.05),
                          ),
                          child: Icon(
                            Directionality.of(context) == TextDirection.rtl
                                ? Icons.chevron_left_rounded
                                : Icons.chevron_right_rounded,
                            color: AppColors.accentGold.withOpacity(0.7),
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 20),

        // 2. القائمة الأفقية (الخدمات + عدادات المناسبات)
        Container(
          height: 110,
          margin: EdgeInsets.only(top: 10, bottom: 15),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 10),
            physics: BouncingScrollPhysics(),
            children: [
              _glassItem(Icons.mic, 'القرآن صوت', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AudioPlayerPage()),
                );
              }),
              _glassItem(Icons.fingerprint_rounded, 'المسبحة', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TasbihPage()),
                );
              }),
              _glassItem(Icons.explore_rounded, 'القبلة', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QiblaPage()),
                );
              }),
              _glassItem(Icons.auto_awesome_rounded, 'أسماء الله', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NamesOfAllahPage()),
                );
              }),
              _glassItem(Icons.location_on_rounded, 'مساجد', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => NearbyMosquesPage()),
                );
              }),
              // --- الخدمات الثابتة (تظهر فوراً) ---
              _glassItem(Icons.menu_book_rounded, 'المناسك', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManasikPage()),
                );
              }),
              _glassItem(Icons.wallpaper_rounded, 'الخلفيات', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WallpaperPage()),
                );
              }),

              // --- العدادات المرتبطة بالـ API (FutureBuilder) ---
              FutureBuilder(
                // نستخدم الدالة init() التي تجلب البيانات وتحسب المواعيد
                future: prayerController.prayerModel == null
                    ? prayerController.init()
                    : Future.value(null),
                builder: (context, snapshot) {
                  // في حالة التحميل، نعرض Spinner صغير مكان العدادات
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      prayerController.prayerModel == null) {
                    return SizedBox(
                      width: 100,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.accentGold,
                        ),
                      ),
                    );
                  }

                  // بمجرد توفر البيانات في الكنترولر، نعرض العدادات
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _glassItem(Icons.nightlight_round, 'المناسبات الدينية', () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              // تنظيف النص من أي أحرف غير الأرقام (مثل كلمة "يوم")
                              String ramadanClean = prayerController
                                  .daysToRamadan
                                  .replaceAll(RegExp(r'[^0-9]'), '');
                              String hajjClean = prayerController.daysToHajj
                                  .replaceAll(RegExp(r'[^0-9]'), '');

                              // التحويل لرقم، وإذا فشل بنعطيه 0
                              int rDays = int.tryParse(ramadanClean) ?? 0;
                              int hDays = int.tryParse(hajjClean) ?? 0;

                              return EventsPage(
                                // إذا الـ rDays صفر، رح يعطيك العداد أصفار، تأكد إن الكنترولر فيه قيمة
                                ramadanDate: DateTime.now().add(
                                  Duration(days: rDays),
                                ),
                                hajjDate: DateTime.now().add(
                                  Duration(days: hDays),
                                ),
                              );
                            },
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),

              // أيقونة إضافية للمساجد (اختياري)
            ],
          ),
        ),
      ],
    );
  }

  // حافظت لك على تعريف الـ _glassItem الخاص بك كما هو تماماً
  Widget _glassItem(IconData icon, String label, VoidCallback onTap) {
    return Container(
      width: 85,
      margin: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.secondaryDark.withOpacity(0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accentGold.withOpacity(0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.accentGold, size: 30),
              SizedBox(height: 8),
              Text(
                label.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textWhite,

                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- بقية الودجت السابقة (أبقيناها بنفس الستايل لتناسق الألوان) ---
  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 180,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/makkah.jpg'),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.2), AppColors.primaryDark],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
          ),
        ),
        // Positioned(bottom: 30, right: 30, child: DigitalClockWidget()),
      ],
    );
  }

  Widget _buildPrayerAndHijriCard(PrayerController controller) {
    final prayers = controller.prayerModel?.timings;
    final city = controller.prayerModel?.city ?? "جاري تحديد الموقع...".tr;
    final hijri = controller.prayerModel?.hijriDate ?? "--";
    final greg = controller.prayerModel?.gregorianDate ?? "--";

    return Container(
      margin: EdgeInsets.all(20),
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.secondaryDark, AppColors.primaryDark],
        ),
        border: Border.all(
          color: AppColors.accentGold.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PrayerTimesPage(controller: controller),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                // الصف العلوي: الإشعار والموقع
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.notifications_active_outlined,
                      color: AppColors.accentGold.withOpacity(0.8),
                      size: 22,
                    ),
                    Row(
                      children: [
                        Text(
                          city,
                          style: TextStyle(
                            color: AppColors.textGrey,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        SizedBox(width: 5),
                        Icon(
                          Icons.location_on,
                          color: AppColors.accentGold,
                          size: 16,
                        ),
                      ],
                    ),
                  ],
                ),
                Spacer(),

                // المنتصف: العداد التنازلي والتاريخ
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3,
                      child: controller.isLoading
                          ? SizedBox(
                              height: 40,
                              width: 40,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: CircularProgressIndicator(
                                  color: AppColors.accentGold,
                                  strokeWidth: 2, // سماكة صغيرة لتناسب التصميم
                                ),
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'باقي لـ ${controller.nextPrayerName}'.tr,
                                  style: TextStyle(
                                    color: AppColors.accentGold.withOpacity(
                                      0.9,
                                    ),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  controller.remainingTime,
                                  style: TextStyle(
                                    color: AppColors.textWhite,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                    ),
                    // فاصل عمودي
                    Container(
                      height: 50,
                      width: 1,
                      color: AppColors.accentGold.withOpacity(0.15),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.isLoading ? "جاري التحميل...".tr : hijri,
                            style: TextStyle(
                              color: AppColors.accentGold,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            controller.isLoading ? "--/--/----" : greg,
                            style: TextStyle(
                              color: AppColors.textGrey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Spacer(),

                Divider(
                  color: AppColors.accentGold.withOpacity(0.1),
                  thickness: 1,
                ),
                SizedBox(height: 10),

                // الأسفل: شريط الصلوات
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildPrayerItem(
                      'الفجر',
                      controller.isLoading
                          ? '--:--'
                          : (prayers?['Fajr'] ?? '--:--'),
                      !controller.isLoading &&
                          controller.nextPrayerName == 'الفجر',
                    ),
                    _buildPrayerItem(
                      'الظهر',
                      controller.isLoading
                          ? '--:--'
                          : (prayers?['Dhuhr'] ?? '--:--'),
                      !controller.isLoading &&
                          controller.nextPrayerName == 'الظهر',
                    ),
                    _buildPrayerItem(
                      'العصر',
                      controller.isLoading
                          ? '--:--'
                          : (prayers?['Asr'] ?? '--:--'),
                      !controller.isLoading &&
                          controller.nextPrayerName == 'العصر',
                    ),
                    _buildPrayerItem(
                      'المغرب',
                      controller.isLoading
                          ? '--:--'
                          : (prayers?['Maghrib'] ?? '--:--'),
                      !controller.isLoading &&
                          controller.nextPrayerName == 'المغرب',
                    ),
                    _buildPrayerItem(
                      'العشاء',
                      controller.isLoading
                          ? '--:--'
                          : (prayers?['Isha'] ?? '--:--'),
                      !controller.isLoading &&
                          controller.nextPrayerName == 'العشاء',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // دالة بناء عنصر الصلاة الصغير مع تمييز الصلاة القادمة
  Widget _buildPrayerItem(String label, String time, bool isNext) {
    return Column(
      children: [
        Text(
          label.tr,
          style: TextStyle(
            color: isNext ? AppColors.accentGold : AppColors.textGrey,
            fontSize: 13,
            fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        SizedBox(height: 6),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: isNext
                ? AppColors.accentGold.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isNext
                  ? AppColors.accentGold.withOpacity(0.5)
                  : Colors.transparent,
              width: 0.5,
            ),
          ),
          child: Text(
            time,
            style: TextStyle(
              color: isNext
                  ? AppColors.textWhite
                  : AppColors.textGrey.withOpacity(0.7),
              fontSize: 13,
              fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
