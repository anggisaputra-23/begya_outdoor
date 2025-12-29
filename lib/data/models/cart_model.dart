import 'package:equatable/equatable.dart';
import 'cart_item_model.dart';

/// Cart Model untuk keranjang belanja
class Cart extends Equatable {
  final String id;
  final String userId;
  final List<CartItem> items;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Cart({
    required this.id,
    required this.userId,
    required this.items,
    required this.createdAt,
    this.updatedAt,
  });

  // Total items dalam cart
  int get itemCount => items.fold<int>(0, (sum, item) => sum + item.quantity);

  // Total harga semua items
  double get totalPrice =>
      items.fold<double>(0, (sum, item) => sum + item.totalPrice);

  Cart copyWith({
    String? id,
    String? userId,
    List<CartItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Cart(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'items': items.map((item) => item.toJson()).toList(),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  factory Cart.fromJson(Map<String, dynamic> json) => Cart(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    items:
        (json['items'] as List<dynamic>?)
            ?.map((item) => CartItem.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [],
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: json['updated_at'] != null
        ? DateTime.parse(json['updated_at'] as String)
        : null,
  );

  @override
  List<Object?> get props => [id, userId, items, createdAt, updatedAt];
}
