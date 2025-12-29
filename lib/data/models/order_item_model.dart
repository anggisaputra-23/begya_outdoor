import 'package:equatable/equatable.dart';

/// OrderItem Model untuk item dalam pesanan
/// Schema Supabase: id, order_id, product_id, quantity, price
class OrderItem extends Equatable {
  final String id;
  final String orderId;
  final String productId;
  final int quantity;
  final double price;

  const OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.price,
  });

  OrderItem copyWith({
    String? id,
    String? orderId,
    String? productId,
    int? quantity,
    double? price,
  }) {
    return OrderItem(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'order_id': orderId,
    'product_id': productId,
    'quantity': quantity,
    'price': price,
  };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    id: json['id'] as String,
    orderId: json['order_id'] as String,
    productId: json['product_id'] as String,
    quantity: json['quantity'] as int,
    price: (json['price'] as num).toDouble(),
  );

  @override
  List<Object?> get props => [id, orderId, productId, quantity, price];
}
