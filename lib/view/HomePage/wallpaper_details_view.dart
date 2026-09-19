import 'package:doaa/model/wallpaper_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:async_wallpaper/async_wallpaper.dart';
import 'package:doaa/component/app_colors.dart';
import 'package:doaa/controller/wallpaper_controller.dart';

class WallpaperDetailsView extends StatefulWidget {
  final int initialIndex;
  final List<WallpaperModel> wallpapers;

  const WallpaperDetailsView({
    super.key,
    required this.initialIndex,
    required this.wallpapers,
  });

  @override
  State<WallpaperDetailsView> createState() => _WallpaperDetailsViewState();
}

class _WallpaperDetailsViewState extends State<WallpaperDetailsView> {
  late PageController _pageController;
  late int _currentIndex;
  int _swipeCount = 0;
  final WallpaperController controller = Get.find<WallpaperController>();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  // حفظ الصورة في معرض الصور
  Future<void> _saveToGallery(String url, dynamic id) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await Gal.putImageBytes(response.bodyBytes);
        
        controller.incrementDownload(id);
        
        Get.back();
        Get.snackbar(
          "تم التنزيل".tr,
          "تم حفظ الصورة بنجاح في المعرض".tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primaryDark,
          colorText: AppColors.accentGold,
          margin: const EdgeInsets.all(12),
        );
      } else {
        throw Exception("فشل التنزيل");
      }
    } catch (e) {
      Get.back();
      Get.snackbar("خطأ".tr, "فشل حفظ الصورة في المعرض".tr,
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // تعيين الصورة كخلفية للجوال
  Future<void> _setWallpaper(String url) async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final WallpaperResult result = await AsyncWallpaper.setWallpaper(
        WallpaperRequest(
          target: WallpaperTarget.home,
          sourceType: WallpaperSourceType.url,
          source: url,
        ),
      );

      Get.back();

      if (result == WallpaperResult.success()) {
        Get.snackbar(
          "نجاح".tr,
          "تم تعيين خلفية الشاشة بنجاح".tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.primaryDark,
          colorText: AppColors.accentGold,
          margin: const EdgeInsets.all(12),
        );
      } else {
        Get.snackbar(
          "إلغاء".tr,
          "لم يتم تعيين الخلفية".tr,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
      }
    } catch (e) {
      Get.back();
      Get.snackbar(
        "خطأ".tr,
        "تعذر تعيين الخلفية: $e".tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // عرض الصور بالسحب يمين ويسار
          PageView.builder(
            controller: _pageController,
            itemCount: widget.wallpapers.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
                _swipeCount++;
              });

              // إظهار إعلان عند السحب كل 6 صور
              if (_swipeCount > 0 && _swipeCount % 6 == 0) {
                controller.showInterstitialAndAction(() {});
              }
            },
            itemBuilder: (context, index) {
              return InteractiveViewer(
                minScale: 0.5,
                maxScale: 3.5,
                child: Image.network(
                  widget.wallpapers[index].imageUrl,
                  fit: BoxFit.contain,
                ),
              );
            },
          ),

          // خيارات التحميل والتعيين (تم تصحيح ترتيب Positioned مع SafeArea)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // زر التحميل
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accentGold,
                      foregroundColor: AppColors.primaryDark,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.file_download_outlined),
                    label: Text("تحميل".tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      final wallpaper = widget.wallpapers[_currentIndex];
                      controller.showInterstitialAndAction(() {
                        _saveToGallery(wallpaper.imageUrl, wallpaper.id);
                      });
                    },
                  ),

                  // زر تعيين خلفية
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: AppColors.accentGold,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: AppColors.accentGold.withOpacity(0.5)),
                      ),
                    ),
                    icon: const Icon(Icons.wallpaper),
                    label: Text("تعيين كخلفية".tr, style: const TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      final wallpaper = widget.wallpapers[_currentIndex];
                      _setWallpaper(wallpaper.imageUrl);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}