// ignore_for_file: prefer__ructors

import 'package:doaa/component/ad.dart';
import 'package:doaa/component/adsKeys.dart';
import 'package:doaa/controller/ProgressController.dart';
import 'package:doaa/controller/quran_controller.dart';
import 'package:doaa/model/ayah_model.dart';
import 'package:doaa/model/surah_model.dart';
import 'package:flutter/material.dart';
import 'package:doaa/component/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter/gestures.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class SurahDetailsPage extends StatefulWidget {
  final int surahNumber;
  final String surahName;
  final Surah surah;
  final int? initialAyahNumber;

  SurahDetailsPage({
    super.key,
    required this.surahNumber,
    required this.surahName,
    required this.surah,
    this.initialAyahNumber,
  });

  @override
  State<SurahDetailsPage> createState() => _SurahDetailsPageState();
}

class _SurahDetailsPageState extends State<SurahDetailsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>(); // مفتاح لفتح الدراور
  final QuranController controller = QuranController();
  late PageController _pageController;

  late int _currentSurahNumber;
  late String _currentSurahName;

  final Map<String, List<Ayah>> _pagedAyahs = {};
  final List<String> _sortedPageKeys = [];
  List<Surah> _allSurahs = [];

  Color _selectedBgColor = AppColors.primaryDark;
  int? _savedAyahNumber;
  bool _isFullScreen = false;
  double _fontSizeFactor = 0.7;
  bool _isLoading = true;
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  

 @override
void initState() {
  super.initState();
  _pageController = PageController();
  _currentSurahNumber = widget.surahNumber;
  _currentSurahName = widget.surahName;
  _loadInitialData();
  
  // عدم تحميل الإعلان إلا إذا كانت الإعلانات مفعلة
  if (isadactivitaed) {
    _loadBannerAd();
  }
}
  @override
  void dispose() {
    _bannerAd?.dispose();
    _bannerAd = null;
    super.dispose();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    )..load();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    int? colorValue = prefs.getInt('quran_bg_color');
    double? savedFontFactor = prefs.getDouble('quran_font_factor');

    setState(() {
      if (colorValue != null) _selectedBgColor = Color(colorValue);
      if (savedFontFactor != null) _fontSizeFactor = savedFontFactor;
    });

    // جلب قائمة السور كاملة
    _allSurahs = await controller.fetchSurahList();

    // تحميل بيانات السورة الحالية (الأساسية)
    await _loadSurahData(_currentSurahNumber, clearOld: true);

    // تحميل السور المجاورة (التالي والسابق) لتحسين تجربة التصفح
    if (_currentSurahNumber < 114)
      await _loadSurahData(_currentSurahNumber + 1);
    if (_currentSurahNumber > 1)
      await _loadPreviousSurahData(_currentSurahNumber - 1);

    // --- التعديل الجوهري هنا ---
    // إذا كان هناك رقم آية ممرر من الصفحة السابقة (متابعة قراءة)
    if (widget.initialAyahNumber != null && widget.initialAyahNumber! > 0) {
      _jumpToAyah(widget.initialAyahNumber!);
    } else {
      // إذا لم يوجد، اذهب لبداية السورة بشكل طبيعي
      _jumpToSurahStart(_currentSurahNumber);
    }
  }

  void _jumpToAyah(int ayahNum) {
    // البحث في الصفحات المرتبة التي تم تحميلها
    for (int i = 0; i < _sortedPageKeys.length; i++) {
      String key = _sortedPageKeys[i];

      // نتحقق إذا كانت الآية المطلوبة موجودة ضمن آيات هذه الصفحة
      bool isTargetAyahOnThisPage = _pagedAyahs[key]!.any(
        (a) =>
            a.numberInSurah == ayahNum && a.surahNumber == _currentSurahNumber,
      );

      if (isTargetAyahOnThisPage) {
        // الانتظار حتى يتم بناء الواجهة ثم الانتقال للصفحة
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients) {
            _pageController.jumpToPage(i);
          }
        });

        // تحديث حالة الآية المختارة ليتم تظليلها برمجياً
        setState(() {
          _savedAyahNumber = ayahNum;
        });

        break; // التوقف عن البحث بمجرد العثور على الصفحة
      }
    }
  }

  Future<void> _loadSurahData(int surahNum, {bool clearOld = false}) async {
    try {
      var ayahs = await controller.fetchSurahAyahs(surahNum);
      if (!mounted) return;

      setState(() {
        if (clearOld) {
          _pagedAyahs.clear();
          _sortedPageKeys.clear();
        }
        for (var a in ayahs) {
          String key = "${a.page}";
          if (!_pagedAyahs.containsKey(key)) {
            _pagedAyahs[key] = [];
            _sortedPageKeys.add(key);
          }
          if (!_pagedAyahs[key]!.any((el) => el.number == a.number)) {
            _pagedAyahs[key]!.add(a);
          }
        }
        _sortKeys();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> _loadPreviousSurahData(int surahNum) async {
    try {
      var ayahs = await controller.fetchSurahAyahs(surahNum);
      if (!mounted) return;

      int oldLen = _sortedPageKeys.length;
      setState(() {
        for (var a in ayahs) {
          String key = "${a.page}";
          if (!_pagedAyahs.containsKey(key)) {
            _pagedAyahs[key] = [];
            _sortedPageKeys.add(key);
          }
          if (!_pagedAyahs[key]!.any((el) => el.number == a.number)) {
            _pagedAyahs[key]!.add(a);
          }
        }
        _sortKeys();
      });

      int added = _sortedPageKeys.length - oldLen;
      if (_pageController.hasClients && added > 0) {
        int currentPage = _pageController.page?.round() ?? 0;
        _pageController.jumpToPage(currentPage + added);
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  void _sortKeys() {
    _sortedPageKeys.sort((a, b) => int.parse(a).compareTo(int.parse(b)));
    for (var key in _sortedPageKeys) {
      _pagedAyahs[key]!.sort((a, b) => a.number.compareTo(b.number));
    }
  }

  void _jumpToSurahStart(int surahNum) {
    for (int i = 0; i < _sortedPageKeys.length; i++) {
      if (_pagedAyahs[_sortedPageKeys[i]]!.any(
        (a) => a.surahNumber == surahNum,
      )) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients) _pageController.jumpToPage(i);
        });
        break;
      }
    }
  }

  void _handlePageChange(int index) async {
    if (_sortedPageKeys.isEmpty || index >= _sortedPageKeys.length) return;
    String key = _sortedPageKeys[index];
    List<Ayah>? pageAyahs = _pagedAyahs[key];

    if (pageAyahs != null && pageAyahs.isNotEmpty) {
      int surahNum = pageAyahs.first.surahNumber!;

      // الحل: نبدأ بأول آية كقيمة افتراضية
      int ayahNum = pageAyahs.first.numberInSurah;

      // الفحص الذكي: إذا كانت الآية المحفوظة موجودة ضمن آيات هذه الصفحة، نحتفظ بها ولا نغيرها
      bool isSavedAyahOnThisPage = pageAyahs.any(
        (a) =>
            a.numberInSurah == _savedAyahNumber &&
            a.surahNumber == _currentSurahNumber,
      );

      if (isSavedAyahOnThisPage && _savedAyahNumber != null) {
        ayahNum =
            _savedAyahNumber!; // الإبقاء على آيتك المحفوظة ومنع دهسها بآية أخرى
      }

      if (surahNum != _currentSurahNumber) {
        setState(() {
          _currentSurahNumber = surahNum;
          _currentSurahName = _allSurahs
              .firstWhere((s) => s.number == surahNum)
              .name;
        });
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('last_surah_num', surahNum);
      await prefs.setString('last_surah_name', _currentSurahName);
      await prefs.setInt(
        'last_ayah_num',
        ayahNum,
      ); // حفظ رقم الآية الصحيح والمصون

      if (index == _sortedPageKeys.length - 1 && surahNum < 114)
        _loadSurahData(surahNum + 1);
      if (index == 0 && surahNum > 1) _loadPreviousSurahData(surahNum - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // ربط المفتاح
      backgroundColor: _selectedBgColor,
      drawer: _buildQuranDrawer(),
      bottomNavigationBar: (_isBannerAdLoaded && _bannerAd != null && !_isFullScreen)
          ? SafeArea(
            child: Container(
                color: _selectedBgColor, // جعل لون خلفية الإعلان متناسقاً مع لون الصفحة
                width: double.infinity,
                height: _bannerAd!.size.height.toDouble(),
                child: Center(
                  child: AdWidget(ad: _bannerAd!),
                ),
              ),
          )
          : null,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.accentGold),
            )
          : SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      // تم استبدال الـ AppBar بـ Indicator ليكون أكثر انسيابية
                      if (!_isFullScreen) ...[
                        SizedBox(height: 10),
                        SmoothPageIndicator(
                          controller: _pageController,
                          count: _sortedPageKeys.length,
                          effect: ScrollingDotsEffect(
                            activeDotColor: AppColors.accentGold,
                            dotHeight: 6,
                            dotWidth: 6,
                          ),
                        ),
                      ],
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          reverse: true,
                          itemCount: _sortedPageKeys.length,
                          onPageChanged: _handlePageChange,
                          itemBuilder: (context, index) {
                            String key = _sortedPageKeys[index];
                            return _buildPageContent(key, _pagedAyahs[key]!);
                          },
                        ),
                      ),
                    ],
                  ),
                

                  // أيقونة الفتح الجانبي (بديلة للـ AppBar)
                  if (!_isFullScreen)
                    // ignore_for_file: prefer__ructors
                    Positioned(
                      top: 15,
                      right: 5, // إبقاء المسافة القريبة "على الميني"
                      child: GestureDetector(
                        onTap: () => _scaffoldKey.currentState?.openDrawer(),
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color:
                                _selectedBgColor, // نفس لون خلفية الصفحة (Opaque) لمنع تداخل الإطار
                            shape: BoxShape.circle, // شكل دائري
                            border: Border.all(
                              // إضافة إطار رفيع جداً للتباين
                              color: _selectedBgColor.computeLuminance() < 0.5
                                  ? AppColors.accentGold.withOpacity(0.5)
                                  : Colors.brown[900]!.withOpacity(0.3),
                              width: 0.8,
                            ),
                            boxShadow: [
                              // ظل خفيف جداً لإعطاء بعد للأيقونة
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.menu_open_rounded,
                            // لون الأيقونة بتباين عالٍ (ذهبي للداكن، بني للفاتح)
                            color: _selectedBgColor.computeLuminance() < 0.5
                                ? AppColors.accentGold
                                : Colors.brown[900],
                            size: 26, // تقليل الحجم قليلاً ليتناسب مع الدائرة
                          ),
                        ),
                      ),
                    ),

                  // زر ملء الشاشة
                  Positioned(
                    right: 20,
                    bottom: 20,
                    child: FloatingActionButton.small(
                      onPressed: () =>
                          setState(() => _isFullScreen = !_isFullScreen),
                      backgroundColor: AppColors.accentGold.withOpacity(0.8),
                      child: Icon(
                        _isFullScreen
                            ? Icons.fullscreen_exit
                            : Icons.fullscreen,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildPageContent(String key, List<Ayah> pageData) {
    bool isDark = _selectedBgColor.computeLuminance() < 0.5;

    String juzInfo = "الجزء ${pageData.first.juz}";
    String hizbInfo = "الحزب ${pageData.first.hizbQuarter ?? 1}";
    String surahHeader = _allSurahs
        .firstWhere((s) => s.number == pageData.first.surahNumber)
        .name;

    return Stack(
      children: [
        Positioned.fill(
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Image.asset(
              'assets/quranborder.png',
              fit: BoxFit.fill,
              color: isDark ? Color(0xFFB8860B) : null,
              colorBlendMode: isDark ? BlendMode.modulate : null,
            ),
          ),
        ),
        Positioned(
          top: 10,
          left: 45,
          right: 45,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _headerBadge(juzInfo, isDark),
              _headerBadge(surahHeader, isDark),
              _headerBadge(hizbInfo, isDark),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(35, 55, 35, 45),
          child: Center(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: _buildAyahRichText(pageData, isDark),
            ),
          ),
        ),
        Positioned(
          bottom: 15,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              "${pageData.first.page}",
              style: TextStyle(
                color: isDark ? AppColors.accentGold : Colors.brown[900],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _headerBadge(String text, bool isDark) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 2),
    decoration: BoxDecoration(
      color: !isDark
          ? AppColors.textWhite
          : AppColors.primaryDark.withOpacity(0.7),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isDark ? AppColors.accentGold.withOpacity(0.5) : Colors.black,
        width: 0.5,
      ),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontFamily: 'QuranFont',
        fontWeight: FontWeight.bold,
        color: isDark ? AppColors.accentGold : AppColors.primaryDark,
      ),
    ),
  );

  Widget _buildAyahRichText(List<Ayah> pageData, bool isDark) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: RichText(
        textAlign: TextAlign.justify,
        textWidthBasis: TextWidthBasis.longestLine,

        text: TextSpan(
          children: [
            for (int i = 0; i < pageData.length; i++) ...[
              if (pageData[i].numberInSurah == 1) ...[
                WidgetSpan(
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 10),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              'assets/quran.png',
                              width: double.infinity,
                              height: 55,
                              fit: BoxFit.fill,
                              color: isDark
                                  ? Color.fromARGB(255, 255, 245, 152)
                                  : null,
                              colorBlendMode: isDark
                                  ? BlendMode.modulate
                                  : null,
                            ),
                            Text(
                              _allSurahs
                                  .firstWhere(
                                    (s) => s.number == pageData[i].surahNumber,
                                  )
                                  .name,
                              style: TextStyle(
                                fontFamily: 'QuranFont',
                                fontSize: 20,
                                color: isDark
                                    ? AppColors.accentGold
                                    : Colors.brown[900],
                              ),
                            ),
                          ],
                        ),
                        if (pageData[i].surahNumber != 9 &&
                            pageData[i].surahNumber != 1)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            child: Text(
                              "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.amiriQuran(
                                fontSize: 24,
                                color: AppColors.accentGold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
              TextSpan(
                text: () {
                  String content = pageData[i].text.trim();
                  if (pageData[i].numberInSurah == 1 &&
                      pageData[i].surahNumber != 9 &&
                      pageData[i].surahNumber != 1) {
                    String basmalah = "بِسۡمِ ٱللَّهِ ٱلرَّحۡمَـٰنِ ٱلرَّحِیمِ";
                    if (content.startsWith(basmalah)) {
                      content = content.replaceFirst(basmalah, "").trim();
                    }
                  }
                  return content;
                }(),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => _saveMark(pageData[i]),
                style: GoogleFonts.amiriQuran(
                  fontSize: (28 * _fontSizeFactor).clamp(10, 48),
                  height: 1.9,
                  wordSpacing: -1.5,
                  color: isDark ? Colors.white : Colors.black87,
                  backgroundColor:
                      (_savedAyahNumber == pageData[i].numberInSurah &&
                          _currentSurahNumber == pageData[i].surahNumber)
                      ? AppColors.accentGold.withOpacity(0.2)
                      : null,
                ),
              ),
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: GestureDetector(
                  onTap: () => _saveMark(pageData[i]),
                  child: _ayahIcon(
                    pageData[i].numberInSurah,
                    pageData[i].surahNumber!,
                    isDark,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _ayahIcon(int num, int sNum, bool isDark) {
    bool isSaved = _savedAyahNumber == num && _currentSurahNumber == sNum;
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          'assets/ayah_frame.png',
          width: 28,
          height: 28,
          color: isSaved
              ? Colors.blue
              : (isDark ? AppColors.accentGold : Colors.blue[700]),
        ),
        Text(
          "$num",
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: isSaved
                ? Colors.blue
                : (isDark ? AppColors.textWhite : Colors.black),
          ),
        ),
      ],
    );
  }

  void _saveMark(Ayah ayah) async {
    final prefs = await SharedPreferences.getInstance();

    // 1. الحفظ المحلي المعتاد
    await prefs.setInt('last_surah_num', ayah.surahNumber!);
    await prefs.setInt('last_ayah_num', ayah.numberInSurah);
    await prefs.setString('last_surah_name', _currentSurahName);

    setState(() => _savedAyahNumber = ayah.numberInSurah);

    // 2. 🔥 إضافة الشرط لإرسال التقدم للسيرفر
    // نقوم بإنشاء نسخة من الكنترولر
    final progressController = ProgressController();

    // نتحقق إذا كانت هذه آخر آية في سورة الناس (سورة 114)
    // ملاحظة: عدد آيات سورة الناس هو 6
    bool isLastAyahInQuran =
        (ayah.surahNumber == 114 && ayah.numberInSurah == 6);

    await progressController.updateRemoteProgress('quran', {
      'surah_num': ayah.surahNumber,
      'surah_name': _currentSurahName,
      'ayah_num': ayah.numberInSurah,
      // إذا كانت آخر آية في المصحف، نرسل الحالة 'completed' ليحسب السيرفر الختمة
      'status': isLastAyahInQuran ? 'completed' : 'reading',
    });

    // 3. عرض رسالة التأكيد
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isLastAyahInQuran
              ? "مبارك! تم تسجيل ختمة جديدة وحفظ العلامة"
              : "تم حفظ العلامة آية ${ayah.numberInSurah}",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.primaryDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.accentGold,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // --- القائمة الجانبية المعدلة ---
  Widget _buildQuranDrawer() {
    return Drawer(
      backgroundColor: AppColors.primaryDark,
      child: Column(
        children: [
          // رأس القائمة يحتوي على الإعدادات
          Container(
            padding: EdgeInsets.fromLTRB(15, 50, 15, 20),
            color: AppColors.secondaryDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "إعدادات القراءة",
                  style: TextStyle(
                    color: AppColors.accentGold,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                // التحكم في حجم الخط
                Text(
                  "حجم الخط",
                  style: TextStyle(color: AppColors.textWhite, fontSize: 13),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.text_fields,
                      color: AppColors.textWhite,
                      size: 16,
                    ),
                    Expanded(
                      child: Slider(
                        value: _fontSizeFactor,
                        min: 0.5,
                        max: 2.0,
                        activeColor: AppColors.accentGold,
                        onChanged: (v) async {
                          setState(() => _fontSizeFactor = v);
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setDouble('quran_font_factor', v);
                        },
                      ),
                    ),
                    Text(
                      "${(_fontSizeFactor * 100).toInt()}%",
                      style: TextStyle(
                        color: AppColors.textWhite,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                // التحكم في اللون
                Text(
                  "لون الخلفية",
                  style: TextStyle(color: AppColors.textWhite, fontSize: 13),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _colorDrawerOption(AppColors.primaryDark),
                    _colorDrawerOption(Color(0xFFF5E6CA)),
                    _colorDrawerOption(
                      const Color.fromARGB(255, 216, 237, 255),
                    ),
                    _colorDrawerOption(Color(0xFFE8F5E9)),
                  ],
                ),
              ],
            ),
          ),

          // قائمة السور (الفهرس)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "الفهرس",
              style: TextStyle(
                color: AppColors.accentGold,
                fontSize: 20,
                fontFamily: 'QuranFont',
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _allSurahs.length,
              itemBuilder: (context, i) => ListTile(
                selected: _allSurahs[i].number == _currentSurahNumber,
                selectedTileColor: AppColors.accentGold.withOpacity(0.1),
                title: Text(
                  _allSurahs[i].name,
                  style: TextStyle(
                    color: _allSurahs[i].number == _currentSurahNumber
                        ? AppColors.accentGold
                        : AppColors.textWhite,
                    fontFamily: 'QuranFont',
                    fontSize: 17,
                  ),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  setState(() => _isLoading = true);
                  _currentSurahNumber = _allSurahs[i].number;
                  _currentSurahName = _allSurahs[i].name;
                  await _loadSurahData(_currentSurahNumber, clearOld: true);
                  _jumpToSurahStart(_currentSurahNumber);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorDrawerOption(Color color) => InkWell(
    onTap: () async {
      setState(() => _selectedBgColor = color);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('quran_bg_color', color.value);
    },
    child: Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: _selectedBgColor == color
              ? AppColors.accentGold
              : AppColors.textWhite,
          width: 2,
        ),
      ),
    ),
  );
}
