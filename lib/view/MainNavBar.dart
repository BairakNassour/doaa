import 'dart:async';
import 'package:doaa/component/ad.dart';
import 'package:doaa/component/adsKeys.dart';
import 'package:doaa/component/app_colors.dart';
import 'package:doaa/view/HomePage.dart';
import 'package:doaa/view/HomePage/QuranPage.dart';
import 'package:doaa/view/SettingsPage.dart';
import 'package:doaa/view/SupplicationsPage.dart';
import 'package:doaa/view/friday/HomePageFriday.dart';
import 'package:doaa/view/hisn/hisn_main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> with WidgetsBindingObserver {
  int _selectedIndex = 0;

  // إعدادات إعلان فتح التطبيق (App Open Ad)
  AppOpenAd? _appOpenAd;
  bool _isAdLoaded = false;
  bool _isAdLoading = false;
  bool _isShowingAd = false; // لمنع تداخل الشاشات أثناء عرض الإعلان
  
  // متغير لحفظ وقت آخر ظهور للإعلان
  DateTime? _lastAdShownTime;

  final List<Widget> _pages = [
    HomePage(),
    SupplicationsPage(),
    QuranPage(),
    FridayMainPage(),
    HisnMainPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    // تسجيل مراقب حالة التطبيق (Foreground / Background)
    WidgetsBinding.instance.addObserver(this);
    
    // تحميل وعرض الإعلان عند فتح التطبيق لأول مرة
    if (isadactivitaed) {
      _loadAppOpenAd(showImmediately: true);
    }
  }

  @override
  void dispose() {
    // إزالة مراقب الحالة والتخلص من الإعلان
    WidgetsBinding.instance.removeObserver(this);
    _appOpenAd?.dispose();
    super.dispose();
  }

  // الاستماع لتغيرات حالة التطبيق (الخروج للرئيسية والعودة)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && isadactivitaed) {
      // التحقق مما إذا مرت 5 دقائق منذ آخر عرض للإعلان
      if (_shouldShowAd()) {
        if (_isAdLoaded && _appOpenAd != null) {
          _showAdOnAppOpen();
        } else {
          _loadAppOpenAd(showImmediately: true);
        }
      }
    }
  }

  // دالة التحقق من شرط الـ 5 دقائق
  bool _shouldShowAd() {
    if (_lastAdShownTime == null) return true;
    final difference = DateTime.now().difference(_lastAdShownTime!);
    return difference.inMinutes >= 5;
  }

  // دالة تحميل إعلان فتح التطبيق
  void _loadAppOpenAd({bool showImmediately = false}) {
    if (_isAdLoading || _appOpenAd != null || _isShowingAd) return;

    _isAdLoading = true;

    AppOpenAd.load(
      adUnitId: AdHelper.appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _appOpenAd = ad;
            _isAdLoaded = true;
            _isAdLoading = false;
          });

          if (showImmediately && _shouldShowAd()) {
            _showAdOnAppOpen();
          }
        },
        onAdFailedToLoad: (error) {
          debugPrint('فشل تحميل إعلان فتح التطبيق: $error');
          if (!mounted) return;
          setState(() {
            _isAdLoaded = false;
            _isAdLoading = false;
            _appOpenAd = null;
          });
        },
      ),
    );
  }

  // دالة إظهار إعلان فتح التطبيق
  void _showAdOnAppOpen() {
    if (_appOpenAd != null && !_isShowingAd) {
      _isShowingAd = true;

      _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _appOpenAd = null;
          _isAdLoaded = false;
          _isShowingAd = false;
          _lastAdShownTime = DateTime.now(); // تحديث وقت آخر ظهور
          _loadAppOpenAd(); // إعادة التحميل مسبقاً للمرة القادمة
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _appOpenAd = null;
          _isAdLoaded = false;
          _isShowingAd = false;
          _loadAppOpenAd();
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
              SystemNavigator.pop();
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
                _buildNavItem(Icons.calendar_month, 'الجمعة'.tr, 3),
                _buildNavItem(Icons.wallet_giftcard_outlined, 'حصن المسلم'.tr, 4),
                _buildNavItem(Icons.settings, 'إعدادات'.tr, 5),
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