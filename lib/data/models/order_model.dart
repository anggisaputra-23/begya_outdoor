import 'package:equatable/equatable.dart';

/// Order Model untuk pesanan pelanggan
class Order extends Equatable {
  final String id;
  final String userId;
  final double totalPrice;
  final String status; // menunggu, dibayar, dikirim, selesai
  final String? proofPayment;
  final DateTime createdAt;
  final String? customerName;
  final String? customerPhone;
  final String? customerAddress;
  final double? subtotal;
  final double? shippingCost;

  const Order({
    required this.id,
    required this.userId,
    required this.totalPrice,
    required this.status,
    this.proofPayment,
    required this.createdAt,
    this.customerName,
    this.customerPhone,
    this.customerAddress,
    this.subtotal,
    this.shippingCost,
  });

  Order copyWith({
    String? id,
    String? userId,
    double? totalPrice,
    String? status,
    String? proofPayment,
    DateTime? createdAt,
    String? customerName,
    String? customerPhone,
    String? customerAddress,
    double? subtotal,
    double? shippingCost,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      proofPayment: proofPayment ?? this.proofPayment,
      createdAt: createdAt ?? this.createdAt,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAddress: customerAddress ?? this.customerAddress,
      subtotal: subtotal ?? this.subtotal,
      shippingCost: shippingCost ?? this.shippingCost,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'total_price': totalPrice,
    'status': status,
    'proof_payment': proofPayment,
    'created_at': createdAt.toIso8601String(),
    'customer_name': customerName,
    'customer_phone': customerPhone,
    'customer_address': customerAddress,
    'subtotal': subtotal,
    'shipping_cost': shippingCost,
  };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    totalPrice: (json['total_price'] as num).toDouble(),
    status: json['status'] as String,
    proofPayment: json['proof_payment'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
    customerName: json['customer_name'] as String?,
    customerPhone: json['customer_phone'] as String?,
    customerAddress: json['customer_address'] as String?,
    subtotal: json['subtotal'] != null
        ? (json['subtotal'] as num).toDouble()
        : null,
    shippingCost: json['shipping_cost'] != null
        ? (json['shipping_cost'] as num).toDouble()
        : null,
  );

  @override
  List<Object?> get props => [
    id,
    userId,
    totalPrice,
    status,
    proofPayment,
    createdAt,
    customerName,
    customerPhone,
    customerAddress,
    subtotal,
    shippingCost,
  ];
}
