import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/extensions.dart';
import '../../core/widgets/widgets.dart';
import '../../data/models/models.dart';
import '../../providers/cart_notifier.dart';
import '../../providers/wishlist_notifier.dart';
import '../../providers/product_notifier.dart';

/// Product Detail Screen dengan Hero Animation
class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  bool _isWishlisted = false;
  Product? _product;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    try {
      final productNotifier = context.read<ProductNotifier>();

      // Get all products and find the one matching the ID
      final allProducts = productNotifier.products;

      if (allProducts.isEmpty) {
        // If no products loaded, fetch them first
        await productNotifier.getProducts();
      }

      // Find product by ID
      final product = productNotifier.products.firstWhere(
        (p) => p.id == widget.productId,
        orElse: () => Product(
          id: widget.productId,
          categoryId: 'unknown',
          name: 'Produk Tidak Ditemukan',
          description: 'Produk yang Anda cari tidak tersedia lagi',
          price: 0.0,
          stock: 0,
          ownerId: '',
          createdAt: DateTime.now(),
        ),
      );

      if (mounted) {
        setState(() {
          _product = product;
          _isLoading = false;
        });

        // Load wishlist status after product is loaded
        await _loadWishlistStatus();
      }
    } catch (e) {
      debugPrint('Error loading product: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _product = Product(
            id: widget.productId,
            categoryId: 'unknown',
            name: 'Error Loading Product',
            description: 'Terjadi kesalahan saat memuat produk',
            price: 0.0,
            stock: 0,
            ownerId: '',
            createdAt: DateTime.now(),
          );
        });
      }
    }
  }

  Future<void> _loadWishlistStatus() async {
    if (_product == null) return;

    if (!mounted) return;

    final wishlistNotifier = context.read<WishlistNotifier>();
    await wishlistNotifier.loadWishlist();

    if (mounted) {
      setState(() {
        _isWishlisted = wishlistNotifier.isInWishlist(_product!.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryGreen,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => GoRouter.of(context).pop(),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_product == null ||
        _product!.stock == 0 &&
            _product!.id == widget.productId &&
            _product!.name == 'Produk Tidak Ditemukan') {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryGreen,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => GoRouter.of(context).pop(),
          ),
        ),
        body: Center(
          child: EmptyWidget(
            icon: Icons.search_off,
            title: 'Produk Tidak Ditemukan',
            description: 'Produk yang Anda cari tidak tersedia',
            actionLabel: 'Kembali',
            onAction: () => GoRouter.of(context).pop(),
          ),
        ),
      );
    }

    final product = _product!;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              context.showSuccessSnackBar('Share feature coming soon');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Gallery
            _buildImageGallery(product),

            // Product Info
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(product.name, style: AppTextStyles.heading3),

                  const SizedBox(height: 8),

                  // Category
                  Chip(
                    label: Text(product.categoryId.toUpperCase()),
                    backgroundColor: AppColors.primaryGreen.withOpacity(0.2),
                    labelStyle: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryGreen,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Price & Stock
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Harga', style: AppTextStyles.bodySmall),
                            const SizedBox(height: 4),
                            Text(
                              (product.price as num).toCurrency(),
                              style: AppTextStyles.heading3.copyWith(
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Stok Tersedia',
                              style: AppTextStyles.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${product.stock} unit',
                              style: AppTextStyles.heading4.copyWith(
                                color: product.stock > 0
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Description
                  Text('Deskripsi Produk', style: AppTextStyles.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    product.description.isEmpty
                        ? 'Tidak ada deskripsi'
                        : product.description,
                    style: AppTextStyles.bodyMedium,
                  ),

                  const SizedBox(height: 24),

                  // Quantity Selector
                  if (product.stock > 0) ...[
                    Text('Jumlah', style: AppTextStyles.titleLarge),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderDefault),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: _quantity > 1
                                ? () {
                                    setState(() => _quantity--);
                                  }
                                : null,
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                _quantity.toString(),
                                style: AppTextStyles.titleLarge,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _quantity < product.stock
                                ? () {
                                    setState(() => _quantity++);
                                  }
                                : null,
                            tooltip: _quantity >= product.stock
                                ? 'Stok terbatas (${product.stock} tersedia)'
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.warning_outlined, color: AppColors.error),
                          const SizedBox(width: 8),
                          Text(
                            'Produk tidak tersedia',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Owner Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: AppColors.primaryGreen,
                          child: Text(
                            product.ownerId.substring(0, 1).toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Penjual', style: AppTextStyles.bodySmall),
                              const SizedBox(height: 4),
                              Text(
                                product.ownerId,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: product.stock > 0
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Consumer<WishlistNotifier>(
                      builder: (context, wishlistNotifier, _) {
                        return GestureDetector(
                          onTap: () async {
                            final success = await wishlistNotifier
                                .toggleWishlist(product);

                            if (!mounted) return;

                            if (success) {
                              setState(() {
                                _isWishlisted = wishlistNotifier.isInWishlist(
                                  product.id,
                                );
                              });

                              context.showSuccessSnackBar(
                                _isWishlisted
                                    ? '❤️ Ditambahkan ke Wishlist'
                                    : '💔 Dihapus dari Wishlist',
                              );
                            } else {
                              context.showErrorSnackBar(
                                'Gagal mengupdate wishlist',
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.primaryGreen),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isWishlisted
                                      ? Icons.favorite
                                      : Icons.favorite_outline,
                                  color: _isWishlisted
                                      ? Colors.red
                                      : AppColors.primaryGreen,
                                  size: 24,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Wishlist',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: _isWishlisted
                                        ? Colors.red
                                        : AppColors.primaryGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Consumer<CartNotifier>(
                      builder: (context, cartNotifier, _) {
                        return PrimaryButton(
                          label: 'Keranjang 🛒',
                          onPressed: () {
                            // Validate stock before adding to cart
                            if (_quantity > product.stock) {
                              context.showErrorSnackBar(
                                'Stok terbatas! Hanya tersedia ${product.stock} item',
                              );
                              return;
                            }

                            cartNotifier
                                .addToCart(
                                  productId: product.id,
                                  productName: product.name,
                                  productPrice: product.price,
                                  productImage: product.mainImageUrl ?? '',
                                  quantity: _quantity,
                                )
                                .then((success) {
                                  if (success && mounted) {
                                    context.showSuccessSnackBar(
                                      '$_quantity x ${product.name} ditambahkan ke keranjang',
                                    );
                                    setState(() => _quantity = 1);
                                  } else if (mounted) {
                                    context.showErrorSnackBar(
                                      cartNotifier.error ??
                                          'Gagal menambahkan ke keranjang',
                                    );
                                  }
                                });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildImageGallery(Product product) {
    return Column(
      children: [
        // Main Image dengan Optimized Loading
        Hero(
          tag: 'product_${widget.productId}',
          child: Container(
            height: 300,
            width: double.infinity,
            color: AppColors.grey100,
            // 🖼️ OPTIMIZED IMAGE LOADING dengan caching & shimmer
            child:
                product.mainImageUrl != null && product.mainImageUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: product.mainImageUrl!,
                    fit: BoxFit.cover,
                    // ⏳ SHIMMER LOADING PLACEHOLDER
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: AppColors.grey200,
                      highlightColor: AppColors.grey100,
                      child: Container(
                        color: AppColors.grey100,
                      ),
                    ),
                    // ❌ ERROR HANDLER dengan informasi
                    errorWidget: (context, url, error) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported_outlined,
                              color: AppColors.grey400,
                              size: 48,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Gambar tidak tersedia',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      );
                    },
                    // ⚡ OPTIMASI: Caching dengan memory cache
                    memCacheHeight: 300,
                    memCacheWidth: 400,
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          color: AppColors.grey400,
                          size: 48,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Belum ada gambar',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
