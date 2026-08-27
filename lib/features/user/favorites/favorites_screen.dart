import 'package:flutter/material.dart';
import '../../../models/product_model.dart';
import '../../../services/favorites_service.dart';
import '../../../services/product_service.dart';
import '../../../core/constants/app_colors.dart';
import '../../../widgets/product_card.dart';
import '../product/product_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoritesService _favoritesService = FavoritesService();
  final ProductService _productService = ProductService();

  Set<String> favoriteIds = {};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
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
        title: const Text('My Favorites'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: StreamBuilder<List<ProductModel>>(
        stream: _productService.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          var allProducts = snapshot.data ?? [];

          // ✅ فلترة المنتجات المفضلة فقط
          final favoriteProducts = allProducts
              .where((product) => favoriteIds.contains(product.id))
              .map((product) => product.copyWith(isFavorite: true))
              .toList();

          if (favoriteProducts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: AppColors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Start adding products you love!',
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
            itemCount: favoriteProducts.length,
            itemBuilder: (context, index) {
              final product = favoriteProducts[index];
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
    );
  }
}
