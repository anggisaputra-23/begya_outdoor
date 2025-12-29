import 'package:dartz/dartz.dart' hide Order;
import '../datasources/supabase_datasource.dart';
import '../models/models.dart';

/// Abstract repository untuk Order operations
abstract class OrderRepository {
  Future<Either<Exception, Order>> createOrder({
    required List<CartItem> items,
    required double subtotal,
    required double shippingCost,
    required String customerName,
    required String customerPhone,
    required String customerAddress,
  });

  Future<Either<Exception, Order>> getOrderById(String orderId);

  Future<Either<Exception, List<Order>>> getCustomerOrders(String customerId);

  Future<Either<Exception, List<Order>>> getAllOrders();

  Future<Either<Exception, Order>> updateOrderStatus({
    required String orderId,
    required String status,
  });

  Future<Either<Exception, String>> uploadPaymentProof({
    required String orderId,
    required String filePath,
  });
}

/// Concrete implementation of OrderRepository
class OrderRepositoryImpl implements OrderRepository {
  final SupabaseDataSource dataSource;

  OrderRepositoryImpl(this.dataSource);

  @override
  Future<Either<Exception, Order>> createOrder({
    required List<CartItem> items,
    required double subtotal,
    required double shippingCost,
    required String customerName,
    required String customerPhone,
    required String customerAddress,
  }) async {
    try {
      // Validate inputs
      if (items.isEmpty) {
        return Left(Exception('Keranjang tidak boleh kosong'));
      }

      if (customerName.isEmpty ||
          customerPhone.isEmpty ||
          customerAddress.isEmpty) {
        return Left(Exception('Data customer tidak lengkap'));
      }

      final order = await dataSource.createOrder(
        items: items,
        subtotal: subtotal,
        shippingCost: shippingCost,
        customerName: customerName,
        customerPhone: customerPhone,
        customerAddress: customerAddress,
      );

      return Right(order);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, Order>> getOrderById(String orderId) async {
    try {
      final order = await dataSource.getOrderById(orderId);
      return Right(order);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, List<Order>>> getCustomerOrders(
    String customerId,
  ) async {
    try {
      final orders = await dataSource.getCustomerOrders(customerId);
      return Right(orders);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, List<Order>>> getAllOrders() async {
    try {
      final orders = await dataSource.getAllOrders();
      return Right(orders);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, Order>> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      final validStatuses = ['menunggu', 'dibayar', 'dikirim', 'selesai'];
      if (!validStatuses.contains(status)) {
        return Left(Exception('Status tidak valid'));
      }

      final order = await dataSource.updateOrderStatus(
        orderId: orderId,
        status: status,
      );

      return Right(order);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, String>> uploadPaymentProof({
    required String orderId,
    required String filePath,
  }) async {
    try {
      final url = await dataSource.uploadPaymentProof(
        orderId: orderId,
        filePath: filePath,
      );

      return Right(url);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }
}
