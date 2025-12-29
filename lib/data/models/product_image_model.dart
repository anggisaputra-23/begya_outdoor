import 'package:equatable/equatable.dart';

/// Product Image Model untuk menyimpan multiple images per product
class ProductImage extends Equatable {
  final String id;
  final String productId;
  final String imageUrl;
  final int order;
  final DateTime createdAt;

  const ProductImage({
    required this.id,
    required this.productId,
    required this.imageUrl,
    required this.order,
    required this.createdAt,
  });

  ProductImage copyWith({
    String? id,
    String? productId,
    String? imageUrl,
    int? order,
    DateTime? createdAt,
  }) {
    return ProductImage(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      imageUrl: imageUrl ?? this.imageUrl,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'product_id': productId,
    'image_url': imageUrl,
    'order': order,
    'created_at': createdAt.toIso8601String(),
  };

  factory ProductImage.fromJson(Map<String, dynamic> json) => ProductImage(
    id: json['id'] as String,
    productId: json['product_id'] as String,
    imageUrl: json['image_url'] as String,
    order: json['order'] as int,
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  @override
  List<Object?> get props => [id, productId, imageUrl, order, createdAt];
}
