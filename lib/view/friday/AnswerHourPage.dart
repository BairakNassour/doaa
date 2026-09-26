import 'package:doaa/component/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AnswerHourPage extends StatefulWidget {
  const AnswerHourPage({super.key});

  @override
  State<AnswerHourPage> createState() => _AnswerHourPageState();
}

class _AnswerHourPageState extends State<AnswerHourPage> {
  bool _isNotificationEnabled = false;

  final List<String> _supplications = [
    "اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي.",
    "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ.",
    "اللَّهُمَّ إِني أْسْأَلُكَ مِنَ الْخَيْرِ كُلِّهِ عَاجِلِهِ وَآجِلِهِ مَا عَلِمْتُ مِنْهُ وَمَا لَمْ أَعْلَمْ.",
    "اللَّهُمَّ اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُؤْمِنِينَ وَالْمُؤْمِنَاتِ الأَحْيَاءِ مِنْهُمْ وَالأَمْوَاتِ.",
    "يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ، أَصْلِحْ لِي شَأْنِي كُلَّهُ وَلاَ تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ.",
  ];

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
            "ساعة الإجابة".tr,
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
              // 1. بطاقة تحديد وقت ساعة الإجابة
              _buildTimeHeaderCard(),
              const SizedBox(height: 15),

              // 2. شريط تفعيل تذكير الإشعارات
              _buildNotificationTile(),
              const SizedBox(height: 20),

              // 3. بطاقة آداب الدعاء في هذه الساعة
              _buildEtiquetteCard(),
              const SizedBox(height: 20),

              // 4. عنوان قائمة الأدعية
              Row(
                children: [
                  const Icon(Icons.auto_awesome, color: Color(0xFFC0A080), size: 22),
                  const SizedBox(width: 8),
                  Text(
                    "أدعية جامعة ومستحبة",
                    style: TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 5. عرض الأدعية
              ..._supplications.map((dua) => _buildDuaCard(dua)).toList(),

              const SizedBox(height: 20),
              const Text(
                "✿ ✿ ✿",
                style: TextStyle(
                  color: Color(0xFFC0A080),
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  // --- 1. بطاقة الوقت والتوضيح الشرعي ---
  Widget _buildTimeHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC0A080).withOpacity(0.4)),
      ),
      child: Column(
        children: [
          const Icon(Icons.access_time_filled_rounded, color: Color(0xFFC0A080), size: 45),
          const SizedBox(height: 12),
          Text(
            "وَقْتٌ يُرْجَى فِيهِ إِجَابَةُ الدُّعَاءِ",
            style: TextStyle(
              color: const Color(0xFFC0A080),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "أرجح أقوال أهل العلم أن ساعة الإجابة هي آخر ساعة من يوم الجمعة بعد صلاة العصر وحتى غروب الشمس.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textWhite.withOpacity(0.8),
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. شريط التنبيه والإشعارات ---
  Widget _buildNotificationTile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(15),
      ),
      child: SwitchListTile(
        title: Text(
          "تذكير عند قرب الوقت",
          style: TextStyle(color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "تنبيهك قبل غروب الشمس للتفرغ للدعاء",
          style: TextStyle(color: AppColors.textWhite.withOpacity(0.5), fontSize: 11),
        ),
        value: _isNotificationEnabled,
        activeColor: const Color(0xFFC0A080),
        onChanged: (val) {
          setState(() {
            _isNotificationEnabled = val;
          });
          HapticFeedback.lightImpact();
          Get.snackbar(
            val ? "تم التفعيل" : "تم الإلغاء",
            val ? "سَيتم تذكيرك بقدوم ساعة الإجابة" : "تم إلغاء التذكير",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.primaryDark,
            colorText: AppColors.textWhite,
          );
        },
      ),
    );
  }

  // --- 3. بطاقة آداب واستجابة الدعاء ---
  Widget _buildEtiquetteCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFC0A080).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.stars_rounded, color: Color(0xFFC0A080), size: 20),
              const SizedBox(width: 8),
              Text(
                "من آداب الدعاء في هذه الساعة:",
                style: TextStyle(color: const Color(0xFFC0A080), fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            "• استقبال القبلة والرفع لليدين بإنكسار وخضوع.\n"
            "• البدء بالثناء على الله والصلاة على النبي ﷺ.\n"
            "• الإلحاح في الدعاء مع الجزم واليقين بالإجابة.",
            style: TextStyle(color: AppColors.textWhite.withOpacity(0.8), fontSize: 13, height: 1.7),
          ),
        ],
      ),
    );
  }

  // --- 4. بطاقات الأدعية ---
  Widget _buildDuaCard(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFC0A080).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 16,
                height: 1.6,
                fontFamily: 'Amiri',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy_rounded, color: Color(0xFFC0A080), size: 20),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: text));
              HapticFeedback.lightImpact();
              Get.snackbar(
                "تم النسخ",
                "تم نسخ النص بنجاح",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.primaryDark,
                colorText: AppColors.textWhite,
                duration: const Duration(seconds: 1),
              );
            },
          )
        ],
      ),
    );
  }
}