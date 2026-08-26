import 'dart:io';
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

  String selectedCategory = 'Makeup';
  File? selectedImage;
  bool isLoading = false;

  final categories = ['Makeup', 'Skincare', 'Perfume', 'Hair', 'Nails'];

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

    setState(() => isLoading = true);

    try {
      await ProductService().addProduct(
        name: nameController.text.trim(),
        price: priceController.text.trim(),
        description: descController.text.trim(),
        category: selectedCategory,
        quantity: int.tryParse(qtyController.text.trim()) ?? 0,
        image: selectedImage!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully!')),
        );
        // Clear fields
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
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
            _buildTextField(
              nameController,
              'Product Name',
              Icons.label_outline,
            ),
            const SizedBox(height: 14),
            _buildTextField(
              priceController,
              'Price',
              Icons.attach_money_outlined,
            ),
            const SizedBox(height: 14),
            _buildTextField(
              descController,
              'Description',
              Icons.description_outlined,
              maxLines: 3,
            ),
            const SizedBox(height: 14),
            _buildTextField(
              qtyController,
              'Quantity',
              Icons.numbers_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(Icons.category_outlined),
                ),
                items: categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (value) {
                  setState(() => selectedCategory = value!);
                },
              ),
            ),
            const SizedBox(height: 25),
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
