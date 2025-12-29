import 'package:equatable/equatable.dart';

/// Product Model untuk produk outdoor
class Product extends Equatable {
  final String id;
  final String categoryId;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String? mainImageUrl;
  final int? rating;
  final int? reviewCount;
  final String ownerId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    this.mainImageUrl,
    this.rating,
    this.reviewCount,
    required this.ownerId,
    required this.createdAt,
    this.updatedAt,
  });

  Product copyWith({
    String? id,
    String? categoryId,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? mainImageUrl,
    int? rating,
    int? reviewCount,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      mainImageUrl: mainImageUrl ?? this.mainImageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'category_id': categoryId,
    'name': name,
    'description': description,
    'price': price,
    'stock': stock,
    'main_image_url': mainImageUrl,
    'rating': rating,
    'review_count': reviewCount,
    'user_id': ownerId, // Use user_id for consistency with fromJson
    'owner_id': ownerId, // Keep owner_id as fallback
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  factory Product.fromJson(Map<String, dynamic> json) {
    try {
      DateTime parseDateTime(dynamic value) {
        if (value == null) return DateTime.now();
        if (value is DateTime) return value;
        if (value is String) {
          try {
            return DateTime.parse(value);
          } catch (_) {
            return DateTime.now();
          }
        }
        return DateTime.now();
      }

      double parsePrice(dynamic value) {
        if (value == null) return 0.0;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) {
          try {
            return double.parse(value);
          } catch (_) {
            return 0.0;
          }
        }
        return 0.0;
      }

      int parseStock(dynamic value) {
        if (value == null) return 0;
        if (value is int) return value;
        if (value is double) return value.toInt();
        if (value is String) {
          try {
            return int.parse(value);
          } catch (_) {
            return 0;
          }
        }
        return 0;
      }

      String parseOwnerId(dynamic value1, dynamic value2) {
        // Try user_id first, then owner_id
        String? userId = value1 as String?;
        String? ownerId = value2 as String?;

        if (userId != null && userId.isNotEmpty) return userId;
        if (ownerId != null && ownerId.isNotEmpty) return ownerId;
        return ''; // Default empty string if both are null or empty
      }

      return Product(
        id: (json['id'] as String?)?.isEmpty ?? true
            ? ''
            : json['id'] as String,
        categoryId: (json['category_id'] as String?)?.isEmpty ?? true
            ? 'unknown'
            : json['category_id'] as String,
        name: (json['name'] as String?)?.isEmpty ?? true
            ? 'Unknown Product'
            : json['name'] as String,
        description: (json['description'] as String?) ?? '',
        price: parsePrice(json['price']),
        stock: parseStock(json['stock']),
        mainImageUrl: (json['main_image_url'] as String?)?.isEmpty ?? true
            ? null
            : json['main_image_url'] as String,
        rating: json['rating'] as int?,
        reviewCount: json['review_count'] as int?,
        ownerId: parseOwnerId(json['user_id'], json['owner_id']),
        createdAt: parseDateTime(json['created_at']),
        updatedAt: json['updated_at'] != null
            ? parseDateTime(json['updated_at'])
            : null,
      );
    } catch (e) {
      // Return default product if parsing fails
      return Product(
        id: '',
        categoryId: 'unknown',
        name: 'Unknown Product',
        description: '',
        price: 0.0,
        stock: 0,
        ownerId: '',
        createdAt: DateTime.now(),
      );
    }
  }

  @override
  List<Object?> get props => [
    id,
    categoryId,
    name,
    description,
    price,
    stock,
    mainImageUrl,
    rating,
    reviewCount,
    ownerId,
    createdAt,
    updatedAt,
  ];
}
