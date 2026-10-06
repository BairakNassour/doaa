import 'package:doaa/controller/controllers/hisn_controller.dart';
import 'package:doaa/model/hisn_model.dart';
import 'package:doaa/view/hisn/hisn_categories_page.dart';
import 'package:doaa/view/hisn/hisn_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doaa/component/app_colors.dart';

class HisnMainPage extends StatelessWidget {
  const HisnMainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final HisnController controller = Get.put(HisnController());

    return Scaffold(
      backgroundColor: AppColors.secondaryDark,
      body: Stack(
        children: [
          // 1. الخلفية العلوية المتدرجة
          Container(
            height: 240,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF2C5E4A), Color(0xFF1E3A2F)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                        onPressed: () => Get.back(),
                      ),
                      const Spacer(),
                      const Text(
                        "حصن المسلم",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "من أذكار الكتاب والسنة",
                    style: TextStyle(color: Color(0xFFC0A080), fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    "لـ سعيد بن علي بن وهف القحطاني",
                    style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

          // 2. المحتوى الرئيسي القابل للتمرير
          CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 180)),
              SliverFillRemaining(
                hasScrollBody: true,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  ),
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFFC0A080)));
                    }

                    return ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        // شريط البحث
                        TextField(
                          onChanged: controller.filterSearch,
                          style: TextStyle(color: AppColors.textWhite),
                          decoration: InputDecoration(
                            hintText: "ابحث في حصن المسلم...",
                            hintStyle: TextStyle(color: AppColors.textWhite.withOpacity(0.4)),
                            prefixIcon: const Icon(Icons.search, color: Color(0xFFC0A080)),
                            filled: true,
                            fillColor: AppColors.secondaryDark,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // اختصارات التصفح (المفضلة، تصفح، تقدمي...)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildQuickAction(
                              icon: Icons.star_border_rounded,
                              title: "المفضلة",
                              onTap: () => Get.to(() => const HisnCategoriesPage(showOnlyFavorites: true)),
                            ),
                            _buildQuickAction(
                              icon: Icons.history_rounded,
                              title: "أكمل من حيث توقفت",
                              onTap: () {},
                            ),
                            _buildQuickAction(
                              icon: Icons.menu_book_rounded,
                              title: "تصفح الأذكار",
                              onTap: () => Get.to(() => const HisnCategoriesPage()),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),

                        // عنوان القائمة
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "أبواب الكتاب",
                              style: TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () => Get.to(() => const HisnCategoriesPage()),
                              child: const Text("عرض الكل", style: TextStyle(color: Color(0xFFC0A080))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // قائمة الأبواب الرئيسية
                        ...controller.filteredCategories.take(6).map((category) => _buildCategoryTile(category)),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({required IconData icon, required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondaryDark,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFFC0A080).withOpacity(0.2)),
            ),
            child: Icon(icon, color: const Color(0xFFC0A080), size: 26),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(HisnCategory category) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.secondaryDark,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFC0A080).withOpacity(0.1)),
      ),
      child: ListTile(
        title: Text(
          category.name,
          style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          "${category.items.length} أذكار",
          style: TextStyle(color: AppColors.textWhite.withOpacity(0.5), fontSize: 12),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFC0A080), size: 16),
        onTap: () => Get.to(() => HisnDetailPage(category: category)),
      ),
    );
  }
}