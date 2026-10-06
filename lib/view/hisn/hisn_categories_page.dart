import 'package:doaa/controller/controllers/hisn_controller.dart';
import 'package:doaa/view/hisn/hisn_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doaa/component/app_colors.dart';
import 'package:doaa/model/hisn_model.dart';
class HisnCategoriesPage extends StatelessWidget {
  final bool showOnlyFavorites;

  const HisnCategoriesPage({super.key, this.showOnlyFavorites = false});

  @override
  Widget build(BuildContext context) {
    final HisnController controller = Get.find<HisnController>();

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryDark,
        elevation: 0,
        centerTitle: true,
        title: Text(
          showOnlyFavorites ? "المفضلة" : "أبواب حصن المسلم",
          style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textWhite),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        List<HisnCategory> list = showOnlyFavorites
            ? controller.categories.where((c) => controller.favorites.contains(c.id)).toList()
            : controller.filteredCategories;

        if (list.isEmpty) {
          return Center(
            child: Text(
              showOnlyFavorites ? "لا توجد أذكار في المفضلة" : "لا توجد نتائج",
              style: TextStyle(color: AppColors.textWhite.withOpacity(0.6)),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final category = list[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.secondaryDark,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFC0A080).withOpacity(0.15)),
              ),
              child: ListTile(
                title: Text(
                  category.name,
                  style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "${category.items.length} أذكار",
                  style: TextStyle(color: AppColors.textWhite.withOpacity(0.5), fontSize: 12),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        controller.favorites.contains(category.id)
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        color: const Color(0xFFC0A080),
                      ),
                      onPressed: () => controller.toggleFavorite(category.id),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFC0A080), size: 16),
                  ],
                ),
                onTap: () => Get.to(() => HisnDetailPage(category: category)),
              ),
            );
          },
        );
      }),
    );
  }
}