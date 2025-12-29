import 'package:dartz/dartz.dart';
import '../models/models.dart';

/// Abstract repository untuk Cart operations
abstract class CartRepository {
  // Local cart management - tidak perlu database untuk basic operations
  Future<Either<Exception, void>> addItemToCart(CartItem item);

  Future<Either<Exception, void>> removeItemFromCart(String itemId);

  Future<Either<Exception, void>> updateItemQuantity({
    required String itemId,
    required int quantity,
  });

  Future<Either<Exception, void>> clearCart();

  Future<Either<Exception, List<CartItem>>> getCartItems();

  double calculateSubtotal(List<CartItem> items);

  CartItem createCartItem({
    required String cartId,
    required String productId,
    required String productName,
    required double productPrice,
    String? productImage,
    int quantity = 1,
  });
}

/// Concrete implementation of CartRepository
class CartRepositoryImpl implements CartRepository {
  // In-memory storage untuk cart items
  final List<CartItem> _cartItems = [];

  @override
  Future<Either<Exception, void>> addItemToCart(CartItem item) async {
    try {
      // Check if item already exists
      final existingIndex = _cartItems.indexWhere(
        (i) => i.productId == item.productId,
      );

      if (existingIndex != -1) {
        // Update quantity jika product sudah ada
        final existing = _cartItems[existingIndex];
        _cartItems[existingIndex] = existing.copyWith(
          quantity: existing.quantity + item.quantity,
        );
      } else {
        // Add new item
        _cartItems.add(item);
      }

      return const Right(null);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, void>> removeItemFromCart(String itemId) async {
    try {
      _cartItems.removeWhere((item) => item.id == itemId);
      return const Right(null);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, void>> updateItemQuantity({
    required String itemId,
    required int quantity,
  }) async {
    try {
      if (quantity <= 0) {
        return Left(Exception('Quantity harus lebih dari 0'));
      }

      final index = _cartItems.indexWhere((item) => item.id == itemId);
      if (index == -1) {
        return Left(Exception('Item tidak ditemukan di cart'));
      }

      _cartItems[index] = _cartItems[index].copyWith(quantity: quantity);
      return const Right(null);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, void>> clearCart() async {
    try {
      _cartItems.clear();
      return const Right(null);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, List<CartItem>>> getCartItems() async {
    try {
      return Right(List.from(_cartItems));
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  double calculateSubtotal(List<CartItem> items) {
    return items.fold<double>(0, (sum, item) => sum + item.totalPrice);
  }

  @override
  CartItem createCartItem({
    required String cartId,
    required String productId,
    required String productName,
    required double productPrice,
    String? productImage,
    int quantity = 1,
  }) {
    return CartItem(
      id: 'cart_item_${DateTime.now().millisecondsSinceEpoch}',
      cartId: cartId,
      productId: productId,
      productName: productName,
      productPrice: productPrice,
      productImage: productImage,
      quantity: quantity,
      createdAt: DateTime.now(),
    );
  }
}
