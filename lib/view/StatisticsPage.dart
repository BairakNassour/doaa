import 'package:doaa/component/app_colors.dart';
import 'package:doaa/controller/ProgressController.dart';
import 'package:doaa/model/user_progress_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final ProgressController _progressController = ProgressController();

  // 0: التسبيح, 1: الأدعية والأذكار
  int _activeTab = 0;
  // 0: شهر, 1: أسبوع, 2: يوم
  int _selectedPeriodIndex = 2;
  int _dailyStreak = 0;

  @override
  void initState() {
    super.initState();
    _loadStreak();
  }

  void _loadStreak() async {
    int streak = await _progressController.updateAndGetStreak();
    setState(() {
      _dailyStreak = streak;
    });
  }

  // 🔥 دالة ذكية تعتمد على الحقل المعالج داخل الموديل الخاص بك وتُحوله للتوقيت المحلي للجهاز
  DateTime _parseItemDate(UserProgressModel item) {
    if (item.createdAt != null) {
      return item.createdAt!.toLocal(); // تحويل UTC إلى توقيت هاتف المستخدم المحلي لضمان دقة اليوم الحقيقي
    }
    return DateTime.now();
  }

  // دالة الفحص والمقارنة الزمنية الدقيقة لليوم والأسبوع والشهر
  bool _isInPeriod(DateTime date, int periodIndex) {
    final now = DateTime.now();
    if (periodIndex == 2) { // اليوم
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    } else if (periodIndex == 1) { // الأسبوع (آخر 7 أيام)
      final lastWeek = now.subtract(const Duration(days: 7));
      return date.isAfter(lastWeek);
    } else { // الشهر الحالي
      return date.year == now.year && date.month == now.month;
    }
  }

  // دالة حساب المجموع الفعلي المطور بناءً على حقول الموديل الجديد
  int _calculateSum(List<UserProgressModel> items, int periodIndex) {
    int total = 0;
    for (var item in items) {
      DateTime itemDate = _parseItemDate(item); // استخدام الدالة المحدثة لتمرير الكائن بالكامل

      if (_isInPeriod(itemDate, periodIndex)) {
        if (_activeTab == 0) {
          // استخدام حقل displayCount الذكي الذي قمت بإضافته في الموديل
          int countValue = int.tryParse(item.displayCount) ?? 0;
          total += countValue;
        } else {
          // في حال الأذكار: نعد السجلات (لأن الذكر يُنجز كعمل كامل)
          total += 1;
        }
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        title: Text(
          'stats_title'.tr,
          style: TextStyle(
            color: AppColors.accentGold,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.accentGold),
          onPressed: () => Get.back(),
        ),
      ),
      body: FutureBuilder<List<UserProgressModel>>(
        future: _progressController.getAllStats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.accentGold),
            );
          }

          final allStats = snapshot.data ?? [];

          // تصفية البيانات حسب النوع المختار في التاب السفلي (تأخذ بالاعتبار حالة الأحرف)
          final filteredByCategory = allStats.where((item) {
            bool isTasbih = item.category.toLowerCase().contains('tasbeeh') || 
                            item.category.toLowerCase().contains('tasbih');
            return _activeTab == 0 ? isTasbih : !isTasbih;
          }).toList();

          final badges = _calculateBadges(allStats);

          // الحسابات المعدلة للمجاميع الفعلية المتوافقة مع جهاز المستخدم المحلي
          int daySum = _calculateSum(filteredByCategory, 2);
          int weekSum = _calculateSum(filteredByCategory, 1);
          int monthSum = _calculateSum(filteredByCategory, 0);
          
          // المجموع الكلي التراكمي (Lifetime)
          int totalLifetime = 0;
          if (_activeTab == 0) {
            for (var item in filteredByCategory) {
              totalLifetime += int.tryParse(item.displayCount) ?? 0;
            }
          } else {
            totalLifetime = filteredByCategory.length;
          }

          // تصفية السجلات التفصيلية التي ستظهر في الأسفل لتعرض فقط السجلات المناسبة للمدة الزمنية المفعلة
          final displayList = filteredByCategory.where((item) {
            DateTime itemDate = _parseItemDate(item);
            return _isInPeriod(itemDate, _selectedPeriodIndex);
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildCategoryTabs(),
                const SizedBox(height: 20),
                _buildMainStatsGrid(
                  day: daySum.toString(),
                  week: weekSum.toString(),
                  month: monthSum.toString(),
                  streak: _dailyStreak.toString(),
                ),
                const SizedBox(height: 20),
                _buildLifeTimeCard(totalLifetime),
                const SizedBox(height: 15),
                _buildBadgesSection(badges),
                const SizedBox(height: 25),
                _buildPeriodSelector(),
                const SizedBox(height: 20),
                Text(
                  "activity_details".tr,
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                displayList.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            "no_records_found".tr,
                            style: TextStyle(color: AppColors.textGrey),
                          ),
                        ),
                      )
                    : _buildDetailedList(displayList),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryDark,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [_tabItem("الأدعية والأذكار", 1), _tabItem("التسبيح", 0)],
      ),
    );
  }

  Widget _tabItem(String title, int index) {
    bool isActive = _activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _activeTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.accentGold.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(15),
            border: isActive ? Border.all(color: AppColors.accentGold) : null,
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isActive ? AppColors.accentGold : AppColors.textGrey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainStatsGrid({
    required String day,
    required String week,
    required String month,
    required String streak,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          margin: const EdgeInsets.only(bottom: 15),
          decoration: BoxDecoration(
            color: AppColors.secondaryDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_fire_department, color: Colors.orange, size: 40),
              const SizedBox(width: 10),
              Text(
                "$streak أيام متتالية",
                style: TextStyle(color: AppColors.textWhite, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Row(
          children: [
            _buildStatSquare("اليوم", day, Icons.today, Colors.green),
            const SizedBox(width: 8),
            _buildStatSquare("الأسبوع", week, Icons.date_range, Colors.cyan),
            const SizedBox(width: 8),
            _buildStatSquare("الشهر", month, Icons.calendar_month, AppColors.accentGold),
          ],
        ),
      ],
    );
  }

  Widget _buildStatSquare(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppColors.secondaryDark,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(color: AppColors.textGrey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLifeTimeCard(int total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondaryDark,
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [AppColors.secondaryDark, AppColors.accentGold.withOpacity(0.1)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "الإجمالي الكلي",
                style: TextStyle(color: AppColors.textGrey, fontSize: 12),
              ),
              Text(
                total.toString(),
                style: TextStyle(
                  color: AppColors.accentGold,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Icon(Icons.all_inclusive, color: AppColors.accentGold, size: 40),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: ["الشهر", "الأسبوع", "اليوم"].asMap().entries.map((entry) {
        bool isSelected = _selectedPeriodIndex == entry.key;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedPeriodIndex = entry.key),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.accentGold : AppColors.secondaryDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  entry.value,
                  style: TextStyle(
                    color: isSelected ? AppColors.primaryDark : AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDetailedList(List<UserProgressModel> stats) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        final String actualCount = stat.displayCount; // جلب العداد الموحد مباشرة من موديلك الذكي
        DateTime itemDate = _parseItemDate(stat); // التاريخ بعد ضبط توقيته محلياً لشاشة العرض

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.secondaryDark,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Icon(
                _getIconForCategory(stat.category),
                color: AppColors.accentGold,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getCategoryName(stat.category, stat.details),
                      style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _getDynamicDetail(stat),
                      style: TextStyle(color: AppColors.textGrey, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _activeTab == 0 ? "+$actualCount" : "تم",
                    style: TextStyle(
                      color: AppColors.accentGold, 
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    DateFormat('hh:mm a').format(itemDate),
                    style: TextStyle(color: AppColors.textGrey.withOpacity(0.5), fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _getCategoryName(String cat, Map<String, dynamic> details) {
    String categoryLower = cat.toLowerCase();
    if (categoryLower == 'quran') return "القرآن الكريم";
    if (categoryLower.contains('tasbeeh') || categoryLower.contains('tasbih')) {
      return details['dhikr_name'] ?? "التسبيح";
    }
    if (categoryLower == 'azkar') {
      String type = details['type']?.toString() ?? "";
      if (type == 'morning') return "أذكار الصباح";
      if (type == 'evening') return "أذكار المساء";
      return "الأذكار والأدعية";
    }
    return "عمل صالح";
  }

  String _getDynamicDetail(UserProgressModel stat) {
    final d = stat.details;
    if (stat.category.toLowerCase() == 'quran') return "سورة ${d['surah_name'] ?? '...'}";
    if (d['status'] == 'completed') return "تم الإتمام بنجاح";
    return d['content_preview'] ?? "تم الإنجاز بنجاح";
  }

  IconData _getIconForCategory(String cat) {
    String categoryLower = cat.toLowerCase();
    if (categoryLower == 'quran') return Icons.menu_book;
    if (categoryLower.contains('tasbeeh') || categoryLower.contains('tasbih')) return Icons.fingerprint;
    return Icons.done_all;
  }

  List<Map<String, dynamic>> _calculateBadges(List<UserProgressModel> allStats) {
    List<Map<String, dynamic>> badges = [];
    int adkarCount = allStats.where((i) => i.category.toLowerCase() == 'azkar').length;
    if (adkarCount >= 10) {
      badges.add({'title': 'المداوم', 'icon': Icons.auto_awesome, 'color': Colors.orange});
    }
    int tasbihSum = 0;
    for (var i in allStats) {
      if (i.category.toLowerCase().contains('tasbeeh') || i.category.toLowerCase().contains('tasbih')) {
        tasbihSum += int.tryParse(i.displayCount) ?? 0;
      }
    }
    if (tasbihSum >= 1000) {
      badges.add({'title': 'الألفية', 'icon': Icons.fingerprint, 'color': Colors.cyan});
    }
    return badges;
  }

  Widget _buildBadgesSection(List<Map<String, dynamic>> badges) {
    if (badges.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text("الأوسمة المستحقة", style: TextStyle(color: AppColors.textWhite, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            reverse: true,
            itemCount: badges.length,
            itemBuilder: (context, index) {
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: AppColors.secondaryDark,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(badges[index]['icon'], color: badges[index]['color'], size: 25),
                    Text(badges[index]['title'], style: TextStyle(color: AppColors.textWhite, fontSize: 9)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}