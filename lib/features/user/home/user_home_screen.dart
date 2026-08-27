import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/product_model.dart';
import '../../../services/product_service.dart';
import '../../../services/favorites_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../widgets/product_card.dart';
import '../product/product_details_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final ProductService _productService = ProductService();
  final FavoritesService _favoritesService = FavoritesService();

  String selectedCategory = 'All';
  List<String> categories = ['All'];
  Set<String> favoriteIds = {};

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadFavorites();
  }

  Future<void> _loadCategories() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .orderBy('name')
          .get();

      final cats = snapshot.docs.map((doc) {
        return doc.data()['name'] as String;
      }).toList();

      setState(() {
        categories = ['All', ...cats];
      });
    } catch (e) {
      debugPrint('Error loading categories: $e');
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final ids = await _favoritesService.getFavorites().first;
      setState(() {
        favoriteIds = ids.toSet();
      });
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }

  Future<void> _toggleFavorite(String productId) async {
    try {
      if (favoriteIds.contains(productId)) {
        await _favoritesService.removeFavorite(productId);
        setState(() {
          favoriteIds.remove(productId);
        });
      } else {
        await _favoritesService.addFavorite(productId);
        setState(() {
          favoriteIds.add(productId);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VELORA'),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: AppColors.dark),
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ فلترة التصنيفات
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButton<String>(
                isExpanded: true,
                underline: const SizedBox(),
                value: selectedCategory,
                items: categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
              ),
            ),
          ),

          // ✅ قائمة المنتجات
          Expanded(
            child: StreamBuilder<List<ProductModel>>(
              stream: _productService.getProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                var products = snapshot.data ?? [];

                // فلترة حسب التصنيف
                if (selectedCategory != 'All') {
                  products = products.where((product) {
                    return product.category == selectedCategory;
                  }).toList();
                }

                // تحديث حالة المفضلة
                products = products.map((product) {
                  return product.copyWith(
                    isFavorite: favoriteIds.contains(product.id),
                  );
                }).toList();

                if (products.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 60,
                          color: AppColors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: TextStyle(color: AppColors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: .7,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(
                      product: product,
                      showFavoriteButton: true,
                      onTap: product.quantity > 0
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProductDetailsScreen(product: product),
                                ),
                              );
                            }
                          : null,
                      onFavoriteToggle: () {
                        _toggleFavorite(product.id);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
