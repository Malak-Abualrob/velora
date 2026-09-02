import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../core/constants/app_colors.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final bool showFavoriteButton;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  const ProductCard({
    super.key,
    required this.product,
    this.showFavoriteButton = true,
    this.onTap,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = product.quantity <= 0;

    return GestureDetector(
      onTap: isOutOfStock ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFF0E7E9), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.045),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 6,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: const Color(0xFFF8F3F4),
                    child: product.imageUrl.isNotEmpty
                        ? Image.network(
                            product.imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) {
                              return const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 38,
                                  color: Color(0xFFC8B8BD),
                                ),
                              );
                            },
                          )
                        : const Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 42,
                              color: Color(0xFFC8B8BD),
                            ),
                          ),
                  ),

                  // Favorite Button
                  if (showFavoriteButton)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onFavoriteToggle,
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.94),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              product.isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: product.isFavorite
                                  ? const Color(0xFFB56F7D)
                                  : const Color(0xFF8E7D82),
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Out of Stock
                  if (isOutOfStock)
                    Container(
                      color: Colors.black.withValues(alpha: 0.45),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.94),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Out of Stock',
                            style: TextStyle(
                              color: Color(0xFF302A2D),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Product Information
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 11, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        color: Color(0xFF302A2D),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 5),

                    Text(
                      product.category,
                      style: const TextStyle(
                        color: Color(0xFFB88A95),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const Spacer(),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '\$${product.price}',
                          style: const TextStyle(
                            color: Color(0xFF302A2D),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const Spacer(),

                        if (!isOutOfStock)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6ECEF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${product.quantity} left',
                              style: const TextStyle(
                                color: Color(0xFF9B6F7A),
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
