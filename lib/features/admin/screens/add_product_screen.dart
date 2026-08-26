import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../widgets/beauty_button.dart';
import '../../../services/product_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final descController = TextEditingController();
  final qtyController = TextEditingController();

  String? selectedCategory; // 👈 nullable عشان نعرف إذا اختار ولا لأ
  File? selectedImage;
  bool isLoading = false;

  // 👇 قائمة التصنيفات من Firestore
  List<String> categories = [];
  bool isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
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
        categories = cats;
        isLoadingCategories = false;
        if (categories.isNotEmpty) {
          selectedCategory =
              categories.first; // اختيار أول تصنيف كقيمة افتراضية
        }
      });
    } catch (e) {
      debugPrint('Error loading categories: $e');
      setState(() {
        isLoadingCategories = false;
      });
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() => selectedImage = File(image.path));
    }
  }

  Future<void> addProduct() async {
    if (selectedImage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select an image')));
      return;
    }

    if (selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    setState(() => isLoading = true);

    try {
      await ProductService().addProduct(
        name: nameController.text.trim(),
        price: priceController.text.trim(),
        description: descController.text.trim(),
        category: selectedCategory!,
        quantity: int.tryParse(qtyController.text.trim()) ?? 0,
        image: selectedImage!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Product added successfully!')),
        );
        nameController.clear();
        priceController.clear();
        descController.clear();
        qtyController.clear();
        setState(() => selectedImage = null);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product'),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ✅ اختيار الصورة
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  image: selectedImage != null
                      ? DecorationImage(
                          image: FileImage(selectedImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: selectedImage == null
                    ? const Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 60,
                        color: AppColors.grey,
                      )
                    : null,
              ),
            ),

            const SizedBox(height: 16),

            // ✅ اسم المنتج
            _buildTextField(
              nameController,
              'Product Name',
              Icons.label_outline,
            ),
            const SizedBox(height: 14),

            // ✅ السعر
            _buildTextField(
              priceController,
              'Price',
              Icons.attach_money_outlined,
            ),
            const SizedBox(height: 14),

            // ✅ الوصف
            _buildTextField(
              descController,
              'Description',
              Icons.description_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 14),

            // ✅ الكمية
            _buildTextField(
              qtyController,
              'Quantity',
              Icons.numbers_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 14),

            // ✅ Dropdown التصنيفات من Firestore
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: isLoadingCategories
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Text('Loading categories...'),
                        ],
                      ),
                    )
                  : categories.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_outlined,
                            color: Colors.orange,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'No categories. Add one from Categories tab!',
                            style: TextStyle(color: AppColors.grey),
                          ),
                        ],
                      ),
                    )
                  : DropdownButtonFormField<String>(
                      initialValue: selectedCategory,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        icon: Icon(Icons.category_outlined),
                      ),
                      items: categories.map((cat) {
                        return DropdownMenuItem(value: cat, child: Text(cat));
                      }).toList(),
                      onChanged: (value) {
                        setState(() => selectedCategory = value);
                      },
                    ),
            ),

            const SizedBox(height: 25),

            // ✅ زر الإضافة
            BeautyButton(
              text: 'Add Product',
              loading: isLoading,
              onPressed: addProduct,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          icon: Icon(icon),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
