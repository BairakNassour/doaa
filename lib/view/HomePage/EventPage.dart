import 'dart:async';
import 'package:flutter/material.dart';
import 'package:doaa/component/app_colors.dart';
import 'package:get/get.dart';

class EventsPage extends StatefulWidget {
  // نمرر التواريخ كـ DateTime لكي يحسب العداد الساعات والثواني بدقة
  final DateTime ramadanDate;
  final DateTime hajjDate;

  const EventsPage({
    super.key,
    required this.ramadanDate,
    required this.hajjDate,
  });

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  Timer? _timer;
  Duration _ramadanDuration = const Duration();
  Duration _hajjDuration = const Duration();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  // دالة تشغيل العداد وتحديثه كل ثانية
  void _startTimer() {
    _calculateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _calculateTime();
      }
    });
  }

  void _calculateTime() {
    final now = DateTime.now();
    setState(() {
      _ramadanDuration = widget.ramadanDate.difference(now);
      _hajjDuration = widget.hajjDate.difference(now);
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // إغلاق التايمر عند الخروج للحفاظ على أداء الجهاز
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title:  Text(
          'المناسبات القادمة'.tr,
          style: TextStyle(
            color: AppColors.accentGold,
            fontFamily: 'QuranFont',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon:  Icon(Icons.arrow_back_ios_new, color:  AppColors.textWhite, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // كرت رمضان
            _buildEventCard(
              title: 'العد التنازلي لرمضان',
              eventName: 'رمضان المبارك',
              duration: _ramadanDuration,
              imagePath: 'assets/moon.png',
              gradient: const [Color(0xFF1B4D3E), Color(0xFF2D6A4F)],
              accentColor: const Color(0xFF95D5B2),
            ),
            
            const SizedBox(height: 25),

            // كرت الحج
            _buildEventCard(
              title: 'العد التنازلي للحج',
              eventName: 'موسم الحج',
              duration: _hajjDuration,
              imagePath: 'assets/sun.png',
              gradient: const [Color(0xFF744A1B), Color(0xFF9C6628)],
              accentColor: const Color(0xFFFFD166),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventCard({
    required String title,
    required String eventName,
    required Duration duration,
    required String imagePath,
    required List<Color> gradient,
    required Color accentColor,
  }) {
    // التأكد من أن الوقت لم ينتهِ (إذا انتهى نعرض أصفار)
    bool isExpired = duration.isNegative;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0, bottom: 10),
          child: Text(
            title.tr,
            style: TextStyle(
              color: accentColor.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: gradient[0].withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              // زخرفة خلفية
              Positioned(
                left: -20,
                bottom: -20,
                child: Opacity(
                  opacity: 0.1,
                  child: Icon(Icons.mosque, size: 120, color:  AppColors.textWhite),
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          eventName.tr,
                          style:  TextStyle(
                            color:  AppColors.textWhite,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'QuranFont',
                          ),
                        ),
                        Image.asset(imagePath, height: 45, width: 45),
                      ],
                    ),
                    const SizedBox(height: 25),
                    
                    // صف العداد التنازلي المربعات
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildTimeBlock(isExpired ? "0" : duration.inDays.toString(), 'يوم'),
                        _buildTimeBlock(isExpired ? "00" : (duration.inHours % 24).toString().padLeft(2, '0'), 'ساعة'),
                        _buildTimeBlock(isExpired ? "00" : (duration.inMinutes % 60).toString().padLeft(2, '0'), 'دقيقة'),
                        _buildTimeBlock(isExpired ? "00" : (duration.inSeconds % 60).toString().padLeft(2, '0'), 'ثانية'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ويدجت المربع الصغير لكل وحدة زمنية
  Widget _buildTimeBlock(String value, String label) {
    return Column(
      children: [
        Container(
          width: 65,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color:  AppColors.textWhite.withOpacity(0.12), // تأثير زجاجي
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color:  AppColors.textWhite.withOpacity(0.2)),
          ),
          child: Center(
            child: Text(
              value,
              style:  TextStyle(
                color:  AppColors.textWhite,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label.tr,
          style:  TextStyle(
            color:  AppColors.textWhite,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}