import 'dart:io'; // 🔥 تم استيرادها لمعرفات الإعلانات
import 'package:doaa/component/adsKeys.dart';
import 'package:doaa/controller/quran_controller.dart';
import 'package:doaa/model/ayah_model.dart';
import 'package:doaa/model/surah_model.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:doaa/component/app_colors.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // 🔥 استيراد حزمة الإعلانات
import 'package:doaa/component/ad.dart'; // 🔥 استيراد ملف التحكم بالإعلانات الخاص بك

class AudioPlayerPage extends StatefulWidget {
  const AudioPlayerPage({super.key});

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final QuranController _controller = QuranController();

  List<AyahAudio> _ayahs = [];
  List<Surah> _allSurahs = [];
  int _currentSurahNumber = 1;
  String _currentSurahName = "سورة الفاتحة";
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _isLoading = true;
  bool _isRepeatMode = false; 

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  // 🔥 متغيرات الإعلانات الجديدة
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialAdLoaded = false;
  bool _hasShownInterstitialInSession = false; // التحكم بالظهور لمرة واحدة بالجلسة

  // معرفات الإعلانات التجريبية للاختبار

  // 1. قائمة القراء المحددة والمطلوبة فقط مع صورهم
  final List<Map<String, String>> _reciters = [
    {
      "identifier": "ar.alafasy",
      "name": "القارئ مشاري العفاسي",
      "image": "assets/mashari.jpg"
    },
    {
      "identifier": "ar.abdulsamad",
      "name": "الشيخ عبد الباسط عبد الصمد",
      "image": "assets/abdalbaset.webp"
    },
    {
      "identifier": "ar.minshawi",
      "name": "الشيخ محمد صديق المنشاوي",
      "image": "assets/almanshawi.webp"
    },
  ];

  late Map<String, String> _selectedReciter;

  @override
  void initState() {
    super.initState();
    _selectedReciter = _reciters[0]; 
    _initAudioContext(); 
    _setupAudioListeners();
    _loadInitialData();

    // 🔥 تحميل الإعلانات مبكراً إذا كانت مفعلة
    if (isadactivitaed) {
      _loadBannerAd();
      _loadInterstitialAd();
    }
  }

  // 🔥 دالة تحميل إعلان البانر
  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() => _isBannerAdLoaded = true);
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          debugPrint('فشل تحميل البانر: $err');
        },
      ),
    )..load();
  }

  // 🔥 دالة تحميل الإعلان البيني
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          setState(() {
            _interstitialAd = ad;
            _isInterstitialAdLoaded = true;
          });
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('فشل تحميل الإعلان البيني: $error');
          _isInterstitialAdLoaded = false;
        },
      ),
    );
  }

  // 🔥 دالة فحص وعرض الإعلان البيني لمرة واحدة فقط عند التغيير
  void _showInterstitialAdWithCallback(VoidCallback onAdClosed) {
    if (_hasShownInterstitialInSession || !isadactivitaed || !_isInterstitialAdLoaded || _interstitialAd == null) {
      onAdClosed();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _hasShownInterstitialInSession = true; // وضع علامة أنه تم العرض في هذه الجلسة
        _loadInterstitialAd(); // تحميل إعلان احتياطي
        onAdClosed();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _loadInterstitialAd();
        onAdClosed();
      },
    );
    _interstitialAd!.show();
  }

  Future<void> _initAudioContext() async {
    await _audioPlayer.setReleaseMode(ReleaseMode.stop);
    await _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);
    
    final AudioContext audioContext = AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: {
          AVAudioSessionOptions.mixWithOthers,
          AVAudioSessionOptions.duckOthers,
        },
      ),
      android: AudioContextAndroid(
        stayAwake: true, 
        audioFocus: AndroidAudioFocus.gain, 
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioMode: AndroidAudioMode.normal,
      ),
    );
    await AudioPlayer.global.setAudioContext(audioContext);
  }

  void _setupAudioListeners() {
    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });

    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (_currentIndex < _ayahs.length - 1) {
        _playNext();
      } else {
        if (_isRepeatMode) {
          setState(() => _currentIndex = 0);
          _playCurrent();
        } else {
          _playNextSurah();
        }
      }
    });
  }

  void _playNextSurah() {
    int nextSurahIndex = _allSurahs.indexWhere((s) => s.number == _currentSurahNumber) + 1;
    
    if (nextSurahIndex < _allSurahs.length) {
      setState(() {
        _currentSurahNumber = _allSurahs[nextSurahIndex].number;
        _currentSurahName = _allSurahs[nextSurahIndex].name;
      });
      _loadSurahAudio(_currentSurahNumber, autoPlay: true);
    } else {
      setState(() => _isPlaying = false);
    }
  }

  Future<void> _loadInitialData() async {
    try {
      _allSurahs = await _controller.fetchSurahList();
      await _loadSurahAudio(_currentSurahNumber, autoPlay: false);
    } catch (e) {
      debugPrint("Error loading quran list: $e");
    }
  }

  Future<void> _loadSurahAudio(int surahNum, {bool autoPlay = false}) async {
    setState(() => _isLoading = true);
    await _audioPlayer.stop();

    try {
      _ayahs = await _controller.fetchSurahAudio(surahNum);
      setState(() {
        _isLoading = false;
        _currentIndex = 0;
      });

      if (_ayahs.isNotEmpty && autoPlay) {
        _playCurrent();
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _playCurrent() async {
    if (_ayahs.isEmpty) return;
    try {
      await _audioPlayer.play(UrlSource(_ayahs[_currentIndex].audioUrl));
      if (mounted) setState(() => _isPlaying = true);
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  void _togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _playCurrent();
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  void _playNext() {
    if (_currentIndex < _ayahs.length - 1) {
      _currentIndex++;
      _playCurrent();
    }
  }

  void _playPrevious() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _playCurrent();
    }
  }

  void _showReciterSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.primaryDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "اختر القارئ",
                  style: GoogleFonts.amiri(color: AppColors.accentGold, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Divider(color: Colors.white24),
                const SizedBox(height: 10),
                ..._reciters.map((reciter) {
                  bool isSelected = reciter['identifier'] == _selectedReciter['identifier'];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(reciter['image']!),
                    ),
                    title: Text(
                      reciter['name']!,
                      style: GoogleFonts.amiri(
                        color: isSelected ? AppColors.accentGold : AppColors.textWhite,
                        fontSize: 18,
                      ),
                    ),
                    trailing: isSelected ? Icon(Icons.check_circle, color: AppColors.accentGold) : null,
                    onTap: () async {
                      Navigator.pop(context);
                      
                      // 🔥 استدعاء الإعلان البيني عند تغيير القارئ (يظهر مرة واحدة في الجلسة)
                      _showInterstitialAdWithCallback(() async {
                        setState(() {
                          _selectedReciter = reciter; 
                        });
                        await _controller.updateSelectedReciter(reciter['identifier']!);
                        _loadSurahAudio(_currentSurahNumber, autoPlay: _isPlaying);
                      });
                    },
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _bannerAd?.dispose(); // 🔥 تفريغ البانر من الذاكرة
    _interstitialAd?.dispose(); // 🔥 تفريغ البيني من الذاكرة
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.secondaryDark,
        drawer: _buildQuranDrawer(),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: AppColors.accentGold),
          title: Text(
            _currentSurahName,
            style: GoogleFonts.amiriQuran(color: AppColors.accentGold, fontSize: 22),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.record_voice_over_rounded, color: AppColors.accentGold),
              tooltip: "تغيير القارئ",
              onPressed: _showReciterSelection,
            ),
          ],
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: AppColors.accentGold))
            : Column(
                children: [
                  const SizedBox(height: 10),
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.accentGold, width: 2),
                            image: DecorationImage(
                              image: AssetImage(_selectedReciter['image']!), 
                              fit: BoxFit.cover,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accentGold.withOpacity(0.3),
                                blurRadius: 15,
                                spreadRadius: 2,
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _selectedReciter['name']!, 
                          style: GoogleFonts.amiri(
                            color: AppColors.accentGold,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
      
                  const SizedBox(height: 20),
      
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryDark.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.accentGold.withOpacity(0.5), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentGold.withOpacity(0.05),
                            blurRadius: 10,
                          )
                        ],
                      ),
                      alignment: Alignment.center,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Text(
                          _ayahs[_currentIndex].text,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.amiri(
                            color: AppColors.textWhite,
                            fontSize: 26,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ),
                  ),
      
                  _buildPlayerControls(),
                  
                  // 🔥 إضافة إعلان البانر في أسفل الصفحة تماماً وبطريقة احترافية
                  if (_isBannerAdLoaded && _bannerAd != null)
                    SafeArea(
                      top: false,
                      child: Container(
                        alignment: Alignment.center,
                        width: _bannerAd!.size.width.toDouble(),
                        height: _bannerAd!.size.height.toDouble(),
                        child: AdWidget(ad: _bannerAd!),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildPlayerControls() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 15), // تم تعديل البادينغ ليتناسب مع البانر بالأسفل
      decoration: BoxDecoration(
        color: AppColors.primaryDark.withOpacity(0.8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              activeTrackColor: AppColors.accentGold,
              inactiveTrackColor: AppColors.textWhite.withOpacity(0.2),
              thumbColor: AppColors.accentGold,
            ),
            child: Slider(
              min: 0,
              max: _duration.inMilliseconds.toDouble(),
              value: _position.inMilliseconds
                  .toDouble()
                  .clamp(0, _duration.inMilliseconds.toDouble()),
              onChanged: (value) async {
                final position = Duration(milliseconds: value.toInt());
                await _audioPlayer.seek(position);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_formatDuration(_position),
                    style: TextStyle(color: AppColors.textWhite, fontSize: 12)),
                Text(_formatDuration(_duration),
                    style: TextStyle(color: AppColors.textWhite, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                tooltip: "تكرار السورة",
                icon: Icon(
                  _isRepeatMode ? Icons.repeat_on_rounded : Icons.repeat_rounded,
                  color: _isRepeatMode ? AppColors.accentGold : AppColors.textWhite,
                ),
                onPressed: () => setState(() => _isRepeatMode = !_isRepeatMode),
              ),
    
              IconButton(
                icon: Icon(Icons.skip_previous_rounded,
                    size: 40, color: AppColors.textWhite),
                onPressed: _playPrevious,
              ),
    
              GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                      color: AppColors.accentGold, shape: BoxShape.circle),
                  child: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      size: 40, color: AppColors.primaryDark),
                ),
              ),
    
              IconButton(
                icon: Icon(Icons.skip_next_rounded,
                    size: 40, color: AppColors.textWhite),
                onPressed: _playNext,
              ),
    
              Builder(builder: (context) {
                return IconButton(
                  icon: Icon(Icons.list_rounded, color: AppColors.textWhite),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Widget _buildQuranDrawer() {
    return Drawer(
      backgroundColor: AppColors.primaryDark,
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: AppColors.secondaryDark),
            child: Center(
              child: Text(
                "فهرس السور".tr,
                style: GoogleFonts.amiriQuran(color: AppColors.accentGold, fontSize: 24),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _allSurahs.length,
              itemBuilder: (context, i) => ListTile(
                selected: _allSurahs[i].number == _currentSurahNumber,
                selectedTileColor: AppColors.accentGold.withOpacity(0.1),
                title: Text(
                  _allSurahs[i].name,
                  style: GoogleFonts.amiriQuran(
                    color: _allSurahs[i].number == _currentSurahNumber
                        ? AppColors.accentGold
                        : AppColors.textWhite,
                    fontSize: 18,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  
                  // 🔥 استدعاء الإعلان البيني عند الانتقال لسورة أخرى من القائمة (يظهر مرة واحدة في الجلسة)
                  _showInterstitialAdWithCallback(() {
                    setState(() {
                      _currentSurahNumber = _allSurahs[i].number;
                      _currentSurahName = _allSurahs[i].name;
                    });
                    _loadSurahAudio(_allSurahs[i].number, autoPlay: true);
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}