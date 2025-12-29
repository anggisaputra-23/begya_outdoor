import 'package:dartz/dartz.dart';
import '../models/models.dart';

abstract class WishlistRepository {
  Future<Either<Exception, List<Product>>> getWishlistItems();
  Future<Either<Exception, void>> addToWishlist(Product product);
  Future<Either<Exception, void>> removeFromWishlist(String productId);
  Future<Either<Exception, void>> clearWishlist();
}
