import 'dart:convert';

class UserProgressModel {
  final String category;
  final Map<String, dynamic> details;
  final int stars;
  final DateTime? createdAt;
  final String displayCount; // حقل جديد لتسهيل عرض عدد التسبيحات مباشرة

  UserProgressModel({
    required this.category,
    required this.details,
    this.stars = 0,
    this.createdAt,
    this.displayCount = "0",
  });

  factory UserProgressModel.fromJson(Map<String, dynamic> json) {
    // 1. معالجة التفاصيل (Details)
    Map<String, dynamic> parsedDetails = {};
    if (json['details'] != null) {
      if (json['details'] is Map) {
        parsedDetails = Map<String, dynamic>.from(json['details']);
      } else if (json['details'] is String) {
        try {
          parsedDetails = jsonDecode(json['details']);
        } catch (_) {}
      }
    }

    // 2. استخراج عدد التسبيحات من داخل التفاصيل ذكاءً
    // نبحث عن counter أولاً (كما يرسله السيرفر) ثم المسميات الأخرى
    String count = "0";
    if (parsedDetails.containsKey('counter')) {
      count = parsedDetails['counter'].toString();
    } else if (parsedDetails.containsKey('total_count')) {
      count = parsedDetails['total_count'].toString();
    } else if (parsedDetails.containsKey('count')) {
      count = parsedDetails['count'].toString();
    }

    // 3. معالجة التاريخ
    DateTime? date;
    if (json['created_at'] != null) {
      date = DateTime.tryParse(json['created_at'].toString());
    } else if (parsedDetails.containsKey('timestamp')) {
      date = DateTime.tryParse(parsedDetails['timestamp'].toString());
    }

    return UserProgressModel(
      category: json['category']?.toString() ?? '',
      stars: int.tryParse(json['stars']?.toString() ?? '0') ?? 0,
      details: parsedDetails,
      createdAt: date,
      displayCount: count, // الآن العدد جاهز للاستخدام مباشرة
    );
  }
}