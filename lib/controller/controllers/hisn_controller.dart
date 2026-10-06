import 'package:doaa/controller/dua_controller.dart';
import 'package:get/get.dart';
import 'package:doaa/controller/quran_controller.dart'; // المتحكم الخاص بك لجلب البيانات
import 'package:doaa/model/hisn_model.dart';

class HisnController extends GetxController {
  final DuaController _duaController = DuaController();

  var isLoading = true.obs;
  var categories = <HisnCategory>[].obs;
  var filteredCategories = <HisnCategory>[].obs;
  var favorites = <int>[].obs; // قائمة معرفات الفئات المفضلة

  @override
  void onInit() {
    super.onInit();
    fetchHisnData();
  }

  Future<void> fetchHisnData() async {
  try {
    isLoading(true);
    
    // جلب البيانات المرجعة من الدالة
    dynamic response = await _duaController.fetchAllData("hosenmoslem");

    if (response != null) {
      // 1. إذا كانت النتيجة Map (تتضمن الجبذر كاملاً):
      if (response is Map<String, dynamic>) {
        HisnResponse hisnData = HisnResponse.fromJson(response);
        categories.assignAll(hisnData.data);
        filteredCategories.assignAll(hisnData.data);
      } 
      // 2. إذا كانت النتيجة List مباشرة (List<DuaCategory> أو List<dynamic>):
      else if (response is List) {
        // تحويل عناصر القائمة إلى HisnCategory
        List<HisnCategory> loadedCategories = response.map((item) {
          if (item is Map<String, dynamic>) {
            return HisnCategory.fromJson(item);
          } else {
            // في حال كانت الكائنات مجهزة من نوع نموذج آخر داخل Controller
            return HisnCategory.fromJson(item.toJson()); 
          }
        }).toList();

        categories.assignAll(loadedCategories);
        filteredCategories.assignAll(loadedCategories);
      }
    }
  } catch (e) {
    Get.snackbar("خطأ", "تعذر تحميل أذكار حصن المسلم: $e");
  } finally {
    isLoading(false);
  }
}

  void filterSearch(String query) {
    if (query.isEmpty) {
      filteredCategories.assignAll(categories);
    } else {
      filteredCategories.assignAll(
        categories.where((cat) => cat.name.contains(query) || 
            cat.items.any((item) => item.content.contains(query))).toList(),
      );
    }
  }

  void toggleFavorite(int categoryId) {
    if (favorites.contains(categoryId)) {
      favorites.remove(categoryId);
    } else {
      favorites.add(categoryId);
    }
  }
}