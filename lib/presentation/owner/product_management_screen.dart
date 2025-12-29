import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/widgets.dart';
import '../../core/utils/extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/product_notifier.dart';
import 'add_product_screen.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      try {
        final authNotifier = context.read<AuthNotifier>();
        final userId = authNotifier.currentUser?.id;
        debugPrint(
          '[ProductManagement] userId: $userId, authenticated: ${authNotifier.isAuthenticated}',
        );
        if (authNotifier.isAuthenticated &&
            userId != null &&
            userId.isNotEmpty) {
          context.read<ProductNotifier>().getProductsByOwner(userId);
        } else {
          debugPrint(
            '[ProductManagement] Skipped loading: userId null or empty',
          );
        }
      } catch (e) {
        debugPrint('[ProductManagement] Error loading products: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Produk'),
        centerTitle: true,
        elevation: 1,
      ),
      body: Consumer<ProductNotifier>(
        builder: (context, productNotifier, _) {
          if (productNotifier.isLoading) {
            return const LoadingWidget(message: 'Memuat produk...');
          }

          if (productNotifier.allProducts.isEmpty) {
            return EmptyWidget(
              icon: Icons.inventory_2_outlined,
              title: 'Belum Ada Produk',
              description: 'Buat produk pertama Anda',
              actionLabel: 'Tambah Produk',
              onAction: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddProductScreen()),
                );
              },
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: productNotifier.allProducts.length,
            itemBuilder: (context, index) {
              final product = productNotifier.allProducts[index];
              return _buildProductCard(context, productNotifier, product);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    ProductNotifier productNotifier,
    dynamic product,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
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
                        cacheHeight: 80,
                        cacheWidth: 80,
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
            const SizedBox(width: 12),
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTextStyles.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (product.price as num).toCurrency(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: product.stock > 0
                              ? AppColors.successColor.withOpacity(0.1)
                              : AppColors.errorColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Stok: ${product.stock}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: product.stock > 0
                                ? AppColors.successColor
                                : AppColors.errorColor,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (product.rating != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_half_rounded,
                              size: 12,
                              color: AppColors.warningColor,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${product.rating}',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
            // Action Buttons
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    // Edit product
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddProductScreen(product: product),
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.edit_outlined,
                    color: AppColors.primaryGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Hapus Produk?'),
                        content: const Text(
                          'Apakah Anda yakin ingin menghapus produk ini?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              final success = await productNotifier
                                  .deleteProduct(product.id);
                              if (success && mounted) {
                                context.showSuccessSnackBar(
                                  'Produk berhasil dihapus',
                                );
                              } else if (mounted) {
                                context.showErrorSnackBar(
                                  'Gagal menghapus produk',
                                );
                              }
                            },
                            child: const Text(
                              'Hapus',
                              style: TextStyle(color: AppColors.errorColor),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Icon(
                    Icons.delete_outline,
                    color: AppColors.errorColor,
                    size: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
