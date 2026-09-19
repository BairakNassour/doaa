import 'package:flutter/material.dart';
import 'package:doaa/component/app_colors.dart';
import 'package:doaa/controller/quran_controller.dart';
import 'package:doaa/model/surah_model.dart';
import 'package:doaa/view/HomePage/SurahDetailsPage.dart';

class HizbDetailsPage extends StatefulWidget {
  final int initialHizb;
  const HizbDetailsPage({super.key, required this.initialHizb});

  @override
  State<HizbDetailsPage> createState() => _HizbDetailsPageState();
}

class _HizbDetailsPageState extends State<HizbDetailsPage> {
  late PageController _pageController;
  final QuranController _controller = QuranController();
  int _currentHizb = 1;
  List<Surah> _allSurahs = [];
  bool _isLoading = true;

  // خريطة دقيقة لبداية ونهاية السور في كل حزب من الأحزاب الـ 60
  // تم ضبطها لتشمل السور التي تقع ضمن نطاق كل حزب
  final Map<int, List<int>> _hizbSurahMap = {
    1: [1, 2], 2: [2, 2], 3: [2, 2], 4: [2, 2], 5: [2, 3], 6: [3, 3], 
    7: [3, 4], 8: [4, 4], 9: [4, 4], 10: [4, 4], 11: [4, 5], 12: [5, 5], 
    13: [5, 6], 14: [6, 6], 15: [6, 7], 16: [7, 7], 17: [7, 8], 18: [8, 9], 
    19: [9, 9], 20: [9, 9], 21: [9, 10], 22: [11, 11], 23: [11, 12], 24: [12, 13], 
    25: [14, 15], 26: [16, 16], 27: [16, 17], 28: [18, 18], 29: [18, 19], 30: [20, 20], 
    31: [21, 21], 32: [22, 22], 33: [23, 24], 34: [25, 25], 35: [26, 27], 36: [27, 28], 
    37: [29, 30], 38: [31, 33], 39: [33, 34], 40: [35, 36], 41: [37, 38], 42: [38, 39], 
    43: [40, 40], 44: [41, 41], 45: [42, 43], 46: [44, 45], 47: [46, 48], 48: [48, 51], 
    49: [51, 53], 50: [54, 57], 51: [58, 61], 52: [62, 66], 53: [67, 70], 54: [71, 77], 
    55: [78, 83], 56: [84, 91], 57: [92, 100], 58: [101, 108], 59: [109, 112], 60: [113, 114],
  };

  @override
  void initState() {
    super.initState();
    _currentHizb = widget.initialHizb;
    _pageController = PageController(initialPage: _currentHizb - 1);
    _loadData();
  }

  Future<void> _loadData() async {
    _allSurahs = await _controller.fetchSurahList();
    setState(() => _isLoading = false);
  }

  List<Surah> _getSurahsInHizb(int hizbNum) {
    if (_allSurahs.isEmpty) return [];
    List<int>? range = _hizbSurahMap[hizbNum];
    if (range == null) return [];
    return _allSurahs.where((s) => s.number >= range[0] && s.number <= range[1]).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.secondaryDark,
        elevation: 0,
        title: Text("الحزب $_currentHizb", 
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
                  itemCount: 60,
                  onPageChanged: (index) {
                    setState(() => _currentHizb = index + 1);
                  },
                  itemBuilder: (context, index) {
                    return _buildHizbContent(index + 1);
                  },
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildTopSurahBar() {
    List<Surah> surahs = _getSurahsInHizb(_currentHizb);
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
              label: Text(
                surahs[index].name, 
                style:  TextStyle(
                  color: AppColors.accentGold, 
                  fontSize: 14,
                  fontFamily: 'amiriquran', // استخدام الخط المطلوب
                ),
              ),
              onPressed: () => _openSurah(surahs[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHizbContent(int hizbNum) {
    List<Surah> surahs = _getSurahsInHizb(hizbNum);
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
              child: Text(
                "${surah.number}", 
                style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              surah.name, 
              style:  TextStyle(
                color:  AppColors.textWhite, 
                fontSize: 22, 
                fontFamily: 'amiriquran', // استخدام الخط المطلوب
              ),
            ),
            subtitle: Text(
              "${surah.numberOfAyahs} آية - ${surah.revelationType}", 
              style:  TextStyle(color:  AppColors.textWhite, fontSize: 12),
            ),
            trailing:  Icon(Icons.arrow_forward_ios, color: AppColors.accentGold, size: 16),
            onTap: () => _openSurah(surah),
          ),
        );
      },
    );
  }

  void _openSurah(Surah surah) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => SurahDetailsPage(
        surahNumber: surah.number,
        surahName: surah.name,
        surah: surah,
      ),
    ));
  }
}