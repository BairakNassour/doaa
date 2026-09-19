import 'dart:convert';
import 'package:doaa/component/general_url.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/dua_model.dart';

class DuaController {
  // ✅ تُرجع قائمة List<DuaCategory> مع قراءة دقيقة لحالة التفعيل
  Future<List<DuaCategory>> fetchAllData(String type) async {
    final prefs = await SharedPreferences.getInstance();
    final String apiUrl = "$general_url/data/$type";
    final String cacheKey = 'cached_dua_$type';

    try {
      final response = await http.get(Uri.parse(apiUrl)).timeout(
        const Duration(seconds: 8),
      );
      print("ssss");
      print(type);
      print(response.body);
      
      if (response.statusCode == 200) {
        
        await prefs.setString(cacheKey, response.body);
        return _parseData(response.body);
      } else {
        return _loadFromCache(prefs, cacheKey);
      }
    } catch (e) {
      print("Network error for $type: $e");
      return _loadFromCache(prefs, cacheKey);
    }
  }

  List<DuaCategory> _loadFromCache(SharedPreferences prefs, String key) {
    String? cached = prefs.getString(key);
    if (cached != null && cached.isNotEmpty) {
      try {
        return _parseData(cached);
      } catch (e) {
        print("Error parsing cached data: $e");
        return [];
      }
    }
    return [];
  }

  List<DuaCategory> _parseData(String jsonString) {
    final Map<String, dynamic> decoded = json.decode(jsonString);

    // 🔒 قراءة حالة التفعيل الرئيسية بدون فرض true تلقائياً
    bool isParentActive = true;
    if (decoded.containsKey('is_active') && decoded['is_active'] != null) {
      isParentActive = decoded['is_active'] == true || decoded['is_active'] == 1;
    }

    List<DuaCategory> categories = [];
    if (decoded.containsKey('data') && decoded['data'] != null) {
      final List decodedData = decoded['data'];

      categories = decodedData.map((json) {
        // إذا كان العنصر يحتوي على is_active خاصة به يقرأها، وإلا يأخذ حالة الفئة الرئيسية
        bool itemActive = isParentActive;
        if (json['is_active'] != null) {
          itemActive = json['is_active'] == true || json['is_active'] == 1;
        }

        return DuaCategory.fromJson(json, isActive: itemActive);
      }).toList();
    }

    return categories;
  }

  // دالة لجلب حالة تفعيل الفئة الرئيسية فقط (مثل morning / evening)
  Future<bool> checkCategoryStatus(String type) async {
    try {
      final String apiUrl = "$general_url/data/$type";
      final response = await http.get(Uri.parse(apiUrl)).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded.containsKey('is_active') && decoded['is_active'] != null) {
          return decoded['is_active'] == true || decoded['is_active'] == 1;
        }
      }
    } catch (e) {
      print("Error checking status for $type: $e");
    }
    return true; // القيمة الافتراضية
  }

  Future<List<dynamic>> fetchCategoryTypes() async {
    final String apiUrl = "$general_url/category-types";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
    } catch (e) {
      print("Error fetching types: $e");
    }
    return [];
  }
}