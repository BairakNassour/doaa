import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:doaa/component/general_url.dart';
import 'package:doaa/component/adsKeys.dart';
import 'package:doaa/component/app_colors.dart';
import 'package:doaa/model/wallpaper_model.dart';

class WallpaperController extends GetxController {
  var wallpapers = <WallpaperModel>[].obs;
  var isLoading = true.obs;

  // إعلانات AdMob
  BannerAd? bannerAd;
  var isBannerAdReady = false.obs;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialReady = false;

  @override
  void onInit() {
    super.onInit();
    fetchWallpapers();
    _loadBannerAd();
    _loadInterstitialAd();
  }

  // 1. جلب قائمة الصور من لارافيل
  Future<void> fetchWallpapers() async {
    try {
      isLoading(true);
      final response = await http.get(Uri.parse('$general_url/wallpapers'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true) {
          var list = (data['data']['data'] as List)
              .map((e) => WallpaperModel.fromJson(e))
              .toList();
          wallpapers.assignAll(list);
        }
      }
    } catch (e) {
      debugPrint("Error fetching wallpapers: $e");
    } finally {
      isLoading(false);
    }
  }

  // 2. زيادة عدد التحميلات في السيرفر
  Future<void> incrementDownload(int id) async {
    try {
      await http.post(Uri.parse('$general_url/wallpapers/$id/download'));
    } catch (e) {
      debugPrint("Error incrementing download: $e");
    }
  }

  // 3. تحميل الإعلان البيني (Interstitial Ad)
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialReady = true;
        },
        onAdFailedToLoad: (err) {
          _isInterstitialReady = false;
        },
      ),
    );
  }

  // 4. إظهار الإعلان البيني ثم تنفيذ عملية التحميل
  void showInterstitialAndAction(VoidCallback action) {
    if (_isInterstitialReady && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadInterstitialAd();
          action();
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          ad.dispose();
          _loadInterstitialAd();
          action();
        },
      );
      _interstitialAd!.show();
    } else {
      action();
    }
  }

  // 5. تحميل إعلان البانر السفلي
  void _loadBannerAd() {
    bannerAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) => isBannerAdReady(true),
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          isBannerAdReady(false);
        },
      ),
    )..load();
  }

  @override
  void onClose() {
    bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.onClose();
  }
}