import 'package:flutter/material.dart';
import '../../../models/order_model.dart';
import '../../../services/order_service.dart';
import '../../../core/constants/app_colors.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrderService _orderService = OrderService();

  Future<void> _updateStatus(String orderId, String newStatus) async {
    try {
      await _orderService.updateOrderStatus(
        orderId: orderId,
        newStatus: newStatus,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ Order status updated to ${OrderStatus.getDisplayName(newStatus)}',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Error: $e')));
      }
    }
  }

  Future<void> _cancelOrder(String orderId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _updateStatus(orderId, OrderStatus.cancelled);
    }
  }

  Color _getStatusColor(String status) {
    return OrderStatus.getColor(status);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Orders'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: _orderService.getAllOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 80,
                    color: AppColors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No orders yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Orders will appear here when users place them.',
                    style: TextStyle(color: AppColors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final firstItem = order.items.isNotEmpty
                  ? order.items.first
                  : null;

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ معلومات المستخدم
                    Row(
                      children: [
                        const Icon(
                          Icons.person_outline,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            order.userName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.dark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_outlined,
                          size: 16,
                          color: AppColors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          order.userPhone,
                          style: const TextStyle(color: AppColors.grey),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.email_outlined,
                          size: 16,
                          color: AppColors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          order.userEmail,
                          style: const TextStyle(
                            color: AppColors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppColors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            order.address,
                            style: const TextStyle(
                              color: AppColors.grey,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(),

                    // ✅ معلومات المنتج
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: firstItem?.productImage.isNotEmpty == true
                              ? Image.network(
                                  firstItem!.productImage,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) =>
                                      const Icon(Icons.image, size: 30),
                                )
                              : Container(
                                  width: 50,
                                  height: 50,
                                  color: AppColors.lightPink,
                                  child: const Icon(
                                    Icons.image,
                                    color: AppColors.grey,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                firstItem?.productName ?? 'Unknown Product',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.dark,
                                ),
                              ),
                              Text(
                                firstItem != null
                                    ? '\$${double.tryParse(firstItem.productPrice)?.toStringAsFixed(2) ?? firstItem.productPrice}'
                                    : '\$0.00',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (order.items.length > 1)
                                Text(
                                  '+${order.items.length - 1} more items',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.grey,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(),

                    // ✅ المجموع الكلي
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.dark,
                          ),
                        ),
                        Text(
                          '\$${double.tryParse(order.total)?.toStringAsFixed(2) ?? order.total}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // ✅ حالة الطلب (مع Dropdown)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: _getStatusColor(order.status),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // 👇 Dropdown لتغيير الحالة
                            DropdownButton<String>(
                              value: order.status,
                              underline: const SizedBox(),
                              items: OrderStatus.all.map((status) {
                                return DropdownMenuItem(
                                  value: status,
                                  child: Text(
                                    OrderStatus.getDisplayName(status),
                                    style: TextStyle(
                                      color: OrderStatus.getColor(status),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newStatus) {
                                if (newStatus != null &&
                                    newStatus != order.status) {
                                  _updateStatus(order.id, newStatus);
                                }
                              },
                            ),
                          ],
                        ),
                        Text(
                          '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                          style: const TextStyle(
                            color: AppColors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ✅ زر الإلغاء (للطلبات المعلقة فقط)
                    if (order.status == OrderStatus.pending)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _cancelOrder(order.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade50,
                            foregroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Cancel Order'),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
