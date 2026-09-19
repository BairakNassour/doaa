import 'dart:io';

class AdHelper {
  // معرف المانفيست للأندرويد (يوضع في AndroidManifest.xml):
  // ca-app-pub-4003122238711862~9500370366

  // معرف المينفيست للايفون (يوضع في Info.plist تحت مفتاح GADApplicationIdentifier):
  // ca-app-pub-4003122238711862~9500370366

  // إعلان البانر (Banner Ad)
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4003122238711862/4935688908';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-4003122238711862/4935688908';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // الإعلان البيني كامل الشاشة (Interstitial Ad)
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4003122238711862/5533725759';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-4003122238711862/5533725759';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // إعلان فتح التطبيق (App Open Ad)
  static String get appOpenAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4003122238711862/5562374864';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-4003122238711862/5562374864';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // إعلان ضمن المحتوى (Inline / Native Ad)
  static String get nativeOrInlineAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-4003122238711862/8159889090';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-4003122238711862/8159889090';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}