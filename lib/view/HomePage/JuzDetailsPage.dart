import 'package:flutter/material.dart';
import 'package:doaa/component/app_colors.dart';
import 'package:doaa/controller/quran_controller.dart';
import 'package:doaa/model/surah_model.dart';
import 'package:doaa/view/HomePage/SurahDetailsPage.dart';

class JuzDetailsPage extends StatefulWidget {
  final int initialJuz;
  const JuzDetailsPage({super.key, required this.initialJuz});

  @override
  State<JuzDetailsPage> createState() => _JuzDetailsPageState();
}

class _JuzDetailsPageState extends State<JuzDetailsPage> {
  late PageController _pageController;
  final QuranController _controller = QuranController();
  int _currentJuz = 1;
  List<Surah> _allSurahs = [];
  bool _isLoading = true;

  // خريطة دقيقة لبداية ونهاية السور في كل جزء (رقم السورة البداية - رقم السورة النهاية)
  // ملاحظة: بعض الأجزاء تنتهي في منتصف السورة، لذا المنطق هنا سيجلب السور التي تتقاطع مع الجزء
  final Map<int, List<int>> _juzSurahMap = {
    1: [1, 2], 2: [2, 2], 3: [2, 3], 4: [3, 4], 5: [4, 4],
    6: [4, 5], 7: [5, 6], 8: [6, 7], 9: [7, 8], 10: [8, 9],
    11: [9, 11], 12: [11, 12], 13: [12, 14], 14: [15, 16], 15: [17, 18],
    16: [18, 20], 17: [21, 22], 18: [23, 25], 19: [25, 27], 20: [27, 29],
    21: [29, 33], 22: [33, 36], 23: [36, 39], 24: [39, 41], 25: [42, 45],
    26: [46, 51], 27: [52, 57], 28: [58, 66], 29: [67, 77], 30: [78, 114],
  };

  @override
  void initState() {
    super.initState();
    _currentJuz = widget.initialJuz;
    _pageController = PageController(initialPage: _currentJuz - 1);
    _loadData();
  }

  Future<void> _loadData() async {
    _allSurahs = await _controller.fetchSurahList();
    setState(() => _isLoading = false);
  }

  // دالة لجلب سور جزء معين بناءً على التقسيم الفعلي للقرآن
  List<Surah> _getSurahsInJuz(int juzNum) {
    if (_allSurahs.isEmpty) return [];
    List<int> range = _juzSurahMap[juzNum]!;
    return _allSurahs.where((s) => s.number >= range[0] && s.number <= range[1]).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondaryDark,
        elevation: 0,
        title: Text("الجزء $_currentJuz", 
          style:  TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading 
        ?  Center(child: CircularProgressIndicator(color: AppColors.accentGold))
        : Column(
            children: [
              _buildTopSurahBar(),
               Divider(color:  AppColors.textWhite, height: 1),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  reverse: true, 
                  itemCount: 30,
                  onPageChanged: (index) {
                    setState(() => _currentJuz = index + 1);
                  },
                  itemBuilder: (context, index) {
                    return _buildJuzContent(index + 1);
                  },
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildTopSurahBar() {
    List<Surah> surahs = _getSurahsInJuz(_currentJuz);
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        reverse: true,
        itemCount: surahs.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ActionChip(
              backgroundColor: AppColors.secondaryDark,
              label: Text(surahs[index].name, 
                style:  TextStyle(
                  color: AppColors.accentGold, 
                  fontSize: 14, 
                  fontFamily: 'amiriquran' // استخدام الخط المطلوب هنا
                )),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => SurahDetailsPage(
                    surahNumber: surahs[index].number,
                    surahName: surahs[index].name,
                    surah: surahs[index],
                  ),
                ));
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildJuzContent(int juzNum) {
    List<Surah> surahs = _getSurahsInJuz(juzNum);
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        final surah = surahs[index];
        return Card(
          color: AppColors.secondaryDark.withOpacity(0.3),
          margin: const EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.accentGold,
              radius: 18,
              child: Text("${surah.number}", 
                style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
            title: Text(surah.name, 
              style:  TextStyle(
                color:  AppColors.textWhite, 
                fontSize: 22, 
                fontFamily: 'amiriquran' // استخدام الخط المطلوب هنا
              )),
            subtitle: Text("${surah.numberOfAyahs} آية - ${surah.revelationType}", 
              style:  TextStyle(color:  AppColors.textWhite, fontSize: 12)),
            trailing:  Icon(Icons.arrow_forward_ios, color: AppColors.accentGold, size: 16),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => SurahDetailsPage(
                  surahNumber: surah.number,
                  surahName: surah.name,
                  surah: surah,
                ),
              ));
            },
          ),
        );
      },
    );
  }
}