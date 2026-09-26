import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:doaa/component/app_colors.dart';
import 'package:doaa/controller/quran_controller.dart';
import 'package:doaa/model/ayah_model.dart';
import 'package:doaa/view/friday/AnswerHourPage.dart';
import 'package:doaa/view/friday/FridayDuasPage.dart';
import 'package:doaa/view/friday/FridayHadithPage.dart';
import 'package:doaa/view/friday/FridaySunnahPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class FridayMainPage extends StatefulWidget {
  const FridayMainPage({super.key});

  @override
  State<FridayMainPage> createState() => _FridayMainPageState();
}

class _FridayMainPageState extends State<FridayMainPage> {
  // 1. عداد الصلاة على النبي يبدأ من الصفر
  int _salawatCount = 0;
  final int _salawatTarget = 1000;

  // إكمال السنن (0 من 7)
  final int _completedSunnahs = 0;
  final int _totalSunnahs = 7;

  // 2. التحقق هل اليوم هو الجمعة
  bool get _isTodayFriday => DateTime.now().weekday == DateTime.friday;

  // مشغل الصوت
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  int _currentPlayingIndex = 0;
  List<String> _audioUrls = [];

  @override
  void dispose() {
    _audioPlayer.dispose();
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
            "قسم يوم الجمعة".tr,
            style: TextStyle(
              color: AppColors.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              // 1. بطاقة العد التنازلي للجمعة
              _buildCountdownCard(),
              const SizedBox(height: 15),

              // 2. القفل لبقية الأيام (يفتح يوم الجمعة فقط)
              if (_isTodayFriday)
                _buildNotFridayMessage()
              else ...[
                Row(
                  children: [
                    Expanded(child: _buildSalawatCard()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildKahfCard()),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildDuaCard()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildAnswerHourCard()),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _buildSunnahCard()),
                    const SizedBox(width: 12),
                    Expanded(child: _buildHadithCard()),
                  ],
                ),
              ],

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
    );
  }

  // --- رسالة يوم الجمعة مغلق ---
  Widget _buildNotFridayMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC0A080).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.lock_clock_rounded,
            color: Color(0xFFC0A080),
            size: 50,
          ),
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

  // --- 1. بطاقة العد التنازلي ---
  Widget _buildCountdownCard() {
    DateTime now = DateTime.now();
    int daysUntilFriday = (DateTime.friday - now.weekday + 7) % 7;
    if (daysUntilFriday == 0 && !_isTodayFriday) daysUntilFriday = 7;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC0A080).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mosque, color: Color(0xFFC0A080), size: 20),
              const SizedBox(width: 8),
              Text(
                _isTodayFriday
                    ? "جمعة مباركة! اليوم هو يوم الجمعة"
                    : "الجمعة القادمة بعد",
                style: TextStyle(
                  color: AppColors.textWhite.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
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

  // --- 2. الصلاة على النبي (يبدأ من 0) ---
  Widget _buildSalawatCard() {
    double progress = (_salawatCount / _salawatTarget).clamp(0.0, 1.0);

    return InkWell(
      onTap: () {
        setState(() {
          _salawatCount++;
        });
        HapticFeedback.lightImpact();
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(15),
        height: 160,
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Icon(
              Icons.volunteer_activism_rounded,
              color: Color(0xFFC0A080),
              size: 30,
            ),
            Text(
              "الصلاة على النبي",
              style: TextStyle(
                color: AppColors.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "$_salawatCount / $_salawatTarget",
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.secondaryDark,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFC0A080),
                ),
                minHeight: 6,
              ),
            ),
            Text(
              "اضغط للزيادة +",
              style: TextStyle(
                color: AppColors.textWhite.withOpacity(0.4),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 3. سورة الكهف قراءة وصوت ---
  Widget _buildKahfCard() {
    return _buildGridTile(
      icon: Icons.menu_book_rounded,
      title: "سورة الكهف",
      subtitle: "قراءة واستماع",
      onTap: () async {
        Get.dialog(
          const Center(
            child: CircularProgressIndicator(color: Color(0xFFC0A080)),
          ),
          barrierDismissible: false,
        );

        try {
          // جلب النص عبر QuranController
          QuranController quranController = QuranController();
          List<Ayah> ayahs = await quranController.fetchSurahAyahs(18);

          // جلب الصوتيات المباشرة عبر API القارئ العفاسي لسورة الكهف (18)
          final audioResponse = await http.get(
            Uri.parse("https://api.alquran.cloud/v1/surah/18/ar.alafasy"),
          );

          List<String> urls = [];
          if (audioResponse.statusCode == 200) {
            var data = json.decode(audioResponse.body);
            List ayahsAudio = data['data']['ayahs'];
            urls = ayahsAudio
                .map<String>((a) => a['audio'].toString())
                .toList();
          }

          Get.back(); // إغلاق التحميل
          _showKahfBottomSheet(ayahs, urls);
        } catch (e) {
          Get.back();
          Get.snackbar("خطأ", "تعذر التحميل، يرجى الاتصال بالإنترنت.");
        }
      },
    );
  }

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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryDark,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: const Color(0xFFC0A080).withOpacity(0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _isPlaying
                                  ? Icons.volume_up_rounded
                                  : Icons.volume_off_rounded,
                              color: const Color(0xFFC0A080),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isPlaying
                                  ? "جاري الاستماع للشيخ العفاسي..."
                                  : "استماع لسورة الكهف",
                              style: TextStyle(
                                color: AppColors.textWhite,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(
                            _isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_fill,
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

                                // التشغيل التلقائي للآية التالية
                                _audioPlayer.onPlayerComplete.listen((event) {
                                  if (_currentPlayingIndex <
                                      _audioUrls.length - 1) {
                                    _currentPlayingIndex++;
                                    _audioPlayer.play(
                                      UrlSource(
                                        _audioUrls[_currentPlayingIndex],
                                      ),
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

  Widget _buildDuaCard() {
    return _buildGridTile(
      icon: Icons.handshake_outlined,
      title: "أدعية الجمعة",
      subtitle: "دعاء مميز كل جمعة",
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => FridayDuasPage()),
        );
      },
    );
  }

  Widget _buildAnswerHourCard() {
    return _buildGridTile(
      icon: Icons.access_time_filled_rounded,
      title: "ساعة الإجابة",
      subtitle: "وقت يُرجى فيه إجابة الدعاء",
      onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  AnswerHourPage()),
      );
    },
    );
  }

Widget _buildSunnahCard() {
  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FridaySunnahPage()),
      );
    },
    borderRadius: BorderRadius.circular(20),
    child: Container(
      padding: const EdgeInsets.all(15),
      height: 150,
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_box_outlined, color: Color(0xFFC0A080), size: 28),
          const SizedBox(height: 8),
          Text(
            "سنن وآداب الجمعة",
            style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.greenAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "$_completedSunnahs / $_totalSunnahs مكتملة",
              style: const TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    ),
  );
}

  Widget _buildHadithCard() {
  return _buildGridTile(
    icon: Icons.format_quote_rounded,
    title: "حديث الجمعة",
    subtitle: "حديث صحيح جديد",
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FridayHadithPage()),
      );
    },
  );
}

  Widget _buildGridTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(15),
        height: 150,
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFFC0A080), size: 30),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                color: AppColors.textWhite,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: AppColors.textWhite.withOpacity(0.5),
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
