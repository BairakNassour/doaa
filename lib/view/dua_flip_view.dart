import 'dart:async';
import 'dart:io';
import 'package:doaa/component/adsKeys.dart';
import 'package:doaa/model/dua_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:doaa/component/app_colors.dart';
import 'package:doaa/controller/dua_controller.dart';
import 'package:doaa/controller/ProgressController.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:doaa/component/ad.dart';

class DuaFlipView extends StatefulWidget {
  final String type; // omra, morning, evening, hadith, general, hajj, madina
  final String title;
  final String? categoryName;

  const DuaFlipView({
    super.key,
    required this.type,
    required this.title,
    required this.categoryName,
  });

  @override
  State<DuaFlipView> createState() => _DuaFlipViewState();
}

class _DuaFlipViewState extends State<DuaFlipView> {
  final DuaController _controller = DuaController();
  final ProgressController _remoteProgress = ProgressController();
  late PageController _pageController;
  int _initialPage = 0;
  bool _isLoadingSavedPos = true;
  bool _showCompletionView = false;

  final int _adInterval = 4;
  late Future<List<DuaCategory>> _categoriesFuture;

  DuaCategory? _selectedCategory;
  DuaItem? _selectedItem;
  List<DuaCategory> _stepsData = [];
  bool _isLoadingSteps = true;

  InterstitialAd? _interstitialAd;
  bool _isAdLoaded = false;



  bool get _isStepBasedSystem {
    return widget.title == "عمرة" ||
        widget.title == "حج" ||
        widget.title == "دعاء المدينة";
  }

  @override
  void initState() {
    super.initState();
    print("wwwww");
    print(widget.type);
    _categoriesFuture = _controller.fetchAllData(widget.type);

    if (_isStepBasedSystem) {
      _initializeStepsData();
    } else {
      _loadSavedPosition();
    }

  
    if (isadactivitaed) {
    _loadInterstitialAd();
    _loadBottomBannerAd(); // <-- أضف هذا السطر
  }
  }
  BannerAd? _bottomBannerAd;
bool _isBottomAdLoaded = false;

void _loadBottomBannerAd() {
  _bottomBannerAd = BannerAd(
    adUnitId: AdHelper.bannerAdUnitId,
    size: AdSize.banner,
    request: const AdRequest(),
    listener: BannerAdListener(
      onAdLoaded: (ad) {
        setState(() {
          _isBottomAdLoaded = true;
        });
      },
      onAdFailedToLoad: (ad, error) {
        ad.dispose();
      },
    ),
  )..load();
}

  Future<void> _initializeStepsData() async {
    final allData = await _categoriesFuture;
    setState(() {
      _stepsData = allData;
      _isLoadingSteps = false;
      _isLoadingSavedPos = false;
    });
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          setState(() {
            _interstitialAd = ad;
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('فشل تحميل الإعلان البيني: $error');
          _isAdLoaded = false;
        },
      ),
    );
  }

  void _showAdWithCallback(VoidCallback onAdClosed) {
    if (isadactivitaed && _isAdLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadInterstitialAd();
          onAdClosed();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _loadInterstitialAd();
          onAdClosed();
        },
      );
      _interstitialAd!.show();
    } else {
      onAdClosed();
    }
  }

  Future<void> _loadSavedPosition() async {
    final prefs = await SharedPreferences.getInstance();
    int savedContentPos = prefs.getInt('last_pos_${widget.type}') ?? 0;

    final categories = await _categoriesFuture;
    List<DuaItem> allItems = [];
    for (var cat in categories) {
      if (widget.categoryName == null ||
          cat.name.toString() == widget.categoryName.toString()) {
        allItems.addAll(cat.items);
      }
    }

    if (savedContentPos >= allItems.length - 1 && allItems.isNotEmpty) {
      savedContentPos = 0;
      await prefs.setInt('last_pos_${widget.type}', 0);
    }

    int initialPage = savedContentPos;
    if (isadactivitaed && allItems.length > _adInterval) {
      initialPage = savedContentPos + (savedContentPos ~/ _adInterval);
    }

    _initialPage = initialPage;
    _pageController = PageController(initialPage: _initialPage);
    setState(() {
      _isLoadingSavedPos = false;
    });
  }

  void _saveProgress(int index, int total) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_pos_${widget.type}', index);

    bool isFinishedAll = (index == total - 1);

    _remoteProgress.updateRemoteProgress('azkar', {
      'type': widget.type,
      'last_index': index,
      'total_pages': total,
      'status': isFinishedAll ? 'completed' : 'reading',
    });
  }

  Future<void> _resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_pos_${widget.type}', 0);

    _remoteProgress.updateRemoteProgress('azkar', {
      'type': widget.type,
      'last_index': 0,
      'status': 'completed',
    });
  }

  void _goToNextPage(int currentIndex, int totalCount) {
    if (currentIndex == totalCount) {
      _resetProgress();
      _showAdWithCallback(() {
        setState(() {
          _showCompletionView = true;
        });
      });
    } else {
      if (_pageController.hasClients) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _handleBack() {
    if (_isStepBasedSystem) {
      setState(() {
        if (_selectedItem != null) {
          _selectedItem = null;
        } else if (_selectedCategory != null) {
          _selectedCategory = null;
        } else {
          Navigator.pop(context);
        }
      });
    } else {
      Navigator.pop(context);
    }
  }

  String _getAppBarTitle() {
    if (_isStepBasedSystem) {
      if (_selectedItem != null) return _selectedItem!.subTitle;
      if (_selectedCategory != null) return _selectedCategory!.name;
    }
    return widget.title;
  }

  @override
void dispose() {
  _interstitialAd?.dispose();
  _bottomBannerAd?.dispose(); // <-- أضف هذا السطر
  if (!_isStepBasedSystem) _pageController.dispose();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    if (_isLoadingSavedPos || (_isStepBasedSystem && _isLoadingSteps)) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.accentGold),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.secondaryDark,
      bottomNavigationBar: _isBottomAdLoaded && _bottomBannerAd != null
      ? SafeArea(
          child: SizedBox(
            width: _bottomBannerAd!.size.width.toDouble(),
            height: _bottomBannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bottomBannerAd!),
          ),
        )
      : const SizedBox.shrink(),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.accentGold,
          ),
          onPressed: _handleBack,
        ),
        title: Text(
          _getAppBarTitle(),
          style: TextStyle(
            color: AppColors.accentGold,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: _showCompletionView
              ? _buildCompletionWidget()
              : _buildMainBodyContent(),
        ),
      ),
    );
  }

  Widget _buildMainBodyContent() {
    if (_isStepBasedSystem) {
      if (_selectedItem != null) {
        return _buildDuaStepDisplayPage(_selectedItem!);
      }
      if (_selectedCategory != null) {
        return _buildSubItemsList(_selectedCategory!);
      }
      return _buildMainCategoryGrid();
    } else {
      return FutureBuilder<List<DuaCategory>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.accentGold),
            );
          }

          final categories = snapshot.data ?? [];
          List<DuaItem> allItems = [];

          for (var cat in categories) {
            if (widget.categoryName == null ||
                cat.name.toString() == widget.categoryName.toString()) {
              allItems.addAll(cat.items);
            }
          }

          if (allItems.isEmpty) {
            return Center(
              child: Text(
                "لا توجد بيانات لهذا التصنيف",
                style: TextStyle(color: AppColors.textWhite),
              ),
            );
          }

          int totalPagesCount = allItems.length;
          bool useInlineAds = isadactivitaed && allItems.length > _adInterval;

          if (useInlineAds) {
            totalPagesCount =
                allItems.length + (allItems.length - 1) ~/ _adInterval;
          }

          if (_initialPage >= totalPagesCount) {
            _initialPage = 0;
          }

          return PageView.builder(
            controller: _pageController,
            itemCount: totalPagesCount,
            onPageChanged: (index) {
              if (useInlineAds) {
                bool isAdPage = (index + 1) % (_adInterval + 1) == 0;
                if (!isAdPage) {
                  int actualContentIndex = index - (index ~/ (_adInterval + 1));
                  _saveProgress(actualContentIndex, allItems.length);
                }
              } else {
                _saveProgress(index, allItems.length);
              }
            },
            itemBuilder: (context, index) {
              if (useInlineAds) {
                bool isAdPage = (index + 1) % (_adInterval + 1) == 0;
                if (isAdPage) {
                  return InPageAdCard(
                    onNext: () => _goToNextPage(index + 1, totalPagesCount),
                  );
                }
              }

              int actualContentIndex = index;
              if (useInlineAds) {
                actualContentIndex = index - (index ~/ (_adInterval + 1));
              }

              return DuaIndividualCard(
                item: allItems[actualContentIndex],
                currentIndex: actualContentIndex + 1,
                totalCount: allItems.length,
                type: widget.type,
                onFinished: () => _goToNextPage(index + 1, totalPagesCount),
                title: widget.title,
                isStepBased: false,
              );
            },
          );
        },
      );
    }
  }

  Widget _buildMainCategoryGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _stepsData.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final cat = _stepsData[index];
        return GestureDetector(
          onTap: () => setState(() => _selectedCategory = cat),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.secondaryDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.accentGold.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mosque, color: AppColors.accentGold, size: 40),
                const SizedBox(height: 10),
                Text(
                  cat.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubItemsList(DuaCategory category) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: category.items.length,
      itemBuilder: (context, index) {
        final item = category.items[index];
        return Card(
          color: AppColors.secondaryDark,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            title: Text(
              item.subTitle,
              style: TextStyle(color: AppColors.textWhite),
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: AppColors.accentGold,
              size: 16,
            ),
            onTap: () => setState(() => _selectedItem = item),
          ),
        );
      },
    );
  }

  Widget _buildDuaStepDisplayPage(DuaItem item) {
    return DuaIndividualCard(
      item: item,
      currentIndex: 1,
      totalCount: 1,
      type: widget.type,
      onFinished: () {
        setState(() {
          _selectedItem = null; // العودة لقائمة الخطوات عند الانتهاء من التكرارات
        });
      },
      title: widget.title,
      isStepBased: true,
    );
  }

  Widget _buildCompletionWidget() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 30),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: AppColors.primaryDark,
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: AppColors.accentGold.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              color: Colors.greenAccent,
              size: 80,
            ),
            const SizedBox(height: 20),
            Text(
              "تم بحمد الله",
              style: TextStyle(
                color: AppColors.accentGold,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "تقبل الله طاعتك وصالح أعمالك",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textWhite, fontSize: 18),
            ),
            const SizedBox(height: 35),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.exit_to_app_rounded,
                color: AppColors.primaryDark,
              ),
              label: Text(
                "خروج",
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGold,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DuaIndividualCard extends StatefulWidget {
  final DuaItem item;
  final int currentIndex;
  final String title;
  final int totalCount;
  final String type;
  final VoidCallback onFinished;
  final bool isStepBased;

  const DuaIndividualCard({
    super.key,
    required this.item,
    required this.currentIndex,
    required this.totalCount,
    required this.type,
    required this.onFinished,
    required this.title,
    required this.isStepBased,
  });

  @override
  State<DuaIndividualCard> createState() => _DuaIndividualCardState();
}

class _DuaIndividualCardState extends State<DuaIndividualCard> {
  late int _remCount;
  final ProgressController _remoteProgress = ProgressController();

  @override
  void initState() {
    super.initState();
    // إذا كان التكرار في البيانات 0، نجعل قيمته الافتراضية 1 على الأقل ليظهر للضغط
    _remCount = widget.item.count > 0 ? widget.item.count : 1;
  }

  @override
  void didUpdateWidget(DuaIndividualCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.content != widget.item.content) {
      _remCount = widget.item.count > 0 ? widget.item.count : 1;
    }
  }

  void _handleTap() {
    if (_remCount > 0) {
      setState(() => _remCount--);

      _remoteProgress.updateRemoteProgress("tasbih", {
        "count": 1,
        "type": widget.type,
        "action": "tap",
      });

      if (_remCount == 0) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) widget.onFinished();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int maxCount = widget.item.count > 0 ? widget.item.count : 1;
    double progress = _remCount / maxCount;
    bool isFinished = _remCount == 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: AppColors.secondaryDark,
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: AppColors.accentGold.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          if (widget.item.subTitle.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Text(
                "[ ${widget.item.subTitle} ]",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.accentGold, fontSize: 22),
              ),
            ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Text(
                  widget.item.content,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isFinished
                        ? AppColors.textGrey
                        : AppColors.textWhite,
                    fontSize: 22,
                    height: 1.7,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (!widget.isStepBased)
                _buildInfo(
                  "الترتيب",
                  "${widget.currentIndex} / ${widget.totalCount}",
                ),

              // ⭐ إظهار دائم لدائرة التكرارات لكل الدعوات
              GestureDetector(
                onTap: _handleTap,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: 1 - progress,
                        strokeWidth: 8,
                        backgroundColor: AppColors.textWhite,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isFinished
                              ? Colors.greenAccent
                              : AppColors.accentGold,
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isFinished
                            ? Colors.green.withOpacity(0.2)
                            : AppColors.accentGold,
                      ),
                      child: Center(
                        child: Text(
                          "$_remCount",
                          style: TextStyle(
                            color: isFinished
                                ? AppColors.accentGold
                                : AppColors.primaryDark,
                            fontSize: 35,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (!widget.isStepBased)
                _buildInfo(
                  "التكرار",
                  "$maxCount",
                ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildInfo(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: AppColors.textWhite, fontSize: 11)),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textWhite,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class InPageAdCard extends StatefulWidget {
  final VoidCallback onNext;

  const InPageAdCard({super.key, required this.onNext});

  @override
  State<InPageAdCard> createState() => _InPageAdCardState();
}

class _InPageAdCardState extends State<InPageAdCard> {
  BannerAd? _inlineBannerAd;
  bool _isAdLoaded = false;

  @override
  @override
  void initState() {
    super.initState();
    
    // تحميل الإعلان المدمج فقط إذا كانت الإعلانات مفعلة
    if (isadactivitaed) {
      _loadInlineBannerAd();
    }
  }

  void _loadInlineBannerAd() {
    
    _inlineBannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      size: AdSize.mediumRectangle,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          debugPrint('فشل تحميل الإعلان المدمج: $error');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _inlineBannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: AppColors.secondaryDark,
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: AppColors.accentGold.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, color: AppColors.accentGold, size: 16),
              const SizedBox(width: 8),
              Text(
                "إعلان ممول",
                style: TextStyle(color: AppColors.textGrey, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Center(
              child: _isAdLoaded && _inlineBannerAd != null
                  ? SizedBox(
                      width: _inlineBannerAd!.size.width.toDouble(),
                      height: _inlineBannerAd!.size.height.toDouble(),
                      child: AdWidget(ad: _inlineBannerAd!),
                    )
                  : CircularProgressIndicator(color: AppColors.accentGold),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: widget.onNext,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: AppColors.accentGold,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "متابعة\nالقراءة",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}