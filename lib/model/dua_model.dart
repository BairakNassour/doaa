class DuaCategory {
  final int id;
  final String name;
  final String type;
  final bool isActive; // 👈 حقل حالة التفعيل
  final List<DuaItem> items;

  DuaCategory({
    required this.id,
    required this.name,
    required this.type,
    this.isActive = true,
    required this.items,
  });

  factory DuaCategory.fromJson(Map<String, dynamic> json, {bool? isActive}) {
    return DuaCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      // استخدام قيمة التفعيل الممررة من الـ Controller أو قراءتها مباشرةً
      isActive: isActive ?? (json['is_active'] == true || json['is_active'] == 1 || json['is_active'] == null),
      items: (json['items'] as List? ?? [])
          .map((item) => DuaItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'is_active': isActive,
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

class DuaItem {
  final int id;
  final String subTitle;
  final String content;
  final int count;

  DuaItem({
    required this.id,
    required this.subTitle,
    required this.content,
    required this.count,
  });

  factory DuaItem.fromJson(Map<String, dynamic> json) {
    return DuaItem(
      id: json['id'] ?? 0,
      subTitle: json['sub_title'] ?? '',
      content: json['content'] ?? '',
      count: json['count'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sub_title': subTitle,
      'content': content,
      'count': count,
    };
  }
}