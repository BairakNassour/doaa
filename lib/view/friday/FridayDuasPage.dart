import 'package:doaa/component/app_colors.dart';
import 'package:doaa/controller/dua_controller.dart';
import 'package:doaa/model/dua_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class FridayDuasPage extends StatefulWidget {
  const FridayDuasPage({super.key});

  @override
  State<FridayDuasPage> createState() => _FridayDuasPageState();
}

class _FridayDuasPageState extends State<FridayDuasPage> {
  final DuaController _duaController = DuaController();
  late Future<List<DuaCategory>> _futureDuas;

  // خريطة لتتبع عداد الأدعية التفاعلية
  final Map<int, int> _duaCounts = {};

  @override
  void initState() {
    super.initState();
    // استدعاء البيانات وتمرير التايب gomaa
    _futureDuas = _duaController.fetchAllData("gomaa");
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
            "أدعية يوم الجمعة".tr,
            style: TextStyle(
              color: AppColors.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: FutureBuilder<List<DuaCategory>>(
          future: _futureDuas,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFFC0A080)),
              );
            }

            if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off_rounded, color: Color(0xFFC0A080), size: 50),
                    const SizedBox(height: 15),
                    Text(
                      "لا تتوفر أدعية حالياً أو حدث خطأ في الاتصال",
                      style: TextStyle(color: AppColors.textWhite),
                    ),
                  ],
                ),
              );
            }

            final categories = snapshot.data!;

            return ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: categories.length,
              itemBuilder: (context, catIndex) {
                final category = categories[catIndex];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // عنوان الفئة (مثل: دعاء الفرج)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: Color(0xFFC0A080), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            category.name ?? "أدعية الجمعة",
                            style: TextStyle(
                              color: const Color(0xFFC0A080),
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // عرض قائمة عناصر الدعاء داخل الفئة
                    ...List.generate(category.items?.length ?? 0, (itemIndex) {
                      final item = category.items![itemIndex];
                      
                      // تهيئة العداد لكل عنصر دعاء
                      _duaCounts.putIfAbsent(item.id!, () => item.count ?? 1);

                      return _buildDuaCard(item);
                    }),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  // --- بناء بطاقة الدعاء الفردية ---
  Widget _buildDuaCard(dynamic item) {
    int currentCount = _duaCounts[item.id] ?? 1;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFC0A080).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.subTitle != null && item.subTitle.isNotEmpty) ...[
            Text(
              item.subTitle,
              style: TextStyle(
                color: const Color(0xFFC0A080).withOpacity(0.9),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
          ],

          // نص الدعاء
          Text(
            item.content ?? "",
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 18,
              height: 1.8,
              fontFamily: 'Amiri',
            ),
          ),

          const SizedBox(height: 15),
          const Divider(color: Color(0xFFC0A080), thickness: 0.3),
          const SizedBox(height: 5),

          // شريط أدوات الدعاء (المشاركة + العداد)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.copy_rounded, color: Color(0xFFC0A080), size: 22),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: item.content ?? ""));
                  Get.snackbar(
                    "تم النسخ",
                    "تم نسخ نص الدعاء بنجاح",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.primaryDark,
                    colorText: AppColors.textWhite,
                  );
                },
              ),

              // زر العداد التفاعلي
              InkWell(
                onTap: () {
                  if (currentCount > 0) {
                    setState(() {
                      _duaCounts[item.id!] = currentCount - 1;
                    });
                    HapticFeedback.lightImpact();
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: currentCount == 0
                        ? Colors.greenAccent.withOpacity(0.2)
                        : const Color(0xFFC0A080).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: currentCount == 0 ? Colors.greenAccent : const Color(0xFFC0A080),
                    ),
                  ),
                  child: Text(
                    currentCount == 0 ? "تم التكرار ✓" : "التكرار: $currentCount",
                    style: TextStyle(
                      color: currentCount == 0 ? Colors.greenAccent : const Color(0xFFC0A080),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
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
}