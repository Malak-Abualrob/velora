import 'package:flutter/material.dart';

import '../models/beauty_product_model.dart';

class HomeController extends ChangeNotifier {
  final categories = [
    'Makeup',
    'Skincare',
    'Perfume',
  ];

  final categoryIcons = [
    Icons.brush_outlined,
    Icons.spa_outlined,
    Icons.auto_awesome_outlined,
  ];

  final products = const [
    BeautyProductModel(
      name: 'Rose Lipstick',
      category: 'Makeup',
      image: 'assets/images/lipstick.jpg',
      price: '\$24',
    ),
    BeautyProductModel(
      name: 'Velora Bloom',
      category: 'Perfume',
      image: 'assets/images/perfume.jpg',
      price: '\$45',
    ),
    BeautyProductModel(
      name: 'Glow Care Set',
      category: 'Skincare',
      image: 'assets/images/skincare.jpg',
      price: '\$35',
    ),
    BeautyProductModel(
      name: 'Soft Glam Kit',
      category: 'Makeup',
      image: 'assets/images/makeup.jpg',
      price: '\$40',
    ),
  ];

  int selectedCategory = 0;

  void selectCategory(int index) {
    selectedCategory = index;
    notifyListeners();
  }
}