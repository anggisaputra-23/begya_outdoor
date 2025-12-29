import 'package:dartz/dartz.dart';
import 'dart:io';
import 'dart:typed_data';
import '../datasources/supabase_datasource.dart';
import '../models/models.dart';

/// Concrete implementation of ProductRepository
class ProductRepositoryImpl implements ProductRepository {
  final SupabaseDataSource dataSource;

  ProductRepositoryImpl(this.dataSource);

  @override
  Future<Either<Exception, List<Product>>> getProducts({
    int limit = 20,
    int offset = 0,
    String? categoryId,
    String? searchQuery,
  }) async {
    try {
      final products = await dataSource.getProducts(
        limit: limit,
        offset: offset,
        categoryId: categoryId,
        searchQuery: searchQuery,
      );
      return Right(products);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, Product>> getProductById(String productId) async {
    try {
      final product = await dataSource.getProductById(productId);
      return Right(product);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, List<Product>>> getProductsByOwner(
    String ownerId,
  ) async {
    try {
      final products = await dataSource.getProductsByOwner(ownerId);
      return Right(products);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, Product>> createProductWithImageBytes({
    required String categoryId,
    required String name,
    required String description,
    required double price,
    required int stock,
    required Uint8List imageBytes,
  }) async {
    try {
      final product = await dataSource.createProductWithImageBytes(
        categoryId: categoryId,
        name: name,
        description: description,
        price: price,
        stock: stock,
        imageBytes: imageBytes,
      );
      return Right(product);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, Product>> createProductWithImage({
    required String categoryId,
    required String name,
    required String description,
    required double price,
    required int stock,
    required File imageFile,
  }) async {
    try {
      final product = await dataSource.createProductWithImage(
        categoryId: categoryId,
        name: name,
        description: description,
        price: price,
        stock: stock,
        imageFile: imageFile,
      );
      return Right(product);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, Product>> createProduct({
    required String categoryId,
    required String name,
    required String description,
    required double price,
    required int stock,
    String? mainImageUrl,
  }) async {
    try {
      final product = await dataSource.createProduct(
        categoryId: categoryId,
        name: name,
        description: description,
        price: price,
        stock: stock,
        mainImageUrl: mainImageUrl,
      );
      return Right(product);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, Product>> updateProduct({
    required String productId,
    String? categoryId,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? mainImageUrl,
  }) async {
    try {
      final product = await dataSource.updateProduct(
        productId: productId,
        categoryId: categoryId,
        name: name,
        description: description,
        price: price,
        stock: stock,
        mainImageUrl: mainImageUrl,
      );
      return Right(product);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, Product>> updateProductWithImageBytes({
    required String productId,
    required String name,
    required String description,
    required double price,
    required int stock,
    required String categoryId,
    required Uint8List imageBytes,
  }) async {
    try {
      final product = await dataSource.updateProductWithImageBytes(
        productId: productId,
        name: name,
        description: description,
        price: price,
        stock: stock,
        categoryId: categoryId,
        imageBytes: imageBytes,
      );
      return Right(product);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, void>> deleteProduct(String productId) async {
    try {
      await dataSource.deleteProduct(productId);
      return const Right(null);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }

  @override
  Future<Either<Exception, List<Category>>> getCategories() async {
    try {
      final categories = await dataSource.getCategories();
      return Right(categories);
    } catch (e) {
      return Left(Exception(e.toString()));
    }
  }
}

/// Abstract repository untuk Product operations
abstract class ProductRepository {
  Future<Either<Exception, List<Product>>> getProducts({
    int limit,
    int offset,
    String? categoryId,
    String? searchQuery,
  });

  Future<Either<Exception, Product>> getProductById(String productId);

  Future<Either<Exception, List<Product>>> getProductsByOwner(String ownerId);

  Future<Either<Exception, Product>> createProductWithImageBytes({
    required String categoryId,
    required String name,
    required String description,
    required double price,
    required int stock,
    required Uint8List imageBytes,
  });

  Future<Either<Exception, Product>> createProductWithImage({
    required String categoryId,
    required String name,
    required String description,
    required double price,
    required int stock,
    required File imageFile,
  });

  Future<Either<Exception, Product>> createProduct({
    required String categoryId,
    required String name,
    required String description,
    required double price,
    required int stock,
    String? mainImageUrl,
  });

  Future<Either<Exception, Product>> updateProduct({
    required String productId,
    String? categoryId,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? mainImageUrl,
  });

  Future<Either<Exception, Product>> updateProductWithImageBytes({
    required String productId,
    required String name,
    required String description,
    required double price,
    required int stock,
    required String categoryId,
    required Uint8List imageBytes,
  });

  Future<Either<Exception, void>> deleteProduct(String productId);

  Future<Either<Exception, List<Category>>> getCategories();
}
