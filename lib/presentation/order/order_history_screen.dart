import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/widgets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/extensions.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/order_notifier.dart';
import 'order_detail_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
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
  void initState() {
    super.initState();
    Future.microtask(() {
      final authNotifier = context.read<AuthNotifier>();
      if (authNotifier.isAuthenticated && authNotifier.currentUser != null) {
        context.read<OrderNotifier>().getCustomerOrders(
          authNotifier.currentUser!.id,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pesanan'),
        centerTitle: true,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final authNotifier = context.read<AuthNotifier>();
              if (authNotifier.isAuthenticated &&
                  authNotifier.currentUser != null) {
                context.read<OrderNotifier>().getCustomerOrders(
                  authNotifier.currentUser!.id,
                );
              }
            },
          ),
        ],
      ),
      body: Consumer<OrderNotifier>(
        builder: (context, orderNotifier, _) {
          // Check for errors first
          if (orderNotifier.error != null && orderNotifier.error!.isNotEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    const Text(
                      'Gagal Memuat Pesanan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      orderNotifier.error!,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        final authNotifier = context.read<AuthNotifier>();
                        if (authNotifier.isAuthenticated &&
                            authNotifier.currentUser != null) {
                          context.read<OrderNotifier>().getCustomerOrders(
                            authNotifier.currentUser!.id,
                          );
                        }
                      },
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (orderNotifier.isLoading) {
            return const LoadingWidget(message: 'Memuat pesanan...');
          }

          final orders = _filterStatus == null || _filterStatus!.isEmpty
              ? orderNotifier.orders
              : orderNotifier.getOrdersByStatus(_filterStatus!);

          if (orders.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Belum Ada Pesanan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mulai belanja sekarang untuk melihat pesanan di sini',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Mulai Belanja'),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              // Filter Status
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    _buildStatusChip(label: 'Semua', status: null),
                    const SizedBox(width: 8),
                    _buildStatusChip(label: 'Menunggu', status: 'menunggu'),
                    const SizedBox(width: 8),
                    _buildStatusChip(label: 'Dibayar', status: 'dibayar'),
                    const SizedBox(width: 8),
                    _buildStatusChip(label: 'Dikirim', status: 'dikirim'),
                    const SizedBox(width: 8),
                    _buildStatusChip(label: 'Selesai', status: 'selesai'),
                  ],
                ),
              ),
              // Orders List with Pull to Refresh
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    final authNotifier = context.read<AuthNotifier>();
                    if (authNotifier.isAuthenticated &&
                        authNotifier.currentUser != null) {
                      await context.read<OrderNotifier>().getCustomerOrders(
                        authNotifier.currentUser!.id,
                      );
                    }
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return _buildOrderCard(context, order);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusChip({required String label, required String? status}) {
    final isSelected = _filterStatus == status;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.borderColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, dynamic order) {
    // Use helper method for safe date formatting
    final formatedDate = _formatDate(order.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // Header dengan status badge
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pesanan #${order.id.substring(0, 8).toUpperCase()}',
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatedDate,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(order.status),
              ],
            ),
          ),
          // Divider
          Divider(
            height: 1,
            color: AppColors.borderColor,
            indent: 16,
            endIndent: 16,
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shipping Address
                if (order.customerAddress != null &&
                    order.customerAddress!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 18,
                          color: AppColors.primaryGreen,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            order.customerAddress!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Total Price Box
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.primaryGreen.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Pembayaran',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        (order.totalPrice as num).toCurrency(),
                        style: AppTextStyles.titleSmall.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Footer Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetailScreen(orderId: order.id),
                    ),
                  );
                },
                icon: const Icon(Icons.receipt_long_outlined, size: 18),
                label: const Text(
                  'Lihat Detail',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final Map<String, Map<String, dynamic>> statusMap = {
      'menunggu': {
        'label': 'Menunggu',
        'color': AppColors.warningColor,
        'icon': Icons.schedule_outlined,
      },
      'dibayar': {
        'label': 'Dibayar',
        'color': AppColors.infoColor,
        'icon': Icons.check_circle_outline,
      },
      'dikirim': {
        'label': 'Dikirim',
        'color': AppColors.infoColor,
        'icon': Icons.local_shipping_outlined,
      },
      'selesai': {
        'label': 'Selesai',
        'color': AppColors.successColor,
        'icon': Icons.task_alt_outlined,
      },
      'dibatalkan': {
        'label': 'Dibatalkan',
        'color': AppColors.errorColor,
        'icon': Icons.cancel_outlined,
      },
    };

    final statusInfo =
        statusMap[status] ??
        {
          'label': status.isEmpty ? 'Unknown' : status,
          'color': AppColors.textSecondary,
          'icon': Icons.help_outline,
        };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (statusInfo['color'] as Color).withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusInfo['color'] as Color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusInfo['icon'] as IconData,
            size: 16,
            color: statusInfo['color'] as Color,
          ),
          const SizedBox(width: 6),
          Text(
            statusInfo['label'] as String,
            style: AppTextStyles.bodySmall.copyWith(
              color: statusInfo['color'] as Color,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
