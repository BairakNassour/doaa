import 'package:doaa/component/ad.dart';
import 'package:doaa/component/adsKeys.dart';
import 'package:flutter/material.dart';
import 'package:doaa/component/app_colors.dart';
import 'package:doaa/controller/dua_controller.dart';
import 'package:doaa/model/dua_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class OmraFlipPage extends StatefulWidget {
  final String type; // 'omra' | 'madina' | 'hajj'

  const OmraFlipPage({
    super.key,
    required this.type,
  });

  @override
  State<OmraFlipPage> createState() => _DuaFlipPageState();
}

class _DuaFlipPageState extends State<OmraFlipPage> {
  final DuaController _controller = DuaController();
  List<DuaCategory> _duaData = [];
  bool _isLoading = true;

  DuaCategory? _selectedCategory;
  DuaItem? _selectedItem;

  // إعلان البانر
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false;
 
  // إعلان شاشة كاملة (Interstitial Ad)
  InterstitialAd? _interstitialAd;
 

 @override
  void initState() {
    super.initState();
    _initializeData();
    
    // تحميل الإعلانات فقط في حال كانت مفعلة
    if (isadactivitaed) {
      _loadBannerAd();
      _loadInterstitialAd();
    }
  }

  void _loadBannerAd() {
    if (_bannerAd != null) return;
    _bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() => _isBannerAdLoaded = true);
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('Failed to load banner ad: ${err.message}');
          ad.dispose();
          _bannerAd = null;
        },
      ),
    )..load();
  }

  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Failed to load interstitial ad: ${error.message}');
          _interstitialAd = null;
        },
      ),
    );
  }

  void _showInterstitialAd(VoidCallback onComplete) {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadInterstitialAd();
          onComplete();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _loadInterstitialAd();
          onComplete();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      onComplete();
    }
  }

  void _nextDuaOrFinish() {
    if (_selectedCategory == null || _selectedItem == null) return;

    final items = _selectedCategory!.items;
    final currentIndex = items.indexOf(_selectedItem!);

    if (currentIndex != -1 && currentIndex + 1 < items.length) {
      setState(() {
        _selectedItem = items[currentIndex + 1];
      });
    } else {
      _showInterstitialAd(() {
        if (!mounted) return;

        final currentCategoryIndex = _duaData.indexOf(_selectedCategory!);

        if (currentCategoryIndex != -1 && currentCategoryIndex + 1 < _duaData.length) {
          final nextCategory = _duaData[currentCategoryIndex + 1];
          setState(() {
            _selectedCategory = nextCategory;
            if (nextCategory.items.isNotEmpty) {
              _selectedItem = nextCategory.items.first;
            } else {
              _selectedItem = null;
            }
          });
        } else {
          setState(() {
            _selectedItem = null;
            _selectedCategory = null;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    // 👈 تمرير النوع المحدد ديناميكياً
    final allData = await _controller.fetchAllData(widget.type);
    setState(() {
      _duaData = allData;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.secondaryDark,
        appBar: AppBar(
          title: Text(
            _getAppBarTitle(),
            style: TextStyle(color: AppColors.accentGold, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppColors.accentGold),
            onPressed: _handleBack,
          ),
        ),
        bottomNavigationBar: (_selectedItem != null && _isBannerAdLoaded && _bannerAd != null)
            ? SafeArea(
                child: Container(
                  color: AppColors.secondaryDark,
                  width: double.infinity,
                  height: _bannerAd!.size.height.toDouble(),
                  child: Center(child: AdWidget(ad: _bannerAd!)),
                ),
              )
            : null,
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: AppColors.accentGold))
            : Directionality(
                textDirection: TextDirection.rtl,
                child: _buildBody(),
              ),
      ),
    );
  }

  String _getAppBarTitle() {
    if (_selectedItem != null) return _selectedItem!.subTitle;
    if (_selectedCategory != null) return _selectedCategory!.name;
    
    // عنوان الصفحة حسب النوع
    switch (widget.type) {
      case 'hajj':
        return 'خطوات الحج';
      case 'madina':
        return 'أدعية المدينة المنورة';
      case 'omra':
      default:
        return 'خطوات العمرة';
    }
  }

  void _handleBack() {
    setState(() {
      if (_selectedItem != null) {
        if (_selectedCategory != null && _selectedCategory!.items.length == 1) {
          _selectedItem = null;
          _selectedCategory = null;
        } else {
          _selectedItem = null;
        }
      } else if (_selectedCategory != null) {
        _selectedCategory = null;
      } else {
        Navigator.pop(context);
      }
    });
  }

  Widget _buildBody() {
    if (_selectedItem != null) {
      return _buildDuaDisplayPage(_selectedItem!);
    }
    if (_selectedCategory != null) {
      return _buildSubItemsList(_selectedCategory!);
    }
    return _buildMainCategoryGrid();
  }

  Widget _buildMainCategoryGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _duaData.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final cat = _duaData[index];
        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategory = cat;
              if (cat.items.length == 1) {
                _selectedItem = cat.items.first;
              } else {
                _selectedItem = null;
              }
            });
          },
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
                  style: TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            title: Text(item.subTitle, style: TextStyle(color: AppColors.textWhite)),
            trailing: Icon(Icons.arrow_forward_ios, color: AppColors.accentGold, size: 16),
            onTap: () => setState(() => _selectedItem = item),
          ),
        );
      },
    );
  }

  Widget _buildDuaDisplayPage(DuaItem item) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.secondaryDark,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: AppColors.accentGold.withOpacity(0.2)),
            ),
            child: Text(
              item.content,
              textAlign: TextAlign.center,
              style: GoogleFonts.amiri(color: AppColors.textWhite, fontSize: 22, height: 1.8),
            ),
          ),
          const SizedBox(height: 40),
          DuaVerticalCounterItem(
            item: item,
            onFinished: _nextDuaOrFinish,
          ),
        ],
      ),
    );
  }
}

class DuaVerticalCounterItem extends StatefulWidget {
  final DuaItem item;
  final VoidCallback onFinished;

  const DuaVerticalCounterItem({
    super.key,
    required this.item,
    required this.onFinished,
  });

  @override
  State<DuaVerticalCounterItem> createState() => _DuaVerticalCounterItemState();
}

class _DuaVerticalCounterItemState extends State<DuaVerticalCounterItem> {
  late int _remCount;

  @override
  void initState() {
    super.initState();
    _remCount = widget.item.count;
  }

  @override
  void didUpdateWidget(covariant DuaVerticalCounterItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.content != widget.item.content) {
      _remCount = widget.item.count;
    }
  }

  void _handleTap() {
    if (_remCount > 1) {
      setState(() => _remCount--);
    } else if (_remCount == 1) {
      setState(() => _remCount--);
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          widget.onFinished();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double progress = widget.item.count > 0 ? _remCount / widget.item.count : 0;
    bool isFinished = _remCount == 0;

    return Column(
      children: [
        if (widget.item.subTitle.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              "[ ${widget.item.subTitle} ]",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.accentGold, fontSize: 12),
            ),
          ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _handleTap,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: CircularProgressIndicator(
                  value: 1 - progress,
                  strokeWidth: 5,
                  backgroundColor: AppColors.textWhite,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isFinished ? Colors.greenAccent : AppColors.accentGold,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFinished ? Colors.green.withOpacity(0.2) : AppColors.accentGold,
                  boxShadow: [
                    if (!isFinished)
                      BoxShadow(color: AppColors.accentGold.withOpacity(0.2), blurRadius: 10)
                  ],
                ),
                child: Center(
                  child: Text(
                    "$_remCount",
                    style: TextStyle(
                      color: isFinished ? Colors.greenAccent : AppColors.primaryDark,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}