import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:doaa/component/app_colors.dart';
import 'package:doaa/controller/quran_controller.dart';
import 'package:doaa/model/ayah_model.dart';

class SurahKahfPage extends StatefulWidget {
  const SurahKahfPage({super.key});

  @override
  State<SurahKahfPage> createState() => _SurahKahfPageState();
}

class _SurahKahfPageState extends State<SurahKahfPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  List<Ayah> _ayahs = [];
  List<String> _audioUrls = [];
  
  bool _isLoading = true;
  bool _isPlaying = false;
  int _currentIndex = 0;
  
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _fetchKahfData();
    _initAudioListeners();
  }

  // جلب نص الآيات والملفات الصوتية
  Future<void> _fetchKahfData() async {
    try {
      QuranController quranController = QuranController();
      List<Ayah> fetchedAyahs = await quranController.fetchSurahAyahs(18);

      final audioResponse = await http.get(
        Uri.parse("https://api.alquran.cloud/v1/surah/18/ar.alafasy"),
      );

      List<String> urls = [];
      if (audioResponse.statusCode == 200) {
        var data = json.decode(audioResponse.body);
        List ayahsAudio = data['data']['ayahs'];
        urls = ayahsAudio.map<String>((a) => a['audio'].toString()).toList();
      }

      setState(() {
        _ayahs = fetchedAyahs;
        _audioUrls = urls;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تعذر تحميل السورة، تحقق من الاتصال بالإنترنت.")),
      );
    }
  }

  // إعداد مستمعات المشغل الصوتي
  void _initAudioListeners() {
    _audioPlayer.onDurationChanged.listen((newDuration) {
      setState(() => _duration = newDuration);
    });

    _audioPlayer.onPositionChanged.listen((newPosition) {
      setState(() => _position = newPosition);
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (_currentIndex < _audioUrls.length - 1) {
        _playAudioAtIndex(_currentIndex + 1);
      } else {
        setState(() {
          _isPlaying = false;
          _currentIndex = 0;
          _position = Duration.zero;
        });
      }
    });
  }

  // تشغيل آية محددة
  Future<void> _playAudioAtIndex(int index) async {
    if (_audioUrls.isEmpty || index >= _audioUrls.length) return;
    
    setState(() {
      _currentIndex = index;
      _isPlaying = true;
    });

    await _audioPlayer.stop();
    await _audioPlayer.play(UrlSource(_audioUrls[index]));
  }

  // إيقاف أو تشغيل مؤقت
  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() => _isPlaying = false);
    } else {
      if (_audioUrls.isNotEmpty) {
        await _audioPlayer.play(UrlSource(_audioUrls[_currentIndex]));
        setState(() => _isPlaying = true);
      }
    }
  }

  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        backgroundColor: AppColors.secondaryDark,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "سورة الكهف",
          style: TextStyle(
            color: AppColors.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.textWhite),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFC0A080)),
            )
          : Column(
              children: [
                // 1. عرض الآيات القابلة للتمرير
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    itemCount: _ayahs.length,
                    itemBuilder: (context, index) {
                      final isCurrentAyah = index == _currentIndex && _isPlaying;
                      return GestureDetector(
                        onTap: () => _playAudioAtIndex(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isCurrentAyah
                                ? const Color(0xFFC0A080).withOpacity(0.15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: isCurrentAyah
                                ? Border.all(color: const Color(0xFFC0A080), width: 1)
                                : null,
                          ),
                          child: Text(
                            "${_ayahs[index].text} ﴿${_ayahs[index].numberInSurah}﴾",
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: isCurrentAyah
                                  ? const Color(0xFFC0A080)
                                  : AppColors.textWhite,
                              fontSize: 19,
                              height: 1.9,
                              fontFamily: 'Amiri',
                              fontWeight: isCurrentAyah
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // 2. شريط مشغل الصوت السفلي
                _buildAudioPlayerControl(),
              ],
            ),
    );
  }

  // أداة لوحة التحكم بالصوت
  Widget _buildAudioPlayerControl() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.secondaryDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // معلومات التشغيل الحالية
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "القارئ: مشاري العفاسي",
                  style: TextStyle(
                    color: AppColors.textWhite.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
                Text(
                  _ayahs.isNotEmpty ? "آية: ${_currentIndex + 1} من ${_ayahs.length}" : "",
                  style: const TextStyle(
                    color: Color(0xFFC0A080),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // شريط تقدم الصوت
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                activeTrackColor: const Color(0xFFC0A080),
                inactiveTrackColor: AppColors.primaryDark,
                thumbColor: const Color(0xFFC0A080),
              ),
              child: Slider(
                min: 0,
                max: _duration.inSeconds.toDouble() > 0
                    ? _duration.inSeconds.toDouble()
                    : 1.0,
                value: _position.inSeconds.toDouble().clamp(
                      0.0,
                      _duration.inSeconds.toDouble() > 0
                          ? _duration.inSeconds.toDouble()
                          : 1.0,
                    ),
                onChanged: (value) async {
                  final position = Duration(seconds: value.toInt());
                  await _audioPlayer.seek(position);
                },
              ),
            ),

            // أزرار التحكم (السابق - التشغيل/الإيقاف - التالي)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous_rounded, color: Color(0xFFC0A080), size: 32),
                  onPressed: _currentIndex > 0
                      ? () => _playAudioAtIndex(_currentIndex - 1)
                      : null,
                ),
                const SizedBox(width: 15),
                IconButton(
                  iconSize: 50,
                  icon: Icon(
                    _isPlaying
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_fill_rounded,
                    color: const Color(0xFFC0A080),
                  ),
                  onPressed: _togglePlayPause,
                ),
                const SizedBox(width: 15),
                IconButton(
                  icon: const Icon(Icons.skip_next_rounded, color: Color(0xFFC0A080), size: 32),
                  onPressed: _currentIndex < _audioUrls.length - 1
                      ? () => _playAudioAtIndex(_currentIndex + 1)
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