import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:doaa/component/app_colors.dart';
import 'package:doaa/model/hisn_model.dart';

class HisnDetailPage extends StatefulWidget {
  final HisnCategory category;

  const HisnDetailPage({super.key, required this.category});

  @override
  State<HisnDetailPage> createState() => _HisnDetailPageState();
}

class _HisnDetailPageState extends State<HisnDetailPage> {
  int _currentIndex = 0;
  late List<int> _counts;

  @override
  void initState() {
    super.initState();
    _counts = widget.category.items.map((e) => e.count).toList();
  }

  void _decrementCount() {
    if (_counts[_currentIndex] > 0) {
      setState(() {
        _counts[_currentIndex]--;
      });
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.category.items.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.primaryDark,
        appBar: AppBar(title: Text(widget.category.name)),
        body: const Center(child: Text("لا تتوفر أذكار في هذا الباب حالياً")),
      );
    }

    final currentItem = widget.category.items[_currentIndex];
    final currentCount = _counts[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryDark,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.category.name,
          style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textWhite),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // مؤشر الترقيم
            Text(
              "${_currentIndex + 1} / ${widget.category.items.length}",
              style: const TextStyle(color: Color(0xFFC0A080), fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // كرت الذكر
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.secondaryDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFC0A080).withOpacity(0.2)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (currentItem.subTitle.isNotEmpty) ...[
                      Text(
                        currentItem.subTitle,
                        style: const TextStyle(color: Color(0xFFC0A080), fontSize: 14),
                      ),
                      const SizedBox(height: 15),
                    ],
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          currentItem.content,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 20,
                            height: 1.8,
                            fontFamily: 'Amiri',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    // زر العداد التفاعلي
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentCount == 0 ? Colors.grey : const Color(0xFFC0A080),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: _decrementCount,
                      child: Text(
                        currentCount > 0 ? "التكرار المتبقي: $currentCount" : "تم ✓",
                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            // أزرار التنقل (السابق / التالي)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Color(0xFFC0A080)),
                  onPressed: _currentIndex > 0
                      ? () => setState(() => _currentIndex--)
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Color(0xFFC0A080)),
                  onPressed: _currentIndex < widget.category.items.length - 1
                      ? () => setState(() => _currentIndex++)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}