import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/widgets/widgets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/text_styles.dart';
import '../../core/utils/extensions.dart';
import '../../providers/order_notifier.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
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
      context.read<OrderNotifier>().getOrderById(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        centerTitle: true,
        elevation: 1,
      ),
      body: Consumer<OrderNotifier>(
        builder: (context, orderNotifier, _) {
          if (orderNotifier.isLoading) {
            return const LoadingWidget(message: 'Memuat detail pesanan...');
          }

          final order = orderNotifier.selectedOrder;
          if (order == null) {
            return EmptyWidget(
              icon: Icons.receipt_long_outlined,
              title: 'Pesanan tidak ditemukan',
              description: 'Pesanan ini tidak ada dalam sistem',
            );
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Order Header
                      _buildOrderHeader(order),
                      const SizedBox(height: 24),
                      // Status Timeline
                      _buildStatusTimeline(order),
                      const SizedBox(height: 24),
                      // Customer Info
                      _buildCustomerInfo(order),
                      const SizedBox(height: 24),
                      // Order Items
                      _buildOrderItems(order),
                      const SizedBox(height: 24),
                      // Pricing Summary
                      _buildPricingSummary(order),
                    ],
                  ),
                ),
              ),
              // Received Button (hanya untuk status "dikirim")
              _buildReceivedButton(order),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOrderHeader(dynamic order) {
    return Card(
      elevation: 1,
      color: AppColors.primaryGreen.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pesanan #${order.id.substring(0, 8)}',
                  style: AppTextStyles.headingThree,
                ),
                _buildStatusBadge(order.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(order.createdAt),
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTimeline(dynamic order) {
    final statuses = ['menunggu', 'dibayar', 'dikirim', 'selesai'];
    final statusLabels = {
      'menunggu': 'Menunggu Pembayaran',
      'dibayar': 'Pembayaran Diterima',
      'dikirim': 'Dalam Pengiriman',
      'selesai': 'Terima barang',
    };
    final currentIndex = statuses.indexOf(order.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Status Pesanan', style: AppTextStyles.titleSmall),
        const SizedBox(height: 16),
        Row(
          children: List.generate(statuses.length, (index) {
            final isPassed = index <= currentIndex;
            return Expanded(
              child: Column(
                children: [
                  Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isPassed
                          ? AppColors.primaryGreen
                          : AppColors.bgSecondary,
                      border: Border.all(
                        color: isPassed
                            ? AppColors.primaryGreen
                            : AppColors.borderColor,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        isPassed ? Icons.check : Icons.circle_outlined,
                        color: isPassed
                            ? Colors.white
                            : AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    statusLabels[statuses[index]] ?? '',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isPassed
                          ? AppColors.primaryGreen
                          : AppColors.textSecondary,
                      fontWeight: isPassed ? FontWeight.w600 : FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCustomerInfo(dynamic order) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Informasi Pengiriman', style: AppTextStyles.titleSmall),
            const SizedBox(height: 12),
            _buildInfoRow('Nama', order.customerName),
            const SizedBox(height: 8),
            _buildInfoRow('Telepon', order.customerPhone),
            const SizedBox(height: 8),
            _buildInfoRow('Alamat', order.customerAddress),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItems(dynamic order) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Barang Pesanan', style: AppTextStyles.titleSmall),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal', style: AppTextStyles.bodySmall),
                      Text(
                        ((order.subtotal ?? 0) as num).toCurrency(),
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ongkir', style: AppTextStyles.bodySmall),
                      Text(
                        ((order.shippingCost ?? 0) as num).toCurrency(),
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        ((order.totalPrice ?? 0) as num).toCurrency(),
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '📦 Lihat detail item di riwayat pesanan',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
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

  Widget _buildPricingSummary(dynamic order) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal', style: AppTextStyles.bodyMedium),
                Text(
                  (order.subtotal as num).toCurrency(),
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Ongkir', style: AppTextStyles.bodyMedium),
                Text(
                  (order.shippingCost as num).toCurrency(),
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(color: AppColors.borderColor),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: AppTextStyles.titleSmall),
                Text(
                  (order.totalPrice as num).toCurrency(),
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.primaryGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTextStyles.bodySmall,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    final Map<String, Map<String, dynamic>> statusMap = {
      'menunggu': {'label': 'Menunggu', 'color': AppColors.warningColor},
      'dibayar': {'label': 'Dibayar', 'color': AppColors.infoColor},
      'dikirim': {'label': 'Dikirim', 'color': AppColors.infoColor},
      'selesai': {'label': 'Selesai', 'color': AppColors.successColor},
      'cancelled': {'label': 'Dibatalkan', 'color': AppColors.errorColor},
    };

    final statusInfo =
        statusMap[status] ??
        {'label': 'Unknown', 'color': AppColors.textSecondary};

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (statusInfo['color'] as Color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: statusInfo['color'] as Color),
      ),
      child: Text(
        statusInfo['label'] as String,
        style: AppTextStyles.bodySmall.copyWith(
          color: statusInfo['color'] as Color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildReceivedButton(dynamic order) {
    // Hanya tampil tombol "Pesanan Telah Diterima" jika status "dikirim"
    if (order.status != 'dikirim') {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: PrimaryButton(
        label: '✓ Pesanan Telah Diterima',
        onPressed: () {
          _showReceivedConfirmation(order.id);
        },
      ),
    );
  }

  void _showReceivedConfirmation(String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Pesanan Diterima'),
        content: const Text(
          'Apakah Anda yakin pesanan ini telah diterima dengan baik?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batalkan'),
          ),
          TextButton(
            onPressed: () async {
              try {
                // Update order status and wait
                final success = await context
                    .read<OrderNotifier>()
                    .updateOrderStatus(orderId, 'selesai');

                if (!mounted) return;

                // Close dialog
                Navigator.pop(context);

                // Show result message
                if (success) {
                  try {
                    context.showSuccessSnackBar(
                      'Pesanan ditandai sebagai selesai!',
                    );
                  } catch (e) {
                    debugPrint('Error showing success snackbar: $e');
                  }

                  // Reload order data to show updated status
                  try {
                    await context.read<OrderNotifier>().getOrderById(orderId);
                  } catch (e) {
                    debugPrint('Error reloading order: $e');
                  }

                  // Go back to order history after delay
                  Future.delayed(const Duration(milliseconds: 800), () {
                    if (mounted) {
                      try {
                        Navigator.pop(context);
                      } catch (e) {
                        debugPrint('Error navigating back: $e');
                      }
                    }
                  });
                } else {
                  try {
                    final error =
                        context.read<OrderNotifier>().error ??
                        'Gagal mengupdate pesanan';
                    context.showErrorSnackBar(error);
                  } catch (e) {
                    debugPrint('Error showing error snackbar: $e');
                  }
                }
              } catch (e) {
                if (mounted) {
                  try {
                    Navigator.pop(context);
                    context.showErrorSnackBar('Error: $e');
                  } catch (_) {
                    debugPrint('Error in catch block: $e');
                  }
                }
              }
            },
            child: const Text(
              'Ya, Sudah Diterima',
              style: TextStyle(color: AppColors.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }
}
