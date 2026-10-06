class HisnResponse {
  final String categoryType;
  final bool isActive;
  final List<HisnCategory> data;

  HisnResponse({
    required this.categoryType,
    required this.isActive,
    required this.data,
  });

  factory HisnResponse.fromJson(Map<String, dynamic> json) {
    return HisnResponse(
      categoryType: json['category_type'] ?? '',
      isActive: json['is_active'] ?? false,
      data: (json['data'] as List? ?? [])
          .map((item) => HisnCategory.fromJson(item))
          .toList(),
    );
  }
}

class HisnCategory {
  final int id;
  final String name;
  final int categoryTypeId;
  final List<HisnItem> items;

  HisnCategory({
    required this.id,
    required this.name,
    required this.categoryTypeId,
    required this.items,
  });

  factory HisnCategory.fromJson(Map<String, dynamic> json) {
    return HisnCategory(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      categoryTypeId: json['category_type_id'] ?? 0,
      items: (json['items'] as List? ?? [])
          .map((item) => HisnItem.fromJson(item))
          .toList(),
    );
  }
}

class HisnItem {
  final int id;
  final int categoryId;
  final String subTitle;
  final String content;
  final int count;

  HisnItem({
    required this.id,
    required this.categoryId,
    required this.subTitle,
    required this.content,
    required this.count,
  });

  factory HisnItem.fromJson(Map<String, dynamic> json) {
    return HisnItem(
      id: json['id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      subTitle: json['sub_title'] ?? '',
      content: json['content'] ?? '',
      count: json['count'] ?? 1,
    );
  }
}