import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppColors {
  // ==================== [ قيم الوضع الداكن - Dark Mode ] ====================
  static const Color _dPrimary = Color(0xFF0C261F);      // أخضر ليلي عميق
  static const Color _dSecondary = Color(0xFF13322A);    // أخضر زيتي غامق
  static const Color _dGold = Color(0xFF997D45);         // ذهبي مطفي فخم
  static const Color _dText = Color(0xFFE0E0E0);         // أبيض مايل للرمادي مريح للعين
  static const Color _dTextGrey = Color(0xB3E0E0E0);     // رمادي فاتح شفاف

  // ==================== [ قيم الوضع الفاتح - Light Mode ] ====================
  static const Color _lPrimary = Color(0xFFF9F7F2);      // أوف وايت/كريمي دافئ فخم جداً كخلفية أساسية
  static const Color _lSecondary = Color(0xFFF0ECE3);    // درجة كريمية أعمق قليلاً للحاويات والـ Cards
  static const Color _lGold = Color(0xFF8A6F3E);         // ذهبي عربي عميق وواضح على الخلفيات الفاتحة
  static const Color _lText = Color(0xFF0F2922);         // أخضر قرآني داكن جداً بديل للأسود الصريح (مريح وعميق)
  static const Color _lTextGrey = Color(0xFF6E7E75);     // أخضر رمادي متوسط للنصوص الثانوية والآيات غير المحددة

  // ==================== [ جلب الألوان ديناميكياً حسب الوضع ] ====================
  
  // الخلفية الأساسية للتطبيق
  static Color get primaryDark => Get.isDarkMode ? _dPrimary : _lPrimary;
  
  // خلفية الـ Cards، الـ Container، أو الـ Drawer
  static Color get secondaryDark => Get.isDarkMode ? _dSecondary : _lSecondary;
  
  // الأزرار، الأيقونات، التحديد النشط (الذهبي الفخم)
  static Color get accentGold => Get.isDarkMode ? _dGold : _lGold;
  
  // النص الأساسي (الآيات النشطة، عناوين السور)
  static Color get textWhite => Get.isDarkMode ? _dText : _lText;
  
  // النصوص الثانوية أو التوضيحية
  static Color get textGrey => Get.isDarkMode ? _dTextGrey : _lTextGrey;
}