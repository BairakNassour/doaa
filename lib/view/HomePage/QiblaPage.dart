import 'dart:math' as math;
import 'dart:io' show Platform; // تم إضافة الاستيراد لمعرفة نوع النظام
import 'package:doaa/component/ad.dart';
import 'package:doaa/component/adsKeys.dart';
import 'package:doaa/component/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // تم إضافة حزمة الإعلانات

class QiblaPage extends StatefulWidget {
  const QiblaPage({super.key});

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> {
  bool _isVibrated = false;
  double? qiblaAngle; // الزاوية المحسوبة ديناميكياً
  String userCity = "جاري تحديد الموقع...";
  bool isLoading = true;

  // معرفات الإعلانات التجريبية

  // متغيرات إعلان البانر
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  @override
  @override
  void initState() {
    super.initState();
    _getPermissionAndLocation();

    // تحميل الإعلان فقط إذا كانت الإعلانات مفعلة
    if (isadactivitaed) {
      _loadBannerAd();
    }
  }

  // دالة تحميل إعلان البانر
  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          print('Failed to load a banner ad: ${err.message}');
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );

    _bannerAd!.load();
  }

  // دالة طلب الصلاحيات وحساب زاوية القبلة بناءً على الموقع
  Future<void> _getPermissionAndLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => userCity = "خدمة الموقع معطلة");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => userCity = "تم رفض الصلاحية");
        return;
      }
    }

    // الحصول على الإحداثيات الحالية
    Position position = await Geolocator.getCurrentPosition();

    // حساب زاوية القبلة باستخدام معادلة الكرة الأرضية (Haversine/Spherical Geometry)
    double lat = position.latitude;
    double lng = position.longitude;

    // إحداثيات الكعبة المشرفة
    double makkahLat = 21.422487;
    double makkahLng = 39.826206;

    double diffLng = (makkahLng - lng) * (math.pi / 180);
    double latRad = lat * (math.pi / 180);
    double mLatRad = makkahLat * (math.pi / 180);

    double y = math.sin(diffLng);
    double x =
        math.cos(latRad) * math.tan(mLatRad) -
        math.sin(latRad) * math.cos(diffLng);

    double qAngle = math.atan2(y, x) * (180 / math.pi);

    setState(() {
      qiblaAngle = (qAngle + 360) % 360;
      userCity = "موقعك الحالي"; // يمكنك هنا استخدام geocoding لجلب اسم المدينة
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _bannerAd
        ?.dispose(); // تنظيف مساحة الإعلان من الذاكرة لحمايتها من الـ Memory Leak
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.secondaryDark,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "القبلة".tr,
            style: TextStyle(color: AppColors.textWhite),
          ),
        ),
        body: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFC0A080)),
              )
            : Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: StreamBuilder<CompassEvent>(
                    stream: FlutterCompass.events,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const SizedBox();

                      double? direction = snapshot.data?.heading;
                      if (direction == null)
                        return const Center(child: Text("الحساس غير مدعوم"));

                      // حساب الفرق بين اتجاه الهاتف وزاوية القبلة المحسوبة
                      double diff = (qiblaAngle! - direction) % 360;
                      if (diff > 180) diff -= 360;
                      if (diff < -180) diff += 360;

                      bool isAligned = diff.abs() < 5;

                      if (isAligned && !_isVibrated) {
                        HapticFeedback.heavyImpact();
                        _isVibrated = true;
                      } else if (!isAligned) {
                        _isVibrated = false;
                      }

                      double compassBackgroundAngle =
                          (direction * (math.pi / 180) * -1);

                      return Column(
                        children: [
                          const SizedBox(height: 30),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  userCity,
                                  style: TextStyle(color: AppColors.textWhite),
                                ),
                                Text(
                                  isAligned
                                      ? "مواجه للقبلة".tr
                                      : "اتجاه القبلة".tr,
                                  style: TextStyle(
                                    color: isAligned
                                        ? Colors.greenAccent
                                        : AppColors.textWhite,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(flex: 2),
                          Image.asset(
                            'assets/kaba.png',
                            width: 70,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.mosque,
                              color: Color(0xFFC0A080),
                              size: 60,
                            ),
                          ),
                          const SizedBox(height: 80),

                          // البوصلة
                          Center(
                            child: Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                Transform.rotate(
                                  angle: compassBackgroundAngle,
                                  child: _buildRotatingCompassBackground(
                                    qiblaAngle!,
                                  ),
                                ),
                                _buildStaticAlignedPointer(isAligned),
                              ],
                            ),
                          ),
                          const Spacer(flex: 3),
                          _buildBottomInstruction(diff, isAligned),
                          const Spacer(),
                          const Text(
                            "✿ ✿ ✿",
                            style: TextStyle(
                              color: Color(0xFFC0A080),
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      );
                    },
                  ),
                ),
              ),
        // إظهار إعلان البانر في أسفل الشاشة عند تحميله بنجاح
        bottomNavigationBar: _isBannerAdReady
            ? SizedBox(
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  // --- باقي الـ Widgets المساعدة ---

  Widget _buildRotatingCompassBackground(double qAngle) {
    return Container(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (var i = 0; i < 60; i++)
            Transform.rotate(
              angle: (i * 6) * (math.pi / 180),
              child: VerticalDivider(
                color: const Color(0xFFC0A080),
                thickness: i % 15 == 0 ? 3 : 1.5,
                indent: 0,
                endIndent: 205,
              ),
            ),
          // علامة القبلة
          Transform.rotate(
            angle: qAngle * (math.pi / 180),
            child: Container(
              height: 220,
              alignment: Alignment.topCenter,
              child: const Icon(
                Icons.circle,
                color: Color(0xFFC0A080),
                size: 10,
              ),
            ),
          ),
          _directionLabelEnglish("N", 0),
          _directionLabelEnglish("E", 90),
          _directionLabelEnglish("S", 180),
          _directionLabelEnglish("W", 270),
        ],
      ),
    );
  }

  Widget _directionLabelEnglish(String label, double angle) {
    return Transform.rotate(
      angle: angle * (math.pi / 180),
      child: Container(
        height: 250,
        alignment: Alignment.topCenter,
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStaticAlignedPointer(bool isAligned) {
    return Container(
      height: 200,
      alignment: Alignment.topCenter,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          if (isAligned)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.greenAccent.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
          Icon(
            Icons.navigation_rounded,
            size: 45,
            color: isAligned ? Colors.greenAccent : const Color(0xFFC0A080),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInstruction(double offset, bool isAligned) {
    return Column(
      children: [
        Text(
          isAligned ? "0°" : "${offset.abs().toStringAsFixed(0)}°",
          style: TextStyle(
            color: isAligned ? Colors.greenAccent : AppColors.textWhite,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          isAligned
              ? "أنت مواجه للقبلة تماماً".tr
              : "${"تحرك إلى ".tr}${offset > 0 ? "اليسار".tr : "اليمين".tr}",
          style: TextStyle(color: AppColors.textWhite, fontSize: 16),
        ),
      ],
    );
  }
}
