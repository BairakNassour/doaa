import 'dart:async'; // تم إضافة هذا للاستفادة من الـ Timer
import 'package:doaa/component/ad.dart';
import 'package:doaa/component/adsKeys.dart';
import 'package:doaa/component/app_colors.dart';
import 'package:doaa/controller/allah_names_controller.dart';
import 'package:doaa/model/allah_name_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class NamesOfAllahPage extends StatefulWidget {
  const NamesOfAllahPage({super.key});

  @override
  State<NamesOfAllahPage> createState() => _NamesOfAllahPageState();
}

class _NamesOfAllahPageState extends State<NamesOfAllahPage> {
  final AllahNamesController _controller = AllahNamesController();
  final PageController _pageController = PageController();

  List<AllahName> allNames = [];
  bool isLoading = true;
  int _currentIndex = 0;

  // إعدادات الإعلان المدمج في الكروت
  BannerAd? _cardBannerAd;
  bool _isCardBannerAdReady = false;

  // إعدادات إعلان البنر في الأسفل
  BannerAd? _bottomBannerAd;
  bool _isBottomBannerAdReady = false;

  @override
  @override
void initState() {
  super.initState();
  _loadData();
  
  // التحقق من تفعيل الإعلانات قبل تحميلها
  if (isadactivitaed) {
    _loadCardBannerAd();
    _loadBottomBannerAd();
  }
}

  void _loadCardBannerAd() {
    _cardBannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId, // معرف تجريبي
      request: const AdRequest(),
      size: AdSize.mediumRectangle,
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isCardBannerAdReady = true),
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          _isCardBannerAdReady = false;
        },
      ),
    );
    _cardBannerAd!.load();
  }

  void _loadBottomBannerAd() {
    _bottomBannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId, // معرف تجريبي لبنر الأسفل
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isBottomBannerAdReady = true),
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          _isBottomBannerAdReady = false;
        },
      ),
    );
    _bottomBannerAd!.load();
  }

  void _loadData() async {
    try {
      final names = await _controller.fetchNames();
      setState(() {
        allNames = names;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    _cardBannerAd?.dispose();
    _bottomBannerAd?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'أسماء الله الحسنى'.tr,
          style: TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.accentGold))
          : Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: allNames.isEmpty ? 0 : allNames.length + (allNames.length ~/ 5),
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                      HapticFeedback.selectionClick();
                    },
                    itemBuilder: (context, index) {
                      bool isAd = (index + 1) % 6 == 0;
                      
                      // تم استبدال الكارت القديم بمُكوّن العداد
                      if (isAd) {
                        return AdCardWidget(
                          bannerAd: _cardBannerAd,
                          isAdReady: _isCardBannerAdReady,
                          countdownSeconds: 5, // يمكنك تغيير مدة العداد من هنا (مثلاً 5 ثوانٍ)
                        );
                      }

                      int nameIndex = index - (index ~/ 6);
                      return NameIndividualCard(
                        nameObj: allNames[nameIndex],
                        currentIndex: nameIndex + 1,
                        totalNames: allNames.length,
                      );
                    },
                  ),
                ),

                const SizedBox(height: 5),
                _buildNavigationButtons(),
                const SizedBox(height: 10),

                // ⭐ بنر الإعلان السفلي الثابت
                if (_isBottomBannerAdReady && _bottomBannerAd != null)
                  SafeArea(
                    child: Container(
                      width: _bottomBannerAd!.size.width.toDouble(),
                      height: _bottomBannerAd!.size.height.toDouble(),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: AdWidget(ad: _bottomBannerAd!),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildNavigationButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _pageController.nextPage(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            ),
            icon: Icon(Icons.arrow_back_ios, color: AppColors.textWhite, size: 20),
          ),
          Text("اسحب لعرض التالي", style: TextStyle(color: AppColors.textWhite.withOpacity(0.6), fontSize: 12)),
          IconButton(
            onPressed: () => _pageController.previousPage(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            ),
            icon: Icon(Icons.arrow_forward_ios, color: AppColors.textWhite, size: 20),
          ),
        ],
      ),
    );
  }
}

// ⭐ كارت الإعلان الذكي مع العداد التنازلي ⭐
class AdCardWidget extends StatefulWidget {
  final BannerAd? bannerAd;
  final bool isAdReady;
  final int countdownSeconds;

  const AdCardWidget({
    super.key,
    required this.bannerAd,
    required this.isAdReady,
    this.countdownSeconds = 5,
  });

  @override
  State<AdCardWidget> createState() => _AdCardWidgetState();
}

class _AdCardWidgetState extends State<AdCardWidget> {
  late int _remainingSeconds;
  Timer? _timer;
  bool _showAd = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.countdownSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 1) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
        setState(() => _showAd = true);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.secondaryDark,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.accentGold.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _showAd
            ? (widget.isAdReady && widget.bannerAd != null
                ? Center(child: AdWidget(ad: widget.bannerAd!))
                : Center(
                    child: Text(
                      "إعلان",
                      style: TextStyle(color: AppColors.accentGold, fontSize: 18),
                    ),
                  ))
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.accentGold,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "سيظهر الإعلان خلال",
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.accentGold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.accentGold),
                      ),
                      child: Text(
                        "$_remainingSeconds ثوانٍ",
                        style: TextStyle(
                          color: AppColors.accentGold,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class NameIndividualCard extends StatelessWidget {
  final AllahName nameObj;
  final int currentIndex;
  final int totalNames;

  const NameIndividualCard({
    super.key,
    required this.nameObj,
    required this.currentIndex,
    required this.totalNames,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.secondaryDark,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.accentGold.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppColors.accentGold.withOpacity(0.3)),
                ),
                child: Text(
                  "$currentIndex / $totalNames",
                  style: TextStyle(
                    color: AppColors.accentGold,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SelectableText(
                      nameObj.nameAr,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: AppColors.accentGold,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'QuranFont',
                      ),
                    ),
                    if (nameObj.nameEn.isNotEmpty)
                      Text(
                        nameObj.nameEn,
                        style: TextStyle(
                          color: AppColors.accentGold.withOpacity(0.6),
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(
              color: Color(0xFFC0A080),
              indent: 20,
              endIndent: 20,
              thickness: 0.5,
            ),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Text(
                  nameObj.descriptionAr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 17,
                    height: 1.7,
                    fontFamily: 'MyCustomFont',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}