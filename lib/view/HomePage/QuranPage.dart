import 'dart:io'; // سيتم استخدام Platform
import 'dart:io';
import 'package:doaa/component/adsKeys.dart';
import 'package:flutter/foundation.dart';
import 'package:doaa/component/app_colors.dart';
import 'package:doaa/component/generalBoxDecoration.dart';
import 'package:doaa/controller/quran_controller.dart';
import 'package:doaa/controller/ProgressController.dart';
import 'package:doaa/model/surah_model.dart';
import 'package:doaa/view/HomePage/AyatAudio.dart';
import 'package:doaa/view/HomePage/HizbDetailsPage.dart';
import 'package:doaa/view/HomePage/JuzDetailsPage.dart';
import 'package:doaa/view/HomePage/SurahDetailsPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // 🔥 استيراد حزمة الإعلانات
import 'package:doaa/component/ad.dart'; // 🔥 استيراد ملف التحكم بالإعلانات الخاص بك

class QuranPage extends StatefulWidget {
  QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  final QuranController _quranController = QuranController();
  final ProgressController _progressController = ProgressController();
  late Future<List<Surah>> _surahFuture;

  // متغيرات الإعلان البيني
  // InterstitialAd? _interstitialAd;
  // bool _isAdLoaded = false;

  // // 🔥 متغير للتحقق مما إذا كان قد تم عرض الإعلان في هذه الجلسة (الدخول الحالي لصفحة القرآن)
  // bool _hasShownAdInSession = false;

  // معرفات الإعلانات البينية التجريبية للاختبار للأندرويد والـ iOS
  // String get interstitialAdUnitId {
  //   return Platform.isAndroid
  //       ? 'ca-app-pub-3940256099942544/1033173712'
  //       : 'ca-app-pub-3940256099942544/4411468910';
  // }

  // معرفات إعلانات البنر التجريبية للعرض داخل المحتوى
  

  @override
  void initState() {
    super.initState();
    _surahFuture = _quranController.fetchSurahList();

    // 🔥 إذا كانت الإعلانات مفعلة من ملف ad.dart نقوم بتهيئتها وتحميلها مبكراً
    // if (isadactivitaed) {
    //   _loadInterstitialAd();
    // }
  }

  // دالة تحميل الإعلان البيني
  // void _loadInterstitialAd() {
  //   InterstitialAd.load(
  //     adUnitId: interstitialAdUnitId,
  //     request: const AdRequest(),
  //     adLoadCallback: InterstitialAdLoadCallback(
  //       onAdLoaded: (ad) {
  //         setState(() {
  //           _interstitialAd = ad;
  //           _isAdLoaded = true;
  //         });
  //       },
  //       onAdFailedToLoad: (LoadAdError error) {
  //         debugPrint('فشل تحميل إعلان القرآن البيني: $error');
  //         _isAdLoaded = false;
  //       },
  //     ),
  //   );
  // }

  // دالة الفحص وعرض الإعلان لمرة واحدة فقط في الجلسة الواحدة
  // void _showAdWithCallback(VoidCallback onAdClosed) {
  //   // 🔥 إذا تم عرض الإعلان مسبقاً في هذه الجلسة، تخطى الإعلان وافتح الصفحة فوراً
  //   if (_hasShownAdInSession) {
  //     onAdClosed();
  //     return;
  //   }

  //   if (isadactivitaed && _isAdLoaded && _interstitialAd != null) {
  //     _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
  //       onAdDismissedFullScreenContent: (ad) {
  //         ad.dispose();
  //         _loadInterstitialAd(); // تحميل إعلان جديد للمرة القادمة
  //         _hasShownAdInSession = true; // 🔥 حفظ أنه تم عرض الإعلان في هذه الجلسة
  //         onAdClosed();
  //       },
  //       onAdFailedToShowFullScreenContent: (ad, error) {
  //         ad.dispose();
  //         _loadInterstitialAd();
  //         onAdClosed();
  //       },
  //     );
  //     _interstitialAd!.show();
  //   } else {
  //     onAdClosed(); // الانتقال المباشر إذا كانت الإعلانات معطلة أو لم يتم تحميلها بعد
  //   }
  // }

  Future<Map<String, dynamic>> _getLastReadData() async {
    final prefs = await SharedPreferences.getInstance();

    int localSurahNum = prefs.getInt('last_surah_num') ?? 1;
    String localSurahName =
        prefs.getString('last_surah_name') ?? 'سورة الفاتحة';
    int localAyahNum = prefs.getInt('last_ayah_num') ?? 0;

    if (localSurahNum != 1 || localAyahNum != 0) {
      return {
        'surahName': localSurahName,
        'surahNum': localSurahNum,
        'ayahNum': localAyahNum,
        'isRemote': false,
      };
    }

    try {
      final remoteData = await _progressController.getRemoteProgress('quran');
      if (remoteData != null && remoteData['details'] != null) {
        var details = remoteData['details'];
        return {
          'surahName': details['surah_name'] ?? 'سورة الفاتحة',
          'surahNum': details['surah_num'] ?? 1,
          'ayahNum': details['ayah_num'] ?? 0,
          'isRemote': true,
        };
      }
    } catch (e) {
      debugPrint("Remote error: $e");
    }

    return {
      'surahName': 'سورة الفاتحة',
      'surahNum': 1,
      'ayahNum': 0,
      'isRemote': false,
    };
  }

  // @override
  // void dispose() {
  //   _interstitialAd?.dispose(); // تفريغ الذاكرة من الإعلان عند الخروج
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.secondaryDark,
        appBar: AppBar(
          backgroundColor: AppColors.secondaryDark,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'القرآن الكريم',
            style: TextStyle(
              color: AppColors.accentGold,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: TabBar(
            indicatorColor: AppColors.accentGold,
            labelColor: AppColors.accentGold,
            unselectedLabelColor: AppColors.textWhite,
            tabs: [
              Tab(text: 'السور'),
              Tab(text: 'الأجزاء'),
              Tab(text: 'الأحزاب'),
            ],
          ),
        ),
        body: Container(
          decoration: getBoxDecoration(),
          child: Column(
            children: [
              _buildLastReadCard(),
              Expanded(
                child: TabBarView(
                  children: [
                    _buildSurahList(),
                    _buildJuzList(),
                    _buildHizbList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- كارد آخر قراءة مع زر المتابعة وفحص الإعلان ---
  Widget _buildLastReadCard() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getLastReadData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Padding(
            padding: EdgeInsets.all(20.0),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.accentGold),
            ),
          );
        }

        final data = snapshot.data!;
        String surahName = data['surahName'];
        int surahNum = data['surahNum'];
        int ayahNum = data['ayahNum'];

        return Container(
          width: double.infinity,
          height: 160,
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: LinearGradient(
              colors: [
                AppColors.accentGold,
                AppColors.accentGold.withOpacity(0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentGold.withOpacity(0.3),
                blurRadius: 15,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Stack(
              children: [
                Positioned(
                  right: -10,
                  bottom: -5,
                  child: Image.asset(
                    'assets/quranremeber.png',
                    height: 150,
                    fit: BoxFit.contain,
                  ),
                ),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.menu_book_rounded,
                                      color: AppColors.primaryDark,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'آخر قراءة',
                                      style: TextStyle(
                                        color: AppColors.primaryDark,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Text(
                                  surahName,
                                  style: TextStyle(
                                    color: AppColors.primaryDark,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'QuranFont',
                                  ),
                                ),
                                Text(
                                  ayahNum == 0
                                      ? 'ابدأ رحلتك الآن'
                                      : 'آية رقم: $ayahNum',
                                  style: TextStyle(
                                    color: AppColors.primaryDark.withOpacity(
                                      0.8,
                                    ),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(flex: 5, child: SizedBox.expand()),
                    ],
                  ),
                ),
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(25),
                      onTap: () async {
                        List<Surah> surahs = await _surahFuture;
                        Surah selectedSurah = surahs.firstWhere(
                          (s) => s.number == surahNum,
                          orElse: () => surahs.first,
                        );

                        if (!mounted) return;

                        // 🔥 استدعاء دالة الإعلان هنا (ستعرض الإعلان مرة واحدة بالجلسة)
                        // _showAdWithCallback(() {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SurahDetailsPage(
                                surahNumber: surahNum,
                                surahName: surahName,
                                surah: selectedSurah,
                                initialAyahNumber: ayahNum,
                              ),
                            ),
                          ).then((value) => setState(() {}));
                        // });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- قائمة السور (مع إضافة إعلان ضمن المحتوى كل 6 سور) ---
  Widget _buildSurahList() {
    return FutureBuilder<List<Surah>>(
      future: _surahFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.accentGold),
          );
        }
        final surahs = snapshot.data ?? [];
        
        // حساب إجمالي العناصر مع الإعلانات الضمنية
        final int adInterval = 6; // إضافة إعلان كل 6 سور
        final int totalItems = isadactivitaed 
            ? surahs.length + (surahs.length ~/ adInterval)
            : surahs.length;

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: totalItems,
          itemBuilder: (context, index) {
            if (isadactivitaed && (index + 1) % (adInterval + 1) == 0) {
              return _InlineAdCard(adUnitId: AdHelper.bannerAdUnitId);
            }

            // حساب المؤشر الحقيقي للسورة
            int surahIndex = isadactivitaed 
                ? index - (index ~/ (adInterval + 1))
                : index;

            if (surahIndex < surahs.length) {
              return _buildSuraTile(context, surahs[surahIndex]);
            }
            return SizedBox.shrink();
          },
        );
      },
    );
  }

  // --- قائمة الأجزاء (مع إضافة إعلان ضمن المحتوى كل 5 أجزاء) ---
  Widget _buildJuzList() {
    final int adInterval = 5;
    final int totalCount = 30;
    final int totalItems = isadactivitaed 
        ? totalCount + (totalCount ~/ adInterval) 
        : totalCount;

    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: totalItems,
      itemBuilder: (context, index) {
        if (isadactivitaed && (index + 1) % (adInterval + 1) == 0) {
          return _InlineAdCard(adUnitId: AdHelper.bannerAdUnitId);
        }

        int juzIndex = isadactivitaed 
            ? index - (index ~/ (adInterval + 1)) 
            : index;

        if (juzIndex < totalCount) {
          return _buildDivisionTile(
            "الجزء ${juzIndex + 1}",
            "تصفح الجزء كاملاً",
            onTap: () {
              // _showAdWithCallback(() {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JuzDetailsPage(initialJuz: juzIndex + 1),
                  ),
                );
              // });
            },
          );
        }
        return SizedBox.shrink();
      },
    );
  }

  // --- قائمة الأحزاب (مع إضافة إعلان ضمن المحتوى كل 7 أحزاب) ---
  Widget _buildHizbList() {
    final int adInterval = 7;
    final int totalCount = 60;
    final int totalItems = isadactivitaed 
        ? totalCount + (totalCount ~/ adInterval) 
        : totalCount;

    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: totalItems,
      itemBuilder: (context, index) {
        if (isadactivitaed && (index + 1) % (adInterval + 1) == 0) {
          return _InlineAdCard(adUnitId: AdHelper.bannerAdUnitId);
        }

        int hizbIndex = isadactivitaed 
            ? index - (index ~/ (adInterval + 1)) 
            : index;

        if (hizbIndex < totalCount) {
          return _buildDivisionTile(
            "الحزب ${hizbIndex + 1}",
            "نصف الجزء ${(hizbIndex / 2 + 1).toInt()}",
            onTap: () {
              // _showAdWithCallback(() {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HizbDetailsPage(initialHizb: hizbIndex + 1),
                  ),
                );
              // });
            },
          );
        }
        return SizedBox.shrink();
      },
    );
  }

  Widget _buildDivisionTile(
    String title,
    String subtitle, {
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.secondaryDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: AppColors.textWhite.withOpacity(0.05)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryDark.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.chrome_reader_mode,
            color: AppColors.accentGold,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: AppColors.textWhite,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: AppColors.textWhite, fontSize: 12),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: AppColors.accentGold,
          size: 14,
        ),
      ),
    );
  }

  // --- توديعة السورة الفردية وفحص الإعلان ---
  Widget _buildSuraTile(BuildContext context, Surah surah) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.secondaryDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/ayah_frame.png',
              width: 38,
              height: 38,
              color: AppColors.accentGold,
              colorBlendMode: BlendMode.srcIn,
              fit: BoxFit.contain,
            ),
            Text(
              '${surah.number}',
              style: TextStyle(
                color: AppColors.textWhite,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        title: Text(
          surah.name,
          style: GoogleFonts.amiri(
            textStyle: TextStyle(
              color: AppColors.textWhite,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        subtitle: Text(
          '${surah.revelationType} • ${surah.numberOfAyahs} آيات',
          style: TextStyle(color: AppColors.textWhite, fontSize: 12),
        ),
        trailing: Text(
          surah.englishName,
          style: TextStyle(
            color: AppColors.accentGold,
            fontStyle: FontStyle.italic,
          ),
        ),
        onTap: () {
          // 🔥 دالة الإعلان البيني المحدثة (ستظهر مرة واحدة فقط في هذه الجلسة)
          // _showAdWithCallback(() {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SurahDetailsPage(
                  surahName: surah.name,
                  surahNumber: surah.number,
                  surah: surah,
                ),
              ),
            );
          // });
        },
      ),
    );
  }
}

// 🔥 كلاس مصمّم لعرض الإعلانات المضمنة داخل القوائم بطريقة متناسقة وغير مزعجة
class _InlineAdCard extends StatefulWidget {
  final String adUnitId;
  const _InlineAdCard({required this.adUnitId});

  @override
  State<_InlineAdCard> createState() => _InlineAdCardState();
}

class _InlineAdCardState extends State<_InlineAdCard> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      adUnitId: widget.adUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          debugPrint('فشل تحميل الإعلان الضمني: $err');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _bannerAd == null) {
      return SizedBox.shrink(); // إخفاء المساحة في حال عدم تحميل الإعلان
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.secondaryDark.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.accentGold.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              'إعلان تجريبي',
              style: TextStyle(
                color: AppColors.accentGold.withOpacity(0.6),
                fontSize: 10,
              ),
            ),
          ),
          SizedBox(
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          ),
        ],
      ),
    );
  }
}