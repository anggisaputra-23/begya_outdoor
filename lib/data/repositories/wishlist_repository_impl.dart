import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import 'wishlist_repository.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  static const String _wishlistKey = 'wishlist_items';

  final SharedPreferences _prefs;

  WishlistRepositoryImpl(this._prefs);

  @override
  Future<Either<Exception, List<Product>>> getWishlistItems() async {
    try {
      final String? jsonString = _prefs.getString(_wishlistKey);

      if (jsonString == null || jsonString.isEmpty) {
        return Right(<Product>[]);
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      final products = jsonList
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();

      return Right(products);
    } catch (e) {
      return Left(Exception('Error loading wishlist: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> addToWishlist(Product product) async {
    try {
      final result = await getWishlistItems();

      final products = result.fold((error) => <Product>[], (items) => items);

      // Check if already exists
      if (products.any((p) => p.id == product.id)) {
        return const Right(null);
      }

      products.add(product);

      final jsonList = products.map((p) => p.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      await _prefs.setString(_wishlistKey, jsonString);

      return const Right(null);
    } catch (e) {
      return Left(Exception('Error adding to wishlist: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> removeFromWishlist(String productId) async {
    try {
      final result = await getWishlistItems();

      final products = result.fold((error) => <Product>[], (items) => items);

      products.removeWhere((p) => p.id == productId);

      final jsonList = products.map((p) => p.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      await _prefs.setString(_wishlistKey, jsonString);

      return const Right(null);
    } catch (e) {
      return Left(Exception('Error removing from wishlist: $e'));
    }
  }

  @override
  Future<Either<Exception, void>> clearWishlist() async {
    try {
      await _prefs.remove(_wishlistKey);
      return const Right(null);
    } catch (e) {
      return Left(Exception('Error clearing wishlist: $e'));
    }
  }
}
