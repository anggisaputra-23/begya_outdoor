import 'package:equatable/equatable.dart';

/// Cart Item Model untuk item di keranjang
class CartItem extends Equatable {
  final String id;
  final String cartId;
  final String productId;
  final String productName;
  final double productPrice;
  final String? productImage;
  final int quantity;
  final DateTime createdAt;

  const CartItem({
    required this.id,
    required this.cartId,
    required this.productId,
    required this.productName,
    required this.productPrice,
    this.productImage,
    required this.quantity,
    required this.createdAt,
  });

  // Total price untuk item ini
  double get totalPrice => productPrice * quantity;

  CartItem copyWith({
    String? id,
    String? cartId,
    String? productId,
    String? productName,
    double? productPrice,
    String? productImage,
    int? quantity,
    DateTime? createdAt,
  }) {
    return CartItem(
      id: id ?? this.id,
      cartId: cartId ?? this.cartId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productPrice: productPrice ?? this.productPrice,
      productImage: productImage ?? this.productImage,
      quantity: quantity ?? this.quantity,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'cart_id': cartId,
    'product_id': productId,
    'product_name': productName,
    'product_price': productPrice,
    'product_image': productImage,
    'quantity': quantity,
    'created_at': createdAt.toIso8601String(),
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    id: json['id'] as String,
    cartId: json['cart_id'] as String,
    productId: json['product_id'] as String,
    productName: json['product_name'] as String,
    productPrice: (json['product_price'] as num).toDouble(),
    productImage: json['product_image'] as String?,
    quantity: json['quantity'] as int,
    createdAt: DateTime.parse(json['created_at'] as String),
  );

  @override
  List<Object?> get props => [
    id,
    cartId,
    productId,
    productName,
    productPrice,
    productImage,
    quantity,
    createdAt,
  ];
}
