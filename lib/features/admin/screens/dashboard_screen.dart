import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int totalOrders = 0;
  int totalProducts = 0;
  int totalUsers = 0;
  int pendingOrders = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => isLoading = true);

    try {
      // ✅ جلب عدد المنتجات
      final productsSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .get();
      totalProducts = productsSnapshot.docs.length;

      // ✅ جلب عدد المستخدمين
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .get();
      totalUsers = usersSnapshot.docs.length;

      // ✅ جلب عدد الطلبات
      final ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .get();
      totalOrders = ordersSnapshot.docs.length;

      // ✅ جلب عدد الطلبات المعلقة
      final pendingSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('status', isEqualTo: 'pending')
          .get();
      pendingOrders = pendingSnapshot.docs.length;

      setState(() => isLoading = false);
    } catch (e) {
      debugPrint('Error loading stats: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // ✅ صف الإحصائيات
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            title: 'Total Orders',
                            value: totalOrders.toString(),
                            icon: Icons.shopping_bag_outlined,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            title: 'Pending',
                            value: pendingOrders.toString(),
                            icon: Icons.pending_actions_outlined,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            title: 'Products',
                            value: totalProducts.toString(),
                            icon: Icons.inventory_2_outlined,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            title: 'Users',
                            value: totalUsers.toString(),
                            icon: Icons.people_outlined,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ✅ زر تحديث
                    Center(
                      child: TextButton.icon(
                        onPressed: _loadStats,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh Stats'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
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
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: AppColors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
