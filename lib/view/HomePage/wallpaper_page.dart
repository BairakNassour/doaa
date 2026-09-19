import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:doaa/component/app_colors.dart';
import 'package:doaa/controller/wallpaper_controller.dart';
import 'package:doaa/model/wallpaper_model.dart';
import 'package:doaa/component/adsKeys.dart';
import 'package:doaa/component/ad.dart'; // استيراد ملف الإعلانات لمعرفة حالة isadactivitaed
import 'wallpaper_details_view.dart';

class WallpaperPage extends StatelessWidget {
  const WallpaperPage({super.key});

  @override
  Widget build(BuildContext context) {
    final WallpaperController controller = Get.put(WallpaperController());

    return Scaffold(
      backgroundColor: AppColors.secondaryDark,
      body: SafeArea(
        child: Column(
          children: [
            // هيدر التطبيق
            _buildHeader(),

            // شبكة الصور مع الإعلانات المدمجة (حسب حالة isadactivitaed)
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.accentGold,
                    ),
                  );
                }

                if (controller.wallpapers.isEmpty) {
                  return Center(
                    child: Text(
                      "لا توجد خلفيات متاحة حالياً".tr,
                      style: TextStyle(
                        color: AppColors.textWhite.withOpacity(0.6),
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                // إذا كانت الإعلانات مفعلة، نحسب الإعلانات المدمجة كل 5 عناصر، وإلا يكون العدد هو عدد الصور فقط
                int totalItems = isadactivitaed
                    ? controller.wallpapers.length + (controller.wallpapers.length ~/ 4)
                    : controller.wallpapers.length;

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: totalItems,
                  itemBuilder: (context, index) {
                    // إذا كانت الإعلانات مفعلة، نظهر إعلاناً كل 5 بطاقات
                    if (isadactivitaed && (index + 1) % 5 == 0) {
                      return const InlineNativeAdCard();
                    }

                    // حساب الـ index الصحيح للصورة بناءً على تفعيل الإعلانات من عدمه
                    int realImageIndex = isadactivitaed ? index - (index ~/ 5) : index;
                    
                    if (realImageIndex >= controller.wallpapers.length) {
                      return const SizedBox.shrink();
                    }

                    final wallpaper = controller.wallpapers[realImageIndex];
                    return _buildWallpaperCard(controller, wallpaper, realImageIndex);
                  },
                );
              }),
            ),

            // إعلان البانر السفلي (يظهر فقط إذا كان isadactivitaed == true)
            if (isadactivitaed)
              Obx(() {
                if (controller.isBannerAdReady.value &&
                    controller.bannerAd != null) {
                  return Container(
                    width: controller.bannerAd!.size.width.toDouble(),
                    height: controller.bannerAd!.size.height.toDouble(),
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(top: 4),
                    child: AdWidget(ad: controller.bannerAd!),
                  );
                }
                return const SizedBox.shrink();
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Get.back(),
          ),
          Column(
            children: [
              Text(
                "معرض الخلفيات".tr,
                style: TextStyle(
                  color: AppColors.accentGold,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'QuranFont',
                ),
              ),
              const SizedBox(height: 2),
              Container(
                width: 30,
                height: 2,
                decoration: BoxDecoration(
                  color: AppColors.accentGold,
                  borderRadius: BorderRadius.circular(2),
                ),
              )
            ],
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildWallpaperCard(
      WallpaperController controller, WallpaperModel wallpaper, int realIndex) {
    return GestureDetector(
      onTap: () {
        Get.to(() => WallpaperDetailsView(
              initialIndex: realIndex,
              wallpapers: controller.wallpapers,
            ));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.accentGold.withOpacity(0.2),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.network(
                  wallpaper.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: AppColors.primaryDark,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accentGold.withOpacity(0.4),
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.primaryDark,
                    child: const Icon(Icons.broken_image_outlined, color: Colors.white38),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.85),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.downloading_rounded,
                            color: AppColors.textWhite.withOpacity(0.7), size: 14),
                        const SizedBox(width: 4),
                        Text(
                          "${wallpaper.downloadsCount}",
                          style: TextStyle(
                            color: AppColors.textWhite.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGold,
                        foregroundColor: AppColors.primaryDark,
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.file_download_outlined, size: 18),
                      label: Text(
                        "تحميل".tr,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      onPressed: () {
                        Get.to(() => WallpaperDetailsView(
                              initialIndex: realIndex,
                              wallpapers: controller.wallpapers,
                            ));
                      },
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
}

// أداة إعلان مدمج ضمن المحتوى
class InlineNativeAdCard extends StatefulWidget {
  const InlineNativeAdCard({super.key});

  @override
  State<InlineNativeAdCard> createState() => _InlineNativeAdCardState();
}

class _InlineNativeAdCardState extends State<InlineNativeAdCard> {
  BannerAd? _inlineAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadInlineAd();
  }

  void _loadInlineAd() {
    _inlineAd = BannerAd(
      adUnitId: AdHelper.nativeOrInlineAdUnitId,
      size: AdSize.mediumRectangle,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    _inlineAd?.load();
  }

  @override
  void dispose() {
    _inlineAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAdLoaded && _inlineAd != null) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.accentGold.withOpacity(0.3)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: AdWidget(ad: _inlineAd!),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accentGold.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentGold.withOpacity(0.1),
            ),
            child: Icon(Icons.workspace_premium_rounded,
                color: AppColors.accentGold, size: 30),
          ),
          const SizedBox(height: 10),
          Text(
            "إعلان مميز".tr,
            style: TextStyle(
              color: AppColors.textWhite,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}