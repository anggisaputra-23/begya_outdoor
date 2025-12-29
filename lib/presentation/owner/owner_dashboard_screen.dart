import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/widgets.dart';
import '../../core/utils/extensions.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/product_notifier.dart';
import '../../providers/order_notifier.dart';
import 'product_management_screen.dart';
import 'add_product_screen.dart';

class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() => _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState extends State<OwnerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final authNotifier = context.read<AuthNotifier>();
      final productNotifier = context.read<ProductNotifier>();
      final orderNotifier = context.read<OrderNotifier>();

      if (authNotifier.isAuthenticated && authNotifier.currentUser != null) {
        productNotifier.getProductsByOwner(authNotifier.currentUser!.id);
        orderNotifier.getAllOrders();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Penjual'),
        centerTitle: true,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              try {
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeSection(),
            const SizedBox(height: 24),
            _buildStatsSection(),
            const SizedBox(height: 24),
            _buildQuickActionsSection(context),
            const SizedBox(height: 24),
            _buildRecentOrdersSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Consumer<AuthNotifier>(
      builder: (context, authNotifier, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selamat Datang 👋', style: AppTextStyles.headingTwo),
            const SizedBox(height: 8),
            Text(
              authNotifier.currentUser?.fullName ?? 'Penjual',
              style: AppTextStyles.titleLarge.copyWith(
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Kelola produk dan pesanan Anda di sini',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsSection() {
    return Consumer2<ProductNotifier, OrderNotifier>(
      builder: (context, productNotifier, orderNotifier, _) {
        final totalProducts = productNotifier.allProducts.length;
        final totalOrders = orderNotifier.orders.length;
        final totalRevenue = orderNotifier.orders.fold<double>(
          0,
          (sum, order) => sum + order.totalPrice,
        );

        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Produk',
                value: '$totalProducts',
                icon: Icons.inventory_2_outlined,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Pesanan',
                value: '$totalOrders',
                icon: Icons.shopping_bag_outlined,
                color: AppColors.infoColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Omset',
                value: (totalRevenue as num).toCurrency(),
                icon: Icons.trending_up_outlined,
                color: AppColors.successColor,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: AppTextStyles.titleSmall.copyWith(color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Aksi Cepat', style: AppTextStyles.titleSmall),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: PrimaryButton(
                label: 'Tambah Produk',
                icon: Icons.add,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddProductScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SecondaryButton(
                label: 'Kelola Produk',
                icon: Icons.edit_outlined,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProductManagementScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentOrdersSection(BuildContext context) {
    return Consumer<OrderNotifier>(
      builder: (context, orderNotifier, _) {
        final recentOrders = orderNotifier.orders.take(5).toList();

        if (recentOrders.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pesanan Terbaru', style: AppTextStyles.titleSmall),
              const SizedBox(height: 12),
              EmptyWidget(
                icon: Icons.receipt_long_outlined,
                title: 'Belum Ada Pesanan',
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Pesanan Terbaru', style: AppTextStyles.titleSmall),
                TextButtonWidget(
                  label: 'Kelola Pesanan',
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => const OrderManagementModal(),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              children: List.generate(recentOrders.length, (index) {
                final order = recentOrders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '#${order.id.substring(0, 8)}',
                                style: AppTextStyles.bodyMedium,
                              ),
                              Text(
                                'Order #${order.id}',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              (order.totalPrice as num).toCurrency(),
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                            const SizedBox(height: 2),
                            _buildStatusBadge(order.status),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    final Map<String, Color> statusColors = {
      'menunggu': AppColors.warningColor,
      'dibayar': AppColors.infoColor,
      'dikirim': AppColors.infoColor,
      'selesai': AppColors.successColor,
    };

    final statusLabel = {
      'pending': 'Menunggu',
      'paid': 'Dibayar',
      'shipped': 'Dikirim',
      'delivered': 'Selesai',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: (statusColors[status] ?? AppColors.textSecondary).withOpacity(
          0.1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        statusLabel[status] ?? 'Unknown',
        style: AppTextStyles.bodySmall.copyWith(
          color: statusColors[status] ?? AppColors.textSecondary,
          fontSize: 10,
        ),
      ),
    );
  }
}

// Order Management Modal untuk Owner
class OrderManagementModal extends StatefulWidget {
  const OrderManagementModal({super.key});

  @override
  State<OrderManagementModal> createState() => _OrderManagementModalState();
}

class _OrderManagementModalState extends State<OrderManagementModal> {
  String? _filterStatus;

  /// Helper untuk format date dengan aman
  String _formatDate(dynamic date) {
    try {
      if (date == null) return 'N/A';
      final dateTime = date is DateTime
          ? date
          : DateTime.parse(date.toString());
      return dateTime.formatDate();
    } catch (e) {
      return 'Tanggal tidak valid';
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, scrollController) {
        return Consumer<OrderNotifier>(
          builder: (context, orderNotifier, _) {
            final orders = _filterStatus == null || _filterStatus!.isEmpty
                ? orderNotifier.orders
                : orderNotifier.getOrdersByStatus(_filterStatus!);

            return Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.borderColor,
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Kelola Pesanan',
                              style: AppTextStyles.headingThree,
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Filter Status
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip('Semua', null),
                              const SizedBox(width: 8),
                              _buildFilterChip('Menunggu', 'menunggu'),
                              const SizedBox(width: 8),
                              _buildFilterChip('Dibayar', 'dibayar'),
                              const SizedBox(width: 8),
                              _buildFilterChip('Dikirim', 'dikirim'),
                              const SizedBox(width: 8),
                              _buildFilterChip('Selesai', 'selesai'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Orders List
                        if (orders.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              child: Text(
                                'Tidak ada pesanan',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          )
                        else
                          Column(
                            children: List.generate(orders.length, (index) {
                              final order = orders[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                elevation: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '#${order.id.substring(0, 8)} - ${order.customerName ?? 'Customer'}',
                                                  style:
                                                      AppTextStyles.bodyMedium,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  _formatDate(order.createdAt),
                                                  style: AppTextStyles.bodySmall
                                                      .copyWith(
                                                        color: AppColors
                                                            .textSecondary,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Text(
                                            (order.totalPrice as num)
                                                .toCurrency(),
                                            style: AppTextStyles.bodyMedium
                                                .copyWith(
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.primaryGreen,
                                                ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      // Customer Info
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.bgSecondary,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.phone_outlined,
                                                  size: 14,
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    (order
                                                                .customerPhone
                                                                ?.isNotEmpty ??
                                                            false)
                                                        ? order.customerPhone!
                                                        : 'Nomor tidak tersedia',
                                                    style:
                                                        AppTextStyles.bodySmall,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.location_on_outlined,
                                                  size: 14,
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    (order
                                                                .customerAddress
                                                                ?.isNotEmpty ??
                                                            false)
                                                        ? order.customerAddress!
                                                        : 'Alamat tidak tersedia',
                                                    style:
                                                        AppTextStyles.bodySmall,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Status & Action - Conditional Button
                                      _buildStatusActionButton(order),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip(String label, String? status) {
    final isActive = _filterStatus == status;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryGreen : Colors.white,
          border: Border.all(
            color: isActive ? AppColors.primaryGreen : AppColors.borderColor,
            width: isActive ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final Map<String, Color> statusColors = {
      'menunggu': AppColors.warningColor,
      'dibayar': AppColors.infoColor,
      'dikirim': AppColors.infoColor,
      'selesai': AppColors.successColor,
    };

    final statusLabel = {
      'menunggu': 'Menunggu',
      'dibayar': 'Dibayar',
      'dikirim': 'Dikirim',
      'selesai': 'Selesai',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (statusColors[status] ?? AppColors.textSecondary).withOpacity(
          0.1,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        statusLabel[status] ?? 'Unknown',
        style: AppTextStyles.bodySmall.copyWith(
          color: statusColors[status] ?? AppColors.textSecondary,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildStatusActionButton(dynamic order) {
    // Simple status display only - no action buttons
    // Orders automatically created with 'dikirim' status
    // Customer confirms receipt to mark as 'selesai'
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatusBadge(order.status),
        const SizedBox.shrink(), // No action button needed
      ],
    );
  }
}
