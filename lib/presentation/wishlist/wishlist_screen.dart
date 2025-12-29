import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/extensions.dart';
import '../../core/widgets/widgets.dart';
import '../../providers/wishlist_notifier.dart';
import '../../providers/cart_notifier.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    _loadWishlistData();
  }

  Future<void> _loadWishlistData() async {
    debugPrint('Loading wishlist items...');
    if (!mounted) return;
    try {
      await context.read<WishlistNotifier>().loadWishlist();
    } catch (e) {
      debugPrint('Error loading wishlist: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist Saya'),
        centerTitle: true,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => GoRouter.of(context).pop(),
        ),
      ),
      body: Consumer<WishlistNotifier>(
        builder: (context, wishlistNotifier, _) {
          if (wishlistNotifier.isLoading) {
            return const LoadingWidget(message: 'Memuat wishlist...');
          }

          if (wishlistNotifier.wishlists.isEmpty) {
            return EmptyWidget(
              icon: Icons.favorite_outline,
              title: 'Wishlist Kosong',
              description: 'Tambahkan produk favorit Anda',
              actionLabel: 'Belanja Sekarang',
              onAction: () => GoRouter.of(context).pop(),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: wishlistNotifier.wishlists.length,
            itemBuilder: (context, index) {
              final product = wishlistNotifier.wishlists[index];
              return _buildWishlistCard(context, product, wishlistNotifier);
            },
          );
        },
      ),
    );
  }

  Widget _buildWishlistCard(
    BuildContext context,
    dynamic product,
    WishlistNotifier wishlistNotifier,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            GestureDetector(
              onTap: () {
                GoRouter.of(context).push('/product/${product.id}');
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: AppColors.bgSecondary,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child:
                      (product.mainImageUrl != null &&
                          product.mainImageUrl!.isNotEmpty)
                      ? Image.network(
                          product.mainImageUrl!,
                          fit: BoxFit.cover,
                          cacheHeight: 100,
                          cacheWidth: 100,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.image_not_supported_outlined,
                            color: AppColors.textSecondary,
                          ),
                        )
                      : const Icon(
                          Icons.image_not_supported_outlined,
                          color: AppColors.textSecondary,
                        ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      GoRouter.of(context).push('/product/${product.id}');
                    },
                    child: Text(
                      product.name,
                      style: AppTextStyles.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (product.price as num).toCurrency(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Stok: ${product.stock}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: product.stock > 0
                          ? AppColors.primaryGreen
                          : AppColors.errorColor,
                    ),
                  ),
                ],
              ),
            ),
            // Action Buttons
            SizedBox(
              width: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final success = await wishlistNotifier.removeFromWishlist(
                        product.id,
                      );
                      if (context.mounted) {
                        if (success) {
                          context.showSuccessSnackBar('Dihapus dari Wishlist');
                        } else {
                          context.showErrorSnackBar(
                            'Gagal menghapus dari wishlist',
                          );
                        }
                      }
                    },
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final cartNotifier = context.read<CartNotifier>();
                      final success = await cartNotifier.addToCart(
                        productId: product.id,
                        productName: product.name,
                        productPrice: product.price,
                        productImage: product.mainImageUrl ?? '',
                        quantity: 1,
                      );

                      if (context.mounted) {
                        if (success) {
                          context.showSuccessSnackBar(
                            'Ditambahkan ke keranjang',
                          );
                        } else {
                          context.showErrorSnackBar(
                            'Gagal menambah ke keranjang',
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.shopping_cart, size: 16),
                    label: const Text('Cart'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      minimumSize: const Size(80, 36),
                      backgroundColor: AppColors.primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
