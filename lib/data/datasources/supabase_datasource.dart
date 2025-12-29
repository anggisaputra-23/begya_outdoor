import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' hide Category;
import '../models/models.dart';
import '../../core/services/supabase_service.dart';

/// Supabase Datasource untuk handle semua operasi database
class SupabaseDataSource {
  final SupabaseService supabaseService;

  SupabaseDataSource(this.supabaseService);

  // ========== AUTH OPERATIONS ==========

  /// Sign up dengan email dan password
  Future<User> signUp({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    try {
      // Sign up ke Supabase Auth
      final response = await supabaseService.auth.signUp(
        email: email,
        password: password,
      );

      final userId = response.user?.id;
      if (userId == null) {
        throw Exception('Failed to create user account');
      }

      // Simpan user data ke database
      final userData = {
        'id': userId,
        'email': email,
        'name': name,
        'role': role,
        'created_at': DateTime.now().toIso8601String(),
      };

      await supabaseService.client.from('users').insert(userData);

      return User.fromJson({...userData, 'updated_at': null});
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  /// Sign in dengan email dan password
  Future<User> signIn({required String email, required String password}) async {
    try {
      final response = await supabaseService.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final userId = response.user?.id;
      if (userId == null) {
        throw Exception('Sign in failed');
      }

      // Ambil user data dari database
      final userData = await supabaseService.client
          .from('users')
          .select()
          .eq('id', userId)
          .single();

      return User.fromJson(userData);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  /// Get current user
  Future<User?> getCurrentUser() async {
    try {
      final currentUser = supabaseService.currentUser;
      if (currentUser == null) return null;

      final userData = await supabaseService.client
          .from('users')
          .select()
          .eq('id', currentUser.id)
          .single();

      return User.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await supabaseService.signOut();
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // ========== PRODUCT OPERATIONS ==========

  /// Get all products
  Future<List<Product>> getProducts({
    int limit = 20,
    int offset = 0,
    String? categoryId,
    String? searchQuery,
  }) async {
    try {
      var query = supabaseService.client.from('products').select();

      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
          'name.ilike.%$searchQuery%,description.ilike.%$searchQuery%',
        );
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return (response as List).map((p) => Product.fromJson(p)).toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  /// Get product by ID
  Future<Product> getProductById(String productId) async {
    try {
      final response = await supabaseService.client
          .from('products')
          .select()
          .eq('id', productId)
          .single();

      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch product: $e');
    }
  }

  /// Get products by owner
  Future<List<Product>> getProductsByOwner(String ownerId) async {
    try {
      final response = await supabaseService.client
          .from('products')
          .select()
          .eq('user_id', ownerId)
          .order('created_at', ascending: false);

      if (response is! List) {
        return [];
      }

      return response
          .map((p) {
            try {
              return Product.fromJson(p as Map<String, dynamic>);
            } catch (e) {
              debugPrint('Error parsing product: $e');
              return null;
            }
          })
          .whereType<Product>()
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch owner products: $e');
    }
  }

  /// Create product with image bytes upload (Owner only) - supports web & mobile
  Future<Product> createProductWithImageBytes({
    required String categoryId,
    required String name,
    required String description,
    required double price,
    required int stock,
    required Uint8List imageBytes,
  }) async {
    try {
      final userId = supabaseService.currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      debugPrint('📸 Starting image upload for user: $userId');
      debugPrint('📸 Image size: ${imageBytes.length} bytes');

      // Upload image to Supabase Storage bucket
      String? imageUrl;
      final fileName =
          'product_images/${DateTime.now().millisecondsSinceEpoch}.jpg';

      try {
        debugPrint('📸 Uploading to bucket: products, file: $fileName');
        await supabaseService.client.storage
            .from('products')
            .uploadBinary(fileName, imageBytes);

        debugPrint('✅ Upload successful, generating public URL...');
        // Get public URL for the image
        imageUrl = supabaseService.client.storage
            .from('products')
            .getPublicUrl(fileName);
        debugPrint('✅ Image URL generated: $imageUrl');
      } catch (storageError) {
        debugPrint('❌ Storage upload failed: $storageError');
        debugPrint('❌ Error type: ${storageError.runtimeType}');
        // Fallback: create product without image URL if upload fails
        imageUrl = null;
      }

      final now = DateTime.now();
      final productData = {
        'category_id': categoryId,
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'user_id': userId,
        'created_at': now.toIso8601String(),
        if (imageUrl != null) 'main_image_url': imageUrl,
      };

      final response = await supabaseService.client
          .from('products')
          .insert(productData)
          .select()
          .single();

      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  /// Create product with image upload (Owner only)
  Future<Product> createProductWithImage({
    required String categoryId,
    required String name,
    required String description,
    required double price,
    required int stock,
    required File imageFile,
  }) async {
    try {
      final userId = supabaseService.currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Upload image to Supabase Storage bucket
      String? imageUrl;
      final fileName =
          'product_images/${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';

      try {
        final imageBytes = await imageFile.readAsBytes();
        debugPrint('📸 Starting image upload for user: $userId');
        debugPrint('📸 Image size: ${imageBytes.length} bytes');
        debugPrint('📸 Uploading to bucket: products, file: $fileName');

        await supabaseService.client.storage
            .from('products')
            .uploadBinary(fileName, imageBytes);

        debugPrint('✅ Upload successful, generating public URL...');
        // Get public URL for the image
        imageUrl = supabaseService.client.storage
            .from('products')
            .getPublicUrl(fileName);
        debugPrint('✅ Image URL generated: $imageUrl');
      } catch (storageError) {
        debugPrint('❌ Storage upload failed: $storageError');
        debugPrint('❌ Error type: ${storageError.runtimeType}');
        // Fallback: create product without image URL if upload fails
        imageUrl = null;
      }

      final now = DateTime.now();
      final productData = {
        'category_id': categoryId,
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'user_id': userId,
        'created_at': now.toIso8601String(),
        if (imageUrl != null) 'main_image_url': imageUrl,
      };

      final response = await supabaseService.client
          .from('products')
          .insert(productData)
          .select()
          .single();

      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  /// Create product (Owner only)
  Future<Product> createProduct({
    required String categoryId,
    required String name,
    required String description,
    required double price,
    required int stock,
    String? mainImageUrl,
  }) async {
    try {
      final userId = supabaseService.currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final now = DateTime.now();
      final productData = {
        'category_id': categoryId,
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'user_id': userId,
        'created_at': now.toIso8601String(),
      };

      final response = await supabaseService.client
          .from('products')
          .insert(productData)
          .select()
          .single();

      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  /// Update product (Owner only)
  Future<Product> updateProduct({
    required String productId,
    String? categoryId,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? mainImageUrl,
  }) async {
    try {
      final userId = supabaseService.currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Verify ownership
      final existingProduct = await getProductById(productId);
      if (existingProduct.ownerId != userId) {
        throw Exception('Unauthorized: You can only edit your own products');
      }

      final updateData = <String, dynamic>{};

      if (categoryId != null) updateData['category_id'] = categoryId;
      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;
      if (price != null) updateData['price'] = price;
      if (stock != null) updateData['stock'] = stock;
      if (mainImageUrl != null) updateData['main_image_url'] = mainImageUrl;

      final response = await supabaseService.client
          .from('products')
          .update(updateData)
          .eq('id', productId)
          .select()
          .single();

      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  /// Update product with image bytes (Owner only)
  Future<Product> updateProductWithImageBytes({
    required String productId,
    required String name,
    required String description,
    required double price,
    required int stock,
    required String categoryId,
    required Uint8List imageBytes,
  }) async {
    try {
      final userId = supabaseService.currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Verify ownership
      final existingProduct = await getProductById(productId);
      if (existingProduct.ownerId != userId) {
        throw Exception('Unauthorized: You can only edit your own products');
      }

      // Upload new image to Supabase Storage bucket
      String? imageUrl;
      final fileName =
          'product_images/${DateTime.now().millisecondsSinceEpoch}.jpg';

      try {
        debugPrint(
          '📸 Starting image upload for product update, user: $userId',
        );
        debugPrint('📸 Image size: ${imageBytes.length} bytes');
        debugPrint('📸 Uploading to bucket: products, file: $fileName');

        await supabaseService.client.storage
            .from('products')
            .uploadBinary(fileName, imageBytes);

        debugPrint('✅ Upload successful, generating public URL...');
        // Get public URL for the image
        imageUrl = supabaseService.client.storage
            .from('products')
            .getPublicUrl(fileName);
        debugPrint('✅ Image URL generated: $imageUrl');
      } catch (storageError) {
        debugPrint('❌ Storage upload failed: $storageError');
        debugPrint('❌ Error type: ${storageError.runtimeType}');
        // Fallback: update product without changing image if upload fails
        imageUrl = null;
      }

      // Update product with new image URL if available
      final updateData = {
        'category_id': categoryId,
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        if (imageUrl != null) 'main_image_url': imageUrl,
      };

      final response = await supabaseService.client
          .from('products')
          .update(updateData)
          .eq('id', productId)
          .select()
          .single();

      return Product.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update product with image: $e');
    }
  }

  /// Delete product (Owner only)
  Future<void> deleteProduct(String productId) async {
    try {
      final userId = supabaseService.currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Verify ownership
      final existingProduct = await getProductById(productId);
      if (existingProduct.ownerId != userId) {
        throw Exception('Unauthorized: You can only delete your own products');
      }

      await supabaseService.client
          .from('products')
          .delete()
          .eq('id', productId);
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // ========== CATEGORY OPERATIONS ==========

  /// Get all categories
  Future<List<Category>> getCategories() async {
    try {
      final response = await supabaseService.client
          .from('categories')
          .select()
          .order('name', ascending: true);

      if (response is! List) {
        return [];
      }

      return response
          .map((c) {
            try {
              return Category.fromJson(c as Map<String, dynamic>);
            } catch (e) {
              debugPrint('Error parsing category: $e');
              return null;
            }
          })
          .whereType<Category>()
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  // ========== ORDER OPERATIONS ==========

  /// Create order
  Future<Order> createOrder({
    required List<CartItem> items,
    required double subtotal,
    required double shippingCost,
    required String customerName,
    required String customerPhone,
    required String customerAddress,
  }) async {
    try {
      final userId = supabaseService.currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final total = subtotal + shippingCost;
      final now = DateTime.now();

      // Create order dengan status 'dikirim' langsung
      final orderData = {
        'user_id': userId,
        'total_price': total,
        'status': 'dikirim',
        'customer_name': customerName,
        'customer_phone': customerPhone,
        'customer_address': customerAddress,
        'subtotal': subtotal,
        'shipping_cost': shippingCost,
        'proof_payment': null,
        'created_at': now.toIso8601String(),
      };

      final orderResponse = await supabaseService.client
          .from('orders')
          .insert(orderData)
          .select()
          .single();

      // Create order items in order_items table
      for (final item in items) {
        await supabaseService.client.from('order_items').insert({
          'order_id': orderResponse['id'],
          'product_id': item.productId,
          'quantity': item.quantity,
          'price': item.productPrice,
        });
      }

      return Order.fromJson(orderResponse);
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  /// Get order by ID with items
  Future<Order> getOrderById(String orderId) async {
    try {
      final response = await supabaseService.client
          .from('orders')
          .select()
          .eq('id', orderId)
          .single();

      return Order.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch order: $e');
    }
  }

  /// Get order items for an order
  Future<List<Map<String, dynamic>>> getOrderItems(String orderId) async {
    try {
      final response = await supabaseService.client
          .from('order_items')
          .select('''
            id,
            order_id,
            product_id,
            quantity,
            price,
            products(id, name, main_image_url)
          ''')
          .eq('order_id', orderId);

      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      throw Exception('Failed to fetch order items: $e');
    }
  }

  /// Get customer orders
  Future<List<Order>> getCustomerOrders(String customerId) async {
    try {
      final response = await supabaseService.client
          .from('orders')
          .select()
          .eq('user_id', customerId)
          .order('created_at', ascending: false);

      return (response as List).map((o) => Order.fromJson(o)).toList();
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  /// Get all orders (Owner view)
  Future<List<Order>> getAllOrders() async {
    try {
      final response = await supabaseService.client
          .from('orders')
          .select()
          .order('created_at', ascending: false);

      return (response as List).map((o) => Order.fromJson(o)).toList();
    } catch (e) {
      throw Exception('Failed to fetch all orders: $e');
    }
  }

  /// Update order status (Owner only)
  Future<Order> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      final userId = supabaseService.currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Debug logging
      print(
        'DEBUG: Updating order $orderId to status=$status for user=$userId',
      );

      final response = await supabaseService.client
          .from('orders')
          .update({'status': status})
          .eq('id', orderId)
          .eq('user_id', userId)
          .select();

      print('DEBUG: Update response: $response, isEmpty: ${response.isEmpty}');

      if (response.isEmpty) {
        throw Exception(
          'Order not found or RLS policy blocked update - may not be your order',
        );
      }

      return Order.fromJson(response.first);
    } catch (e) {
      print('DEBUG: Update error: $e');
      throw Exception('Failed to update order: $e');
    }
  }

  /// Upload payment proof
  Future<String> uploadPaymentProof({
    required String orderId,
    required String filePath,
  }) async {
    try {
      // Upload ke Supabase Storage
      final fileName =
          'payment_proofs/${DateTime.now().millisecondsSinceEpoch}.png';

      // Implementation akan di-handle di repository layer

      return fileName;
    } catch (e) {
      throw Exception('Failed to upload payment proof: $e');
    }
  }
}
