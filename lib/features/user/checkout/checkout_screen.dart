import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../models/cart_model.dart';
import '../../../models/order_model.dart';
import '../../../models/address_model.dart';
import '../../../services/cart_service.dart';
import '../../../services/order_service.dart';
import '../../../services/address_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../widgets/beauty_button.dart';
import '../address/address_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final CartService _cartService = CartService();
  final OrderService _orderService = OrderService();
  final AddressService _addressService = AddressService();

  bool _isLoading = false;
  AddressModel? _address;
  List<CartModel> _cartItems = [];
  bool _isLoadingAddress = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoadingAddress = true);

    try {
      _address = await _addressService.getAddress();
      final items = await _cartService.getCart().first;
      setState(() {
        _cartItems = items;
        _isLoadingAddress = false;
      });
    } catch (e) {
      setState(() => _isLoadingAddress = false);
      debugPrint('Error loading data: $e');
    }
  }

  double _getTotal() {
    double total = 0;
    for (final item in _cartItems) {
      total += item.price * item.quantity;
    }
    return total;
  }

  Future<void> _placeOrder() async {
    if (_address == null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddressScreen(
            isCheckout: true,
            onAddressSaved: () => _loadData(),
          ),
        ),
      );
      return;
    }

    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Your cart is empty')));
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Items: ${_cartItems.length}'),
            Text('Total: \$${_getTotal().toStringAsFixed(2)}'),
            const SizedBox(height: 8),
            Text('Deliver to: ${_address!.addressLine}'),
            Text('City: ${_address!.city}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Place Order'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not authenticated');

      final items = _cartItems.map((item) {
        return OrderItemModel(
          productId: item.productId,
          productName: item.productName,
          productPrice: item.price.toString(),
          productImage: item.productImage,
          quantity: item.quantity,
        );
      }).toList();

      await _orderService.createOrderFromCart(
        userId: user.uid,
        userEmail: user.email ?? '',
        userName: _address!.fullName,
        userPhone: _address!.phone,
        address: '${_address!.addressLine}, ${_address!.city}',
        items: items,
        total: _getTotal().toStringAsFixed(2),
        cartItems: _cartItems,
      );

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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: _isLoadingAddress
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ العنوان
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.lightPink),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Delivery Address',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.dark,
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddressScreen(
                                      isCheckout: true,
                                      onAddressSaved: () => _loadData(),
                                    ),
                                  ),
                                );
                                _loadData();
                              },
                              child: const Text('Change'),
                            ),
                          ],
                        ),
                        if (_address != null) ...[
                          const SizedBox(height: 8),
                          Text('👤 ${_address!.fullName}'),
                          Text('📱 ${_address!.phone}'),
                          Text('📍 ${_address!.addressLine}'),
                          Text('🏙️ ${_address!.city}'),
                          if (_address!.notes != null)
                            Text('📝 ${_address!.notes}'),
                        ] else ...[
                          const SizedBox(height: 8),
                          const Text(
                            'No address added yet. Tap Change to add one.',
                            style: TextStyle(color: AppColors.grey),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ✅ المنتجات
                  const Text(
                    'Order Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (_cartItems.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Text('Your cart is empty'),
                      ),
                    )
                  else
                    ..._cartItems.map((item) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: item.productImage.isNotEmpty
                                  ? Image.network(
                                      item.productImage,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
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
                                    item.productName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.dark,
                                    ),
                                  ),
                                  Text(
                                    '\$${item.price.toStringAsFixed(2)} x ${item.quantity}',
                                    style: const TextStyle(
                                      color: AppColors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                  const Divider(height: 32),

                  // ✅ المجموع
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.dark,
                        ),
                      ),
                      Text(
                        '\$${_getTotal().toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  BeautyButton(
                    text: _address == null
                        ? 'Add Address First'
                        : 'Place Order',
                    loading: _isLoading,
                    onPressed: _placeOrder,
                  ),
                ],
              ),
            ),
    );
  }
}
