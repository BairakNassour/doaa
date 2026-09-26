import 'package:doaa/component/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class FridayHadithPage extends StatefulWidget {
  const FridayHadithPage({super.key});

  @override
  State<FridayHadithPage> createState() => _FridayHadithPageState();
}

class _FridayHadithPageState extends State<FridayHadithPage> {
  int _currentIndex = 0;

  // قائمة الأحاديث الصحيحة عن يوم الجمعة
  final List<Map<String, String>> _hadiths = [
    {
      "text": "«خيرُ يومٍ طلَعت عليه الشَّمسُ يومُ الجمعةِ؛ فيه خُلِق آدمُ، وفيه أُدْخِل الجَنَّةَ، وفيه أُخْرِج منها، ولا تقومُ السَّاعةُ إلَّا في يومِ الجمعةِ»",
      "source": "رواه مسلم (صحيح مسلم)",
      "benefit": "بيان عظمة يوم الجمعة وأنه أفضل أيام الأسبوع عند الله تعالى.",
    },
    {
      "text": "«من اغتَسَلَ يَوْمَ الجُمُعَةِ وغَسَّلَ، وبَكَّرَ وابْتَكَرَ، ومَشَى ولَمْ يَرْكَبْ، ودَنَا مِنَ الإِماِمِ فاَسْتَمَعَ ولَمْ يَلْغُ، كانَ له بكلِّ خطوةٍ عَمَلُ سَنَةٍ، أجْرُ صِيامِها وقِيامِها»",
      "source": "رواه الألباني (صحيح سنن أبن ماجه)",
      "benefit": "عظم أجر التبكير للجمعة والإنصات للخطيب بدون لغو.",
    },
    {
      "text": "«من قرَأ سورةَ الكهفِ في يومِ الجمعةِ أضاء له من النُّورِ ما بين الجمعتينِ»",
      "source": "رواه الحاكم والألباني (صحيح الجامع)",
      "benefit": "استحباب قراءة سورة الكهف لما فيها من النور والتثبيت.",
    },
    {
      "text": "«أَكْثِرُوا عَلَيَّ مِنَ الصَّلَاةِ فِي يَوْمِ الْجُمُعَةِ وَلَيْلَةِ الْجُمُعَةِ، فَمَنْ صَلَّى عَلَيَّ صَلَاةً صَلَّى اللهُ عَلَيْهِ بِهَا عَشْرًا»",
      "source": "رواه البيهقي وصححه الألباني",
      "benefit": "فضيلة كثرة الصلاة على النبي ﷺ ليلة ويوم الجمعة.",
    },
    {
      "text": "«إنَّ في الجمعةِ لساعةً، لا يوافقُها عبدٌ مسلمٌ، وهو قائمٌ يُصلِّي، يسألُ اللهَ خيرًا، إلا أعطاه إياه»",
      "source": "رواه البخاري ومسلم",
      "benefit": "الحث على استغلال ساعة الإجابة بالدعاء والتضرع لله.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currentHadith = _hadiths[_currentIndex];

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.secondaryDark,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "حديث الجمعة".tr,
            style: TextStyle(
              color: AppColors.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 1. بطاقة رقم الحديث الحالي
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.format_quote_rounded, color: Color(0xFFC0A080), size: 24),
                      const SizedBox(width: 8),
                      Text(
                        "حديث اليوم",
                        style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC0A080).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${_currentIndex + 1} / ${_hadiths.length}",
                      style: const TextStyle(color: Color(0xFFC0A080), fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),

              // 2. بطاقة عرض نص الحديث
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.primaryDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFC0A080).withOpacity(0.3)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.menu_book_rounded, color: Color(0xFFC0A080), size: 40),
                      const SizedBox(height: 20),

                      // نص الحديث
                      Text(
                        currentHadith["text"]!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textWhite,
                          fontSize: 18,
                          height: 1.8,
                          fontFamily: 'Amiri',
                        ),
                      ),
                      const SizedBox(height: 20),

                      // المرجع / التخريج
                      Text(
                        currentHadith["source"]!,
                        style: const TextStyle(
                          color: Color(0xFFC0A080),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Divider(color: Color(0xFFC0A080), thickness: 0.3),
                      const SizedBox(height: 10),

                      // الفائدة أو المعنى الموجز
                      Text(
                        currentHadith["benefit"]!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textWhite.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 3. أزرار التحكم والنسخ والتنقل
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // زر النسخ والمشاركة
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, color: Color(0xFFC0A080), size: 26),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(
                          text: "${currentHadith['text']}\n${currentHadith['source']}"));
                      HapticFeedback.lightImpact();
                      Get.snackbar(
                        "تم النسخ",
                        "تم نسخ الحديث بنجاح",
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.primaryDark,
                        colorText: AppColors.textWhite,
                        duration: const Duration(seconds: 1),
                      );
                    },
                  ),

                  // زر الحديث التالي
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC0A080),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: () {
                      setState(() {
                        _currentIndex = (_currentIndex + 1) % _hadiths.length;
                      });
                      HapticFeedback.lightImpact();
                    },
                    icon: Icon(Icons.refresh_rounded, color: AppColors.primaryDark),
                    label: Text(
                      "حديث آخر",
                      style: TextStyle(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),
              const Text(
                "✿ ✿ ✿",
                style: TextStyle(
                  color: Color(0xFFC0A080),
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}