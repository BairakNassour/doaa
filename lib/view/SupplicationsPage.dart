import 'package:doaa/component/app_colors.dart';
import 'package:doaa/component/generalBoxDecoration.dart';
import 'package:doaa/controller/dua_controller.dart';
import 'package:doaa/model/dua_model.dart';
import 'package:doaa/view/dua_flip_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SupplicationsPage extends StatefulWidget {
  const SupplicationsPage({super.key});

  @override
  State<SupplicationsPage> createState() => _SupplicationsPageState();
}

class _SupplicationsPageState extends State<SupplicationsPage> {
  final DuaController _controller = Get.put(DuaController());

  late Future<List<DuaCategory>> _generalCategoriesFuture;
  late Future<bool> _morningStatusFuture;
  late Future<bool> _eveningStatusFuture;

  @override
  void initState() {
    super.initState();
    // جلب الأدعية العامة وحالة أذكار الصباح والمساء بالتوازي
    _generalCategoriesFuture = _controller.fetchAllData('general');
    

    _generalCategoriesFuture
        .then((categories) {
          print('Total categories: ${categories.length}');
          print("ssssssssssssss");
          for (var category in categories) {
            print(category.type); // أو print(category.name);
          }
        })
        .catchError((error) {
          print('Error fetching data: $error');
        });
    _morningStatusFuture = _controller.checkCategoryStatus('morning');
    _eveningStatusFuture = _controller.checkCategoryStatus('evening');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryDark,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryDark,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'الأدعية والأذكار'.tr,
          style: TextStyle(
            color: AppColors.accentGold,
            fontWeight: FontWeight.bold,
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Container(
        decoration: getBoxDecoration(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                'أذكار المسلم اليومية'.tr,
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),

              // ☀️ 🌙 قسم أذكار الصباح والمساء (يفحص حالة التفعيل من السيرفر مباشرة لكل قسم)
              Row(
                children: [
                  FutureBuilder<bool>(
                    future: _morningStatusFuture,
                    builder: (context, snapshot) {
                      final bool isActive = snapshot.data ?? true;
                      return _buildDailyDhikrCard(
                        context,
                        'أذكار الصباح',
                        Icons.wb_sunny_rounded,
                        '05:00 ص',
                        'morning',
                        isActive: isActive,
                      );
                    },
                  ),
                  const SizedBox(width: 15),
                  FutureBuilder<bool>(
                    future: _eveningStatusFuture,
                    builder: (context, snapshot) {
                      final bool isActive = snapshot.data ?? true;
                      return _buildDailyDhikrCard(
                        context,
                        'أذكار المساء',
                        Icons.nightlight_round,
                        '05:00 م',
                        'evening',
                        isActive: isActive,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // 📜 قسم التصنيفات العامة
              Text(
                'تصنيفات الأدعية العامة'.tr,
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),

              FutureBuilder<List<DuaCategory>>(
                future: _generalCategoriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(
                          color: AppColors.accentGold,
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'حدث خطأ أثناء تحميل البيانات'.tr,
                        style: TextStyle(color: AppColors.textWhite),
                      ),
                    );
                  }

                  final generalCategories = snapshot.data ?? [];

                  if (generalCategories.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'لا توجد تصنيفات حالياً'.tr,
                          style: TextStyle(color: AppColors.textWhite),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: generalCategories.length,
                    itemBuilder: (context, index) {
                      final category = generalCategories[index];
                      print("aaaaaa");
                       print(category.type);
                      return _buildSupplicationCategory(
                        context,
                        category.name,
                        "أدعية نبوية مأثورة",
                        Icons.auto_awesome_motion,
                        category.type,
                        categoryName: category.name,
                        isActive: category
                            .isActive, // الاعتماد المباشر على زر التفعيل
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ويدجت كارد أذكار الصباح والمساء
  Widget _buildDailyDhikrCard(
    BuildContext context,
    String title,
    IconData icon,
    String time,
    String type, {
    required bool isActive,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (!isActive) {
            _showDisabledSnackBar(context, title);
          } else {
            _navigateToFlip(context, title, type);
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.secondaryDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive
                  ? AppColors.accentGold.withOpacity(0.3)
                  : Colors.orange.withOpacity(0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isActive ? AppColors.accentGold : Colors.orange,
                size: 40,
              ),
              const SizedBox(height: 12),
              Text(
                title.tr,
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 5),
              if (!isActive)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'قريباً',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                Text(
                  time,
                  style: TextStyle(
                    color: AppColors.accentGold.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ويدجت تصنيفات الأدعية
  Widget _buildSupplicationCategory(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    String type, {
    String? categoryName,
    required bool isActive,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: AppColors.secondaryDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isActive
              ? AppColors.accentGold
              : Colors.orange.withOpacity(0.5),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (isActive ? AppColors.accentGold : Colors.orange)
                .withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isActive ? AppColors.accentGold : Colors.orange,
          ),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                title.tr,
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (!isActive) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange.withOpacity(0.5)),
                ),
                child: const Text(
                  'قريباً',
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
        subtitle: Text(
          !isActive ? 'سيكون متاحاً قريباً إن شاء الله' : subtitle.tr,
          style: TextStyle(
            color: AppColors.textWhite.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        trailing: Icon(
          !isActive ? Icons.lock_clock_rounded : Icons.arrow_forward_ios,
          color: !isActive ? Colors.orange : AppColors.accentGold,
          size: !isActive ? 20 : 16,
        ),
        onTap: () {
          if (!isActive) {
            _showDisabledSnackBar(context, title);
          } else {
            _navigateToFlip(context, title, type, categoryName: categoryName);
          }
        },
      ),
    );
  }

  void _showDisabledSnackBar(BuildContext context, String title) {
    Get.snackbar(
      'تنبيه',
      'قسم $title مغلق حالياً وسيكون متاحاً قريباً',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.withOpacity(0.8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(15),
      duration: const Duration(seconds: 2),
    );
  }

  void _navigateToFlip(
    BuildContext context,
    String title,
    String type, {
    String? categoryName,
  }) {
    Get.to(
      () => DuaFlipView(type: type, title: title, categoryName: categoryName),
    );
  }
}
