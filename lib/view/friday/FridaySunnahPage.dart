import 'package:doaa/component/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class FridaySunnahPage extends StatefulWidget {
  const FridaySunnahPage({super.key});

  @override
  State<FridaySunnahPage> createState() => _FridaySunnahPageState();
}

class _FridaySunnahPageState extends State<FridaySunnahPage> {
  // قائمة السنن والآداب وحالة الإنجاز لكل منها
  final List<Map<String, dynamic>> _sunnahList = [
    {
      "id": 1,
      "title": "الاغتسال",
      "subtitle": "عَنِ النَّبِيِّ ﷺ: غُسْلُ يَوْمِ الْجُمُعَةِ وَاجِبٌ عَلَى كُلِّ مُحْتَلِمٍ",
      "isDone": false,
    },
    {
      "id": 2,
      "title": "التطيب والتسوك",
      "subtitle": "استخدام الطيب والمسواك للتطهر والتطيب",
      "isDone": false,
    },
    {
      "id": 3,
      "title": "لبس أحسن الثياب",
      "subtitle": "التأنق والنظافة للتجمع والجمعة",
      "isDone": false,
    },
    {
      "id": 4,
      "title": "التبكير إلى صلاة الجمعة",
      "subtitle": "السعي مبكراً إلى المسجد قبل دخول الإمام",
      "isDone": false,
    },
    {
      "id": 5,
      "title": "قراءة سورة الكهف",
      "subtitle": "تضيء للمسلم نورا ما بين الجمعتين",
      "isDone": false,
    },
    {
      "id": 6,
      "title": "الإكثار من الصلاة على النبي ﷺ",
      "subtitle": "من أفضل القربات والأعمال في ليلة ويوم الجمعة",
      "isDone": false,
    },
    {
      "id": 7,
      "title": "الإنصات للخطبة",
      "subtitle": "الاستماع للخطيب والابتعاد عن اللغو أو الانشغال بالهاتف",
      "isDone": false,
    },
  ];

  int get _completedCount => _sunnahList.where((item) => item['isDone'] == true).length;

  @override
  Widget build(BuildContext context) {
    double progress = _completedCount / _sunnahList.length;

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.secondaryDark,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            "سنن وآداب الجمعة".tr,
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
              // 1. بطاقة ملخص وشريط نسبة الإنجاز
              _buildProgressCard(progress),
              const SizedBox(height: 20),

              // 2. قائمة السنن والآداب التفاعلية
              ..._sunnahList.map((item) => _buildSunnahTile(item)).toList(),

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

  // --- بطاقة شريط التقدم ---
  Widget _buildProgressCard(double progress) {
    bool isAllDone = _completedCount == _sunnahList.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isAllDone ? Colors.greenAccent : const Color(0xFFC0A080).withOpacity(0.4),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "مستوى الإنجاز اليوم",
                style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isAllDone ? Colors.greenAccent.withOpacity(0.2) : const Color(0xFFC0A080).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "$_completedCount / ${_sunnahList.length} مكتملة",
                  style: TextStyle(
                    color: isAllDone ? Colors.greenAccent : const Color(0xFFC0A080),
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.secondaryDark,
              valueColor: AlwaysStoppedAnimation<Color>(
                isAllDone ? Colors.greenAccent : const Color(0xFFC0A080),
              ),
              minHeight: 8,
            ),
          ),
          if (isAllDone) ...[
            const SizedBox(height: 12),
            const Text(
              "أحسنت! أتممت جميع سنن وآداب يوم الجمعة 🎉",
              style: TextStyle(color: Colors.greenAccent, fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ]
        ],
      ),
    );
  }

  // --- عنصر السنة المفردة (Checkbox Tile) ---
  Widget _buildSunnahTile(Map<String, dynamic> item) {
    bool isDone = item['isDone'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDone ? Colors.greenAccent.withOpacity(0.5) : const Color(0xFFC0A080).withOpacity(0.2),
        ),
      ),
      child: CheckboxListTile(
        activeColor: Colors.greenAccent,
        checkColor: AppColors.primaryDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        title: Text(
          item['title'],
          style: TextStyle(
            color: isDone ? Colors.greenAccent : AppColors.textWhite,
            fontWeight: FontWeight.bold,
            fontSize: 15,
            decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            item['subtitle'],
            style: TextStyle(
              color: AppColors.textWhite.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ),
        value: isDone,
        onChanged: (bool? val) {
          setState(() {
            item['isDone'] = val ?? false;
          });
          HapticFeedback.lightImpact();
        },
      ),
    );
  }
}