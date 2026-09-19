import 'dart:async';
import 'package:doaa/component/ad.dart';
import 'package:doaa/component/adsKeys.dart';
import 'package:doaa/component/app_colors.dart';
import 'package:doaa/view/HomePage.dart';
import 'package:doaa/view/HomePage/QuranPage.dart';
import 'package:doaa/view/SettingsPage.dart';
import 'package:doaa/view/SupplicationsPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;

  // إعدادات إعلان فتح التطبيق (App Open Ad)
  AppOpenAd? _appOpenAd;
  bool _isAdLoaded = false;
  bool _hasShownAppOpenAd = false; // لمنع تكرار الإعلان خلال نفس الجلسة

  final List<Widget> _pages = [
    HomePage(),
    SupplicationsPage(),
    QuranPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    
    // تحميل إعلان الفتح وعرضه فقط إذا كانت الإعلانات مفعلة
    if (isadactivitaed) {
      _loadAppOpenAd();
    }
  }

  // دالة تحميل إعلان فتح التطبيق وعرضه لمرة واحدة
  void _loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: AdHelper.appOpenAdUnitId, // معرف تجريبي لـ App Open Ad من جوجل
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() {
            _appOpenAd = ad;
            _isAdLoaded = true;
          });

          // عرض الإعلان مباشرة عند أول فتح للمرحلة/التطبيق
          _showAdOnAppOpen();
        },
        onAdFailedToLoad: (error) {
          debugPrint('فشل تحميل إعلان فتح التطبيق: $error');
          _isAdLoaded = false;
          _appOpenAd = null;
        },
      ),
    );
  }

  // دالة إظهار إعلان فتح التطبيق
  void _showAdOnAppOpen() {
    if (!_hasShownAppOpenAd && _appOpenAd != null) {
      _hasShownAppOpenAd = true;

      _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _appOpenAd = null;
          _isAdLoaded = false;
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _appOpenAd = null;
          _isAdLoaded = false;
        },
      );

      _appOpenAd!.show();
    }
  }

  // مربع حوار تأكيد الخروج
  Future<void> _showExitDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.secondaryDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.accentGold.withOpacity(0.2)),
        ),
        title: Text(
          'تأكيد الخروج'.tr,
          textAlign: TextAlign.right,
          style: TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'هل أنت متأكد أنك تريد إغلاق التطبيق؟'.tr,
          textAlign: TextAlign.right,
          style: const TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('إلغاء'.tr, style: const TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentGold,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              SystemNavigator.pop(); // الخروج المباشر دون إعلانات
            },
            child: Text(
              'خروج'.tr,
              style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _appOpenAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (_selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
        } else {
          await _showExitDialog(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.secondaryDark,
        body: _pages[_selectedIndex],
        bottomNavigationBar: SafeArea(
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 15),
            height: 65,
            decoration: BoxDecoration(
              color: AppColors.secondaryDark,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.accentGold.withOpacity(0.1), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(Icons.home_filled, 'الرئيسية'.tr, 0),
                _buildNavItem(Icons.menu_book, 'أدعية'.tr, 1),
                _buildNavItem(Icons.book, 'القرآن'.tr, 2),
                _buildNavItem(Icons.settings, 'إعدادات'.tr, 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() => _selectedIndex = index);
      },
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 26,
            color: isSelected ? AppColors.accentGold : AppColors.textWhite,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? AppColors.accentGold : AppColors.textWhite,
            ),
          ),
        ],
      ),
    );
  }
}