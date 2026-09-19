import 'package:doaa/component/ad.dart';
import 'package:doaa/component/adsKeys.dart';
import 'package:doaa/component/app_colors.dart';
import 'package:doaa/controller/ProgressController.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'dart:async'; // تم إضافة مكتبة Async من أجل العداد التنازلي
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class TasbihPage extends StatefulWidget {
  TasbihPage({super.key});

  @override
  State<TasbihPage> createState() => _TasbihPageState();
}

class _TasbihPageState extends State<TasbihPage>
    with SingleTickerProviderStateMixin {
  int _counter = 0;
  int _target = 33;
  String _currentDhikr = "سبحان الله";
  final ProgressController _progressController = Get.put(ProgressController());

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // 🔥 متغيرات نظام الحظر والعداد التنازلي
  DateTime? _lastTapTime;
  bool _isBlocked = false;
  int _secondsRemaining = 0;
  Timer? _countdownTimer;

  // متغيرات إعلان البانر
  BannerAd? _bannerAd;
  bool _isBannerAdReady = false;

  final List<String> _adhkir = [
    "سبحان الله",
    "الحمد لله",
    "لا إله إلا الله",
    "الله أكبر",
    "أستغفر الله",
    "اللهم صلِّ على محمد",
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(_animationController);

    if (isadactivitaed) {
      _loadBannerAd();
    }
  }

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
          _isBannerAdReady = false;
          ad.dispose();
        },
      ),
    );
    _bannerAd!.load();
  }

  void _saveProgress({bool resetCounterAfterSave = false}) async {
    if (_counter == 0) return;

    int savedCount = _counter;

    bool success = await _progressController.updateRemoteProgress('tasbih', {
      'dhikr_name': _currentDhikr,
      'count': savedCount,
      'date': DateTime.now().toIso8601String(),
    });

    if (resetCounterAfterSave) {
      setState(() {
        _counter = 0;
      });
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: AppColors.primaryDark),
              const SizedBox(width: 10),
              Text(
                "${'تم حفظ التقدم: '.tr}$savedCount ${' تسبيحة'.tr}",
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.accentGold,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        ),
      );
    }
  }

  void _showTargetReachedDialog() {
    HapticFeedback.heavyImpact();

    Get.defaultDialog(
      title: "أتممت الهدف!".tr,
      titleStyle: TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold),
      backgroundColor: AppColors.secondaryDark,
      content: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Text(
          "${'لقد وصلت إلى '.tr} $_target ${' تسبيحة. هل تريد حفظ هذا التقدم وتصفير العداد أم المتابعة؟'.tr}",
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textWhite, fontSize: 16),
        ),
      ),
      barrierDismissible: false,
      cancel: TextButton(
        onPressed: () => Get.back(),
        child: Text(
          "المتابعة".tr,
          style: TextStyle(color: AppColors.textWhite.withOpacity(0.7), fontSize: 16),
        ),
      ),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accentGold,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () {
          Get.back();
          _saveProgress(resetCounterAfterSave: true);
        },
        child: Text(
          "الحفظ والتصفير".tr,
          style: TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  // 🔥 دالة الحظر والعداد التنازلي
  void _startBlockCountdown() {
    setState(() {
      _isBlocked = true;
      _secondsRemaining = 5;
    });

    _showBlockSnackbar();

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 1) {
        setState(() {
          _secondsRemaining--;
        });
        // _showBlockSnackbar();
      } else {
        timer.cancel();
        if (mounted) {
          setState(() {
            _isBlocked = false;
            _secondsRemaining = 0;
          });
          Get.closeCurrentSnackbar();
        }
      }
    });
  }

  // عرض تنبيه السناك بار مع الثواني المتبقية
  void _showBlockSnackbar() {
    Get.rawSnackbar(
      title: "تم إيقاف التسبيح المؤقت".tr,
      message: "${'يرجى التسبيح بتأنٍ وبخشوع. متبقي لفك الحظر: '.tr} $_secondsRemaining ${'ثوانٍ'.tr}",
      backgroundColor: AppColors.accentGold,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 1),
      isDismissible: false,
      margin: const EdgeInsets.all(15),
      borderRadius: 10,
      icon: const Icon(Icons.timer_outlined, color: Colors.white, size: 28),
    );
  }

  // 🔥 دالة الضغط
  void _onTap() {
    if (_isBlocked) {
      // إعادة تذكير المستخدم بالوقت المتبقي في حال حاول الضغط مجدداً أثناء الحظر
      // _showBlockSnackbar();
      return;
    }

    DateTime now = DateTime.now();
    if (_lastTapTime != null) {
      int difference = now.difference(_lastTapTime!).inMilliseconds;
      
      // ⚠️ رفع الحد الزمني إلى 350 ملي ثانية للحظر حتى مع الضغط الأبطأ قليلاً
      if (difference < 350) {
        _startBlockCountdown();
        return;
      }
    }
    _lastTapTime = now;

    setState(() {
      _counter++;
      HapticFeedback.lightImpact();
      _animationController.forward().then(
        (_) => _animationController.reverse(),
      );

      if (_counter == _target) {
        _showTargetReachedDialog();
      }
    });
  }

  void _reset() {
    if (_counter > 0) {
      _saveProgress(resetCounterAfterSave: true);
    }
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _bannerAd?.dispose();
    _countdownTimer?.cancel(); // إيقاف المؤقت لمنع الـ Memory Leak
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
            'المسبحة الإلكترونية'.tr,
            style: TextStyle(
              color: AppColors.accentGold,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppColors.accentGold),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 15),
              _buildDhikrPicker(),
              const SizedBox(height: 25),

              // المسبحة
              GestureDetector(
                onTap: _onTap,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Opacity(
                        opacity: 0.9,
                        child: Image.asset(
                          'assets/ayah_frame.png',
                          width: 280,
                          height: 280,
                          fit: BoxFit.contain,
                          color: AppColors.textWhite,
                          colorBlendMode: BlendMode.srcIn,
                        ),
                      ),
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.withOpacity(0.1),
                        ),
                      ),
                      SizedBox(
                        width: 185,
                        height: 185,
                        child: CustomPaint(
                          painter: TasbihPainter(
                            progress: _counter / _target,
                            color: _isBlocked ? Colors.red : AppColors.accentGold,
                          ),
                        ),
                      ),
                      Container(
                        width: 140,
                        height: 140,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: _isBlocked
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.lock_clock, color: Colors.redAccent, size: 30),
                                    const SizedBox(height: 5),
                                    Text(
                                      '$_secondsRemaining',
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  '$_counter',
                                  style: const TextStyle(
                                    color: Color(0xFF997D45),
                                    fontSize: 55,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // إجمالي التسبيحات
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.accentGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: AppColors.accentGold.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      "إجمالي الجلسة".tr,
                      style: TextStyle(color: AppColors.textWhite, fontSize: 12),
                    ),
                    Text(
                      _counter.toString(),
                      style: TextStyle(
                        color: AppColors.accentGold,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // أزرار التحكم
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSmallAction(Icons.refresh, "تصفير", _reset),
                  _buildSmallAction(Icons.sync, "حفظ الآن", () => _saveProgress(resetCounterAfterSave: true)),
                  _buildSmallAction(
                    Icons.settings_backup_restore,
                    "${'الهدف: '.tr}$_target",
                    () {
                      setState(() => _target = (_target == 33) ? 100 : 33);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 25),

              // قسم متصدري التسبيح
              _buildLeaderboardSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
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

  Widget _buildLeaderboardSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.primaryDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.accentGold.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_events, color: AppColors.accentGold, size: 20),
              const SizedBox(width: 8),
              Text(
                "أكثر المسبحين نشاطاً".tr,
                style: TextStyle(
                  color: AppColors.accentGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 20),
          FutureBuilder<List<dynamic>>(
            future: _progressController.fetchLeaderboard(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    "لا توجد إحصائيات حتى الآن".tr,
                    style: TextStyle(color: AppColors.textWhite.withOpacity(0.5), fontSize: 12),
                  ),
                );
              }

              var list = snapshot.data!;
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  var item = list[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              "#${item['rank']} ",
                              style: TextStyle(
                                color: item['rank'] == 1 ? AppColors.accentGold : Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              item['user_name'],
                              style: TextStyle(color: AppColors.textWhite, fontSize: 13),
                            ),
                          ],
                        ),
                        Text(
                          "${item['total_tasbih']} ${'تسبيحة'.tr}",
                          style: TextStyle(
                            color: AppColors.accentGold,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDhikrPicker() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _adhkir.length,
        itemBuilder: (context, index) {
          bool isSelected = _currentDhikr == _adhkir[index];
          return GestureDetector(
            onTap: () {
              if (_counter > 0) _saveProgress(resetCounterAfterSave: true);
              setState(() {
                _currentDhikr = _adhkir[index];
                _counter = 0;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(left: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accentGold : AppColors.textWhite,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  _adhkir[index].tr,
                  style: TextStyle(
                    color: isSelected ? Colors.black : const Color(0xFF997D45),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSmallAction(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(
            icon,
            color: AppColors.accentGold.withOpacity(0.8),
            size: 28,
          ),
        ),
        Text(
          label.tr,
          style: TextStyle(color: AppColors.textWhite, fontSize: 12),
        ),
      ],
    );
  }
}

class TasbihPainter extends CustomPainter {
  final double progress;
  final Color color;

  TasbihPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double angle = 2 * math.pi * (progress > 1.0 ? 1.0 : progress);

    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      -math.pi / 2,
      angle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(TasbihPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}