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
import '../../providers/product_notifier.dart';
import '../../providers/auth_notifier.dart';

/// Home Screen - Halaman utama menampilkan katalog produk
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;
  String _searchQuery = '';

  final List<String> _categories = [
    'Semua',
    'Tenda',
    'Sepatu',
    'Tas',
    'Survival',
  ];

  @override
  void initState() {
    super.initState();
    // Load products dari database
    Future.microtask(() {
      context.read<ProductNotifier>().getProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        elevation: 0,
        title: Text(
          'Begya Outdoor',
          style: AppTextStyles.heading4.copyWith(color: AppColors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_outline),
            onPressed: () {
              GoRouter.of(context).push('/wishlist');
            },
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              GoRouter.of(context).push('/cart');
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              _showProfileMenu(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
              decoration: InputDecoration(
                hintText: 'Cari produk...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.grey100,
              ),
            ),
          ),

          // Category Filter
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final isSelected = index == _selectedCategoryIndex;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: FilterChip(
                    label: Text(_categories[index]),
                    selected: isSelected,
                    backgroundColor: AppColors.grey100,
                    selectedColor: AppColors.primaryGreen,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? AppColors.white
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (selected) {
                      setState(() => _selectedCategoryIndex = index);
                    },
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Products Grid
          Expanded(
            child: Consumer<ProductNotifier>(
              builder: (context, productNotifier, _) {
                if (productNotifier.isLoading) {
                  return const LoadingWidget(message: 'Memuat produk...');
                }

                if (_getFilteredProducts(productNotifier.products).isEmpty) {
                  return const EmptyWidget(
                    title: 'Tidak ada produk',
                    description: 'Belum ada produk yang ditambahkan',
                    icon: Icons.shopping_bag_outlined,
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: _getFilteredProducts(
                    productNotifier.products,
                  ).length,
                  itemBuilder: (context, index) {
                    final product = _getFilteredProducts(
                      productNotifier.products,
                    )[index];
                    return _buildProductCard(context, product);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Filter products berdasarkan search query dan category
  List<Product> _getFilteredProducts(List<Product> products) {
    return products.where((product) {
      // Filter by search query
      final matchesSearch =
          _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery) ||
          product.description.toLowerCase().contains(_searchQuery);

      // Filter by category
      final matchesCategory =
          _selectedCategoryIndex == 0 ||
          _getCategoryId(_selectedCategoryIndex) == product.categoryId;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  /// Get category ID berdasarkan selected index
  String _getCategoryId(int index) {
    switch (index) {
      case 1:
        return 'tenda'; // Tenda
      case 2:
        return 'sepatu'; // Sepatu
      case 3:
        return 'tas'; // Tas
      case 4:
        return 'survival'; // Survival
      default:
        return '';
    }
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () {
        GoRouter.of(context).push('/product/${product.id}');
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image dengan Hero
            Hero(
              tag: 'product_${product.id}',
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Container(
                  height: 140,
                  width: double.infinity,
                  color: AppColors.grey100,
                  // 🖼️ OPTIMIZED IMAGE LOADING dengan caching & shimmer effect
                  child:
                      (product.mainImageUrl != null &&
                          product.mainImageUrl!.isNotEmpty)
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
                          // ❌ ERROR PLACEHOLDER
                          errorWidget: (context, url, error) => Center(
                            child: Icon(
                              Icons.image_not_supported_outlined,
                              color: AppColors.grey400,
                            ),
                          ),
                          // ⚡ OPTIMASI: Caching di device + compression
                          memCacheHeight: 140,
                          memCacheWidth: 200,
                        )
                      : Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: AppColors.grey400,
                          ),
                        ),
                ),
              ),
            ),

            // Product Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.titleSmall,
                    ),

                    const SizedBox(height: 4),

                    // Price
                    Text(
                      (product.price as num).toCurrency(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),

                    const Spacer(),

                    // Stock Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (product.stock > 0)
                          Text(
                            'Stok: ${product.stock}',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primaryGreen,
                            ),
                          )
                        else
                          Text(
                            'Habis',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.errorColor,
                            ),
                          ),
                        if (product.rating != null && product.rating! > 0)
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                product.rating.toString(),
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Consumer<AuthNotifier>(
        builder: (context, authNotifier, _) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(Icons.person, color: AppColors.primaryGreen),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Profil', style: AppTextStyles.bodyMedium),
                            if (authNotifier.currentUser != null)
                              Text(
                                authNotifier.currentUser!.fullName,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.history_outlined),
                  title: const Text('Riwayat Pesanan'),
                  onTap: () {
                    Navigator.pop(context);
                    GoRouter.of(context).push('/order-history');
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () async {
                    try {
                      Navigator.pop(context);
                      if (!mounted) return;
                      await context.read<AuthNotifier>().signOut();
                      if (mounted) {
                        GoRouter.of(context).go('/login');
                      }
                    } catch (e) {
                      debugPrint('Logout error: $e');
                    }
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
