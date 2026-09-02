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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F8),

      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF7F8),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: const Text(
          'VELORA',
          style: TextStyle(
            color: Color(0xFF302A2D),
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.search_rounded,
                color: Color(0xFF302A2D),
                size: 21,
              ),
            ),
          ),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 4, 20, 2),
            child: Text(
              'Discover your beauty',
              style: TextStyle(
                color: Color(0xFF302A2D),
                fontSize: 26,
                fontWeight: FontWeight.w700,
                height: 1.15,
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(20, 4, 20, 18),
            child: Text(
              'Find something you’ll love ✨',
              style: TextStyle(
                color: Color(0xFF8E7D82),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFEDE3E6), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.035),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E4E8),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Color(0xFF9B6F7A),
                      size: 18,
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Text(
                    'Category',
                    style: TextStyle(
                      color: Color(0xFF8E7D82),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedCategory,
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF9B6F7A),
                        ),
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        style: const TextStyle(
                          color: Color(0xFF302A2D),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
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
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: StreamBuilder<List<ProductModel>>(
              stream: _productService.getProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFFB88A95),
                        ),
                      ),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3E4E8),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.error_outline_rounded,
                              color: Color(0xFF9B6F7A),
                              size: 34,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Something went wrong',
                            style: TextStyle(
                              color: Color(0xFF302A2D),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Error: ${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF9A8A8F),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                var products = snapshot.data ?? [];

                if (selectedCategory != 'All') {
                  products = products.where((product) {
                    return product.category == selectedCategory;
                  }).toList();
                }

                products = products.map((product) {
                  return product.copyWith(
                    isFavorite: favoriteIds.contains(product.id),
                  );
                }).toList();

                if (products.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3E4E8),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.auto_awesome_outlined,
                              size: 44,
                              color: Color(0xFFB88A95),
                            ),
                          ),
                          const SizedBox(height: 22),
                          const Text(
                            'No products found',
                            style: TextStyle(
                              color: Color(0xFF302A2D),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            selectedCategory == 'All'
                                ? 'There are no products available right now.'
                                : 'No products available in this category.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF9A8A8F),
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 18,
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
