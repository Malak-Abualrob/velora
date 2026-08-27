import 'package:flutter/material.dart';
import '../../../models/product_model.dart';
import '../../../services/order_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../widgets/beauty_button.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final OrderService _orderService = OrderService();
  bool isLoading = false;

  Future<void> _placeOrder() async {
    if (widget.product.quantity <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Product is out of stock')));
      return;
    }

    // ✅ تأكيد الطلب
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Order'),
        content: Text(
          'Order "${widget.product.name}" for \$${widget.product.price}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Order Now'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => isLoading = true);

    try {
      await _orderService.createOrder(productId: widget.product.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Order placed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('❌ Error: $e')));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = widget.product.quantity <= 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ صورة المنتج
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                image: widget.product.imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(widget.product.imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: widget.product.imageUrl.isEmpty
                  ? const Icon(Icons.image, size: 80, color: AppColors.grey)
                  : null,
            ),

            const SizedBox(height: 20),

            // ✅ اسم المنتج
            Text(
              widget.product.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.dark,
              ),
            ),

            const SizedBox(height: 8),

            // ✅ التصنيف والسعر
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.lightPink,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.product.category,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '\$${widget.product.price}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ✅ الكمية المتوفرة
            Row(
              children: [
                const Icon(
                  Icons.inventory_2_outlined,
                  size: 18,
                  color: AppColors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  'Quantity available: ${widget.product.quantity}',
                  style: const TextStyle(color: AppColors.grey),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ✅ حالة التوفر
            if (isOutOfStock)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.red),
                    SizedBox(width: 12),
                    Text(
                      'Out of Stock',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // ✅ الوصف
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.product.description.isNotEmpty
                  ? widget.product.description
                  : 'No description available.',
              style: const TextStyle(color: AppColors.grey, height: 1.5),
            ),

            const SizedBox(height: 30),

            // ✅ زر الطلب
            BeautyButton(
              text: isOutOfStock ? 'Out of Stock' : 'Order Now',
              loading: isLoading,
              onPressed: isOutOfStock ? () {} : _placeOrder,
            ),
          ],
        ),
      ),
    );
  }
}
