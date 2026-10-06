import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:doaa/component/app_colors.dart';
import 'package:doaa/controller/quran_controller.dart';
import 'package:doaa/model/ayah_model.dart';
import 'package:doaa/view/friday/AnswerHourPage.dart';
import 'package:doaa/view/friday/FridayDuasPage.dart';
import 'package:doaa/view/friday/FridayHadithPage.dart';
import 'package:doaa/view/friday/FridaySunnahPage.dart';
import 'package:doaa/view/friday/surah_kahf_page.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

// نموذج بيانات لعناصر الشبكة
class FridayGridItem {
  final String title;
  final String subtitle;
  final String iconAsset; // مسار الصورة
  final IconData fallbackIcon; // أيقونة احتياطية
  final VoidCallback onTap;
  final Widget? extraContent; // محتوى إضافي مثل شريط التقدم

  FridayGridItem({
    required this.title,
    required this.subtitle,
    required this.iconAsset,
    required this.fallbackIcon,
    required this.onTap,
    this.extraContent,
  });
}

class FridayMainPage extends StatefulWidget {
  const FridayMainPage({super.key});

  @override
  State<FridayMainPage> createState() => _FridayMainPageState();
}

class _FridayMainPageState extends State<FridayMainPage> {
  // العدادات والبيانات
  int _salawatCount = 0;
  final int _salawatTarget = 1000;
  final int _completedSunnahs = 0;
  final int _totalSunnahs = 7;

  // التحقق من اليوم
  bool get _isTodayFriday => DateTime.now().weekday == DateTime.friday;

  // مشغل الصوت
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  int _currentPlayingIndex = 0;
  List<String> _audioUrls = [];

  // قائمة عناصر الشبكة (سيتم تعريفه داخل build لاستخدام setState)
  late List<FridayGridItem> _gridItems;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

void _onKahfTap() {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const SurahKahfPage()),
  );
}

  @override
  Widget build(BuildContext context) {
    // تحديد تدرج الخلفية العلوية (داكن/فاتح)
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final headerGradient = isDarkMode
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1E3A2F), Color(0xFF2C5E4A)],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2C5E4A), Color(0xFF3F8F6E)],
          );

    // تحديث شريط التقدم للصلاة على النبي
    double salawatProgress = (_salawatCount / _salawatTarget).clamp(0.0, 1.0);

    // تعريف عناصر الشبكة هنا لتحديث العدادات
    _gridItems = [
      FridayGridItem(
        title: "سورة الكهف",
        subtitle: "قراءة واستماع",
        iconAsset: "assets/quranremeber.png", // ستحتاج لإضافة هذه الصورة
        fallbackIcon: Icons.menu_book_rounded,
        onTap: _onKahfTap,
      ),
      FridayGridItem(
        title: "الصلاة على النبي",
        subtitle: "$_salawatCount / $_salawatTarget",
        iconAsset: "assets/kaba.png", // ستحتاج لإضافة هذه الصورة
        fallbackIcon: Icons.volunteer_activism_rounded,
        onTap: () {
          setState(() {
            _salawatCount++;
          });
          HapticFeedback.lightImpact();
        },
        extraContent: Column(
          children: [
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: salawatProgress,
                backgroundColor: AppColors.secondaryDark,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFC0A080)),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
      FridayGridItem(
        title: "أدعية الجمعة",
        subtitle: "دعاء مميز كل جمعة",
        iconAsset: "assets/doaa.png", // ستحتاج لإضافة هذه الصورة
        fallbackIcon: Icons.handshake_outlined,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => FridayDuasPage()));
        },
      ),
      FridayGridItem(
        title: "ساعة الإجابة",
        subtitle: "وقت يُرجى فيه إجابة الدعاء",
        iconAsset: "assets/clock.png", // ستحتاج لإضافة هذه الصورة
        fallbackIcon: Icons.access_time_filled_rounded,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AnswerHourPage()));
        },
      ),
      FridayGridItem(
        title: "سنن وآداب الجمعة",
        subtitle: "$_completedSunnahs / $_totalSunnahs مكتملة",
        iconAsset: "assets/sonah.png", // ستحتاج لإضافة هذه الصورة
        fallbackIcon: Icons.check_box_outlined,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const FridaySunnahPage()));
        },
      ),
      FridayGridItem(
        title: "حديث الجمعة",
        subtitle: "حديث صحيح جديد",
        iconAsset: "assets/hadith.png", // ستحتاج لإضافة هذه الصورة
        fallbackIcon: Icons.format_quote_rounded,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const FridayHadithPage()));
        },
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.secondaryDark,
      body: Stack(
        children: [
          // 1. الخلفية العلوية المرسومة (من الصورة)
          Container(
            height: 280,
            decoration: BoxDecoration(
              gradient: headerGradient,
            ),
            // ضع صورة الخلفية هنا عند توفرها:
            // child: Image.asset('assets/images/friday_header.png', fit: BoxFit.cover),
          ),

          // 2. المحتوى (AppBar + القائمة)
          CustomScrollView(
            slivers: [
              // الـ App Bar الشفاف
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                floating: true,
                centerTitle: true,
                title: Text(
                  "يوم الجمعة".tr, // تم تغيير الاسم ليطابق الصورة
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                leading: IconButton(
                  icon: Icon(Icons.mosque, color: AppColors.textWhite),
                  onPressed: () {}, // أي إجراء تريده
                ),
              ),

              // نص ترحيبي علوي
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      Text(
                        "برنامجك الكامل لليوم المبارك",
                        style: TextStyle(
                          color: AppColors.textWhite.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 25),
                    ],
                  ),
                ),
              ),

              // 3. القائمة ذات الزوايا المنحنية (المحتوى الرئيسي)
              SliverFillRemaining(
                hasScrollBody: true,
                child: Container(
                  padding: const EdgeInsets.only(top: 15),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // بطاقة العد التنازلي (التي تمتد بعرض الشاشة)
                        _buildCountdownCard(),
                        const SizedBox(height: 20),

                        
                          // الشبكة (Grid) للعناصر الستة (2 في كل صف)
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _gridItems.length,
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                              childAspectRatio: 1.1, // لجعلها مربعة تقريباً
                            ),
                            itemBuilder: (context, index) {
                              return _buildGridTile(_gridItems[index]);
                            },
                          ),

                        const SizedBox(height: 25),
                        const Text(
                          "✿ ✿ ✿",
                          style: TextStyle(color: Color(0xFFC0A080), fontSize: 22),
                        ),
                        const SizedBox(height: 15),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- رسالة يوم الجمعة مغلق ---
  Widget _buildNotFridayMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: AppColors.secondaryDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC0A080).withOpacity(0.1)),
      ),
      child: Column(
        children: [
          const Icon(Icons.lock_clock_rounded, color: Color(0xFFC0A080), size: 50),
          const SizedBox(height: 15),
          Text(
            "قسم يوم الجمعة مغلق الآن",
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "تُفتح ميزات وسنن قسم الجمعة خصيصاً يوم الجمعة المبارك. ننتظرك عند حلول اليوم الشريف!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textWhite.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // --- بطاقة العد التنازلي ---
  Widget _buildCountdownCard() {
    DateTime now = DateTime.now();
    int daysUntilFriday = (DateTime.friday - now.weekday + 7) % 7;
    if (daysUntilFriday == 0 && !_isTodayFriday) daysUntilFriday = 7;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.secondaryDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC0A080).withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Text(
            _isTodayFriday ? "جمعة مباركة! اليوم هو يوم الجمعة" : "الجمعة القادمة بعد",
            style: TextStyle(
              color: AppColors.textWhite.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          if (!_isTodayFriday) ...[
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTimeUnit("$daysUntilFriday", "يوم"),
                _buildTimeSeparator(),
                _buildTimeUnit("${23 - now.hour}", "ساعة"),
                _buildTimeSeparator(),
                _buildTimeUnit("${59 - now.minute}", "دقيقة"),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeUnit(String value, String unit) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFC0A080),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            color: AppColors.textWhite.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSeparator() {
    return Text(
      ":",
      style: TextStyle(
        color: const Color(0xFFC0A080).withOpacity(0.5),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // --- بناء بلاطة الشبكة (Grid Tile) بناءً على التصميم الجديد ---
  Widget _buildGridTile(FridayGridItem item) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC0A080).withOpacity(0.1)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: item.onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // الأيقونة (صورة Asset أو الأيقونة الاحتياطية)
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: Center(
                      child: Image.asset(
                        item.iconAsset,
                        width: 50,
                        height: 50,
                        // إذا لم يجد الصورة، يعرض الأيقونة الاحتياطية
                        errorBuilder: (context, error, stackTrace) => Icon(
                          item.fallbackIcon,
                          color: const Color(0xFFC0A080),
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // العنوان
                Text(
                  item.title,
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 3),

                // العنوان الفرعي
                Text(
                  item.subtitle,
                  style: TextStyle(
                    color: AppColors.textWhite.withOpacity(0.5),
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),

                // المحتوى الإضافي (مثل شريط التقدم للصلاة على النبي)
                if (item.extraContent != null) item.extraContent!,
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- نافذة سورة الكهف السفلى (كما هي من كودك الأصلي) ---
  void _showKahfBottomSheet(List<Ayah> ayahs, List<String> audioUrls) {
    _audioUrls = audioUrls;
    _currentPlayingIndex = 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.primaryDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    "سورة الكهف - نور ما بين الجمعتين",
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // مشغل الصوت
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryDark,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFFC0A080).withOpacity(0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _isPlaying ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                              color: const Color(0xFFC0A080),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isPlaying ? "جاري الاستماع للشيخ العفاسي..." : "استماع لسورة الكهف",
                              style: TextStyle(color: AppColors.textWhite, fontSize: 13),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(
                            _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                            color: const Color(0xFFC0A080),
                            size: 38,
                          ),
                          onPressed: () async {
                            if (_isPlaying) {
                              await _audioPlayer.pause();
                              setModalState(() {
                                _isPlaying = false;
                              });
                            } else {
                              if (_audioUrls.isNotEmpty) {
                                await _audioPlayer.play(
                                  UrlSource(_audioUrls[_currentPlayingIndex]),
                                );
                                setModalState(() {
                                  _isPlaying = true;
                                });

                                _audioPlayer.onPlayerComplete.listen((event) {
                                  if (_currentPlayingIndex < _audioUrls.length - 1) {
                                    _currentPlayingIndex++;
                                    _audioPlayer.play(
                                      UrlSource(_audioUrls[_currentPlayingIndex]),
                                    );
                                  } else {
                                    setModalState(() {
                                      _isPlaying = false;
                                    });
                                  }
                                });
                              }
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const Divider(color: Color(0xFFC0A080), height: 25),

                  // عرض الآيات
                  Expanded(
                    child: ListView.builder(
                      itemCount: ayahs.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            "${ayahs[index].text} ﴿${ayahs[index].numberInSurah}﴾",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: AppColors.textWhite,
                              fontSize: 18,
                              height: 1.8,
                              fontFamily: 'Amiri',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).then((_) {
      _audioPlayer.stop();
      _isPlaying = false;
    });
  }
}