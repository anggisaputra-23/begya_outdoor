import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/widgets.dart';
import '../../core/utils/extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../providers/cart_notifier.dart';
import '../../providers/product_notifier.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Belanja'),
        centerTitle: true,
        elevation: 1,
      ),
      body: Consumer<CartNotifier>(
        builder: (context, cartNotifier, _) {
          if (cartNotifier.isLoading) {
            return const LoadingWidget(message: 'Memuat keranjang...');
          }

          if (cartNotifier.cartItems.isEmpty) {
            return EmptyWidget(
              icon: Icons.shopping_cart_outlined,
              title: 'Keranjang Kosong',
              description: 'Mulai belanja sekarang',
              actionLabel: 'Belanja Sekarang',
              onAction: () => Navigator.pop(context),
            );
          }

          return Column(
            children: [
              // Cart Items List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: cartNotifier.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartNotifier.cartItems[index];
                    return _buildCartItemCard(context, cartNotifier, item);
                  },
                ),
              ),
              // Order Summary & Checkout Button
              _buildCheckoutSection(context, cartNotifier),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItemCard(
    BuildContext context,
    CartNotifier cartNotifier,
    dynamic item,
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
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: AppColors.bgSecondary,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.productImage,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
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
                  Text(
                    item.productName,
                    style: AppTextStyles.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (item.productPrice as num).toCurrency(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Quantity Controls
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          if (item.quantity > 1) {
                            await cartNotifier.updateQuantity(
                              item.id,
                              item.quantity - 1,
                            );
                          }
                        },
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.borderColor),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(Icons.remove, size: 16),
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: Center(
                          child: Text(
                            '${item.quantity}',
                            style: AppTextStyles.bodySmall,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          // Get product stock to validate
                          final productNotifier = context
                              .read<ProductNotifier>();

                          try {
                            final product = productNotifier.products.firstWhere(
                              (p) => p.id == item.productId,
                            );

                            // Check if quantity exceeds stock
                            if (item.quantity >= product.stock) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Stok terbatas! Hanya tersedia ${product.stock} item',
                                  ),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                              return;
                            }

                            await cartNotifier.updateQuantity(
                              item.id,
                              item.quantity + 1,
                            );
                          } catch (_) {
                            // Product not found, allow increment
                            await cartNotifier.updateQuantity(
                              item.id,
                              item.quantity + 1,
                            );
                          }
                        },
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.borderColor),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(Icons.add, size: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Delete Button
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  (item.totalPrice as num).toCurrency(),
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.primaryGreen,
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    await cartNotifier.removeFromCart(item.id);
                    context.showSuccessSnackBar(
                      'Produk dihapus dari keranjang',
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

  Widget _buildCheckoutSection(
    BuildContext context,
    CartNotifier cartNotifier,
  ) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border(top: BorderSide(color: AppColors.borderColor)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pricing Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal:', style: AppTextStyles.bodyMedium),
              Text(
                (cartNotifier.subtotal as num).toCurrency(),
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ongkir:', style: AppTextStyles.bodyMedium),
              Text(
                (cartNotifier.shippingCost as num).toCurrency(),
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(color: AppColors.borderColor, height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total:', style: AppTextStyles.titleSmall),
              Text(
                (cartNotifier.total as num).toCurrency(),
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Checkout Button
          PrimaryButton(
            label: 'Lanjut ke Checkout',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CheckoutScreen(
                    cartItems: cartNotifier.cartItems,
                    subtotal: cartNotifier.subtotal,
                    shippingCost: cartNotifier.shippingCost,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
