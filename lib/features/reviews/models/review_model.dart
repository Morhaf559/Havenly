class ReviewModel {
  final int id;
  final int? apartmentId;
  final String? userName;
  final String? comment;
  final int rate;
  final String? createdAt;

  ReviewModel({
    required this.id,
    this.apartmentId,
    this.userName,
    this.comment,
    required this.rate,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    int? reviewId;
    if (json['id'] != null) {
      reviewId = json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString());
    } else if (json['review_id'] != null) {
      reviewId = json['review_id'] is int
          ? json['review_id'] as int
          : int.tryParse(json['review_id'].toString());
    }

    if (reviewId == null) {
      throw Exception('ReviewModel: Unable to parse review ID from JSON');
    }
    int? aptId;
    if (json['apartment_id'] != null) {
      aptId = json['apartment_id'] is int
          ? json['apartment_id'] as int
          : int.tryParse(json['apartment_id'].toString());
    } else if (json['apartment'] != null && json['apartment'] is Map) {
      final apartment = json['apartment'] as Map<String, dynamic>;
      if (apartment['id'] != null) {
        aptId = apartment['id'] is int
            ? apartment['id'] as int
            : int.tryParse(apartment['id'].toString());
      }
    }
    String? userName;
    if (json['user_name'] != null) {
      userName = json['user_name'].toString();
    } else if (json['userName'] != null) {
      userName = json['userName'].toString();
    } else if (json['user'] != null && json['user'] is Map) {
      final user = json['user'] as Map<String, dynamic>;
      if (user['username'] != null) {
        userName = user['username'].toString();
      } else if (user['first_name'] != null) {
        userName = user['first_name'].toString();
        if (user['last_name'] != null) {
          userName = '${userName} ${user['last_name']}';
        }
      }
    }
    int? reviewRate;
    if (json['rate'] != null) {
      if (json['rate'] is int) {
        reviewRate = json['rate'] as int;
      } else if (json['rate'] is String) {
        final rateStr = json['rate'] as String;
        reviewRate = double.tryParse(rateStr)?.toInt();
      } else if (json['rate'] is num) {
        reviewRate = (json['rate'] as num).toInt();
      }
    } else if (json['apartment'] != null && json['apartment'] is Map) {
      final apartment = json['apartment'] as Map<String, dynamic>;
      if (apartment['rate'] != null) {
        if (apartment['rate'] is int) {
          reviewRate = apartment['rate'] as int;
        } else if (apartment['rate'] is String) {
          final rateStr = apartment['rate'] as String;
          reviewRate = double.tryParse(rateStr)?.toInt();
        } else if (apartment['rate'] is num) {
          reviewRate = (apartment['rate'] as num).toInt();
        }
      }
    }

    return ReviewModel(
      id: reviewId,
      apartmentId: aptId,
      userName: userName,
      comment: json['comment'] as String?,
      rate: reviewRate ?? 0,
      createdAt: json['created_at'] as String? ?? json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'apartment_id': apartmentId,
      'user_name': userName,
      'comment': comment,
      'rate': rate,
      'created_at': createdAt,
    };
  }
}
