class NotificationModel {
  final int id;
  final String title;
  final String body;
  final int type;
  final Map<String, dynamic>? data;
  final DateTime? readAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.data,
    this.readAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      type: json['type'] as int,
      data: json['data'] != null
          ? Map<String, dynamic>.from(json['data'] as Map)
          : null,
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      if (data != null) 'data': data,
      if (readAt != null) 'read_at': readAt!.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Check if notification is read
  bool isRead() {
    return readAt != null;
  }

  /// Get type text in Arabic
  String getTypeText() {
    switch (type) {
      case 1:
        return 'حجز';
      case 2:
        return 'تسجيل';
      case 3:
        return 'تقييم';
      case 4:
        return 'طلب';
      default:
        return 'إشعار';
    }
  }

  int? getItemId() {
    if (data != null && data!.containsKey('item_id')) {
      return data!['item_id'] as int?;
    }
    return null;
  }

  bool hasNavigation() {
    return getItemId() != null;
  }
}
