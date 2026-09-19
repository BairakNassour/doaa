import 'dart:convert';
import 'package:doaa/model/allah_name_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// استيراد ملف الرابط العام
import 'package:doaa/component/general_url.dart'; 

class AllahNamesController {
  // الرابط الجديد يشير إلى السيرفر الخاص بك
  final String apiUrl = "$general_url/allah-names";
  final String storageKey = "cached_allah_names";

  Future<List<AllahName>> fetchNames() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      // 1. محاولة جلب البيانات من السيرفر الخاص بك
      final response = await http.get(Uri.parse(apiUrl)).timeout(
        const Duration(seconds: 10),
      );
      print(response.body);

      if (response.statusCode == 200) {
        // تخزين البيانات محلياً للعمل بدون إنترنت لاحقاً
        await prefs.setString(storageKey, response.body);
        return _parseNames(response.body);
      } else {
        return _loadFromLocal(prefs);
      }
    } catch (e) {
      print("Network error, loading local data: $e");
      return _loadFromLocal(prefs);
    }
  }

  // تعديل التحليل ليتناسب مع الهيكلية الجديدة (success, data, message)
  List<AllahName> _parseNames(String jsonString) {
    Map<String, dynamic> body = jsonDecode(jsonString);
    
    // لارافيل يرسل البيانات داخل حقل 'data' كما صممنا في الـ Controller
    List<dynamic> data = body['data']; 
    
    return data.map((dynamic item) => AllahName.fromJson(item)).toList();
  }

  List<AllahName> _loadFromLocal(SharedPreferences prefs) {
    final String? cachedData = prefs.getString(storageKey);
    if (cachedData != null) {
      return _parseNames(cachedData);
    } else {
      throw Exception("لا توجد بيانات مخزنة، يرجى الاتصال بالإنترنت أول مرة.");
    }
  }
}