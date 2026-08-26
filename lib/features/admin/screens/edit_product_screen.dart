import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../widgets/beauty_button.dart';
import '../../../models/product_model.dart';
import '../../../services/product_service.dart';

class EditProductScreen extends StatefulWidget {
  final ProductModel product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController descController;
  late TextEditingController qtyController;

  late String selectedCategory;
  File? selectedImage;
  bool isLoading = false;

  final categories = ['Makeup', 'Skincare', 'Perfume', 'Hair', 'Nails'];

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.product.name);
    priceController = TextEditingController(text: widget.product.price);
    descController = TextEditingController(text: widget.product.description);
    qtyController = TextEditingController(
      text: widget.product.quantity.toString(),
    );
    selectedCategory = widget.product.category;
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

  Future<void> updateProduct() async {
    setState(() => isLoading = true);

    try {
      await ProductService().updateProduct(
        id: widget.product.id,
        name: nameController.text.trim(),
        price: priceController.text.trim(),
        description: descController.text.trim(),
        category: selectedCategory,
        quantity: int.tryParse(qtyController.text.trim()) ?? 0,
        image: selectedImage,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Product updated!')));
        Navigator.pop(context);
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
        title: const Text('Edit Product'),
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
                      : (widget.product.imageUrl.isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(widget.product.imageUrl),
                                fit: BoxFit.cover,
                              )
                            : null),
                ),
                child: selectedImage == null && widget.product.imageUrl.isEmpty
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
              text: 'Update Product',
              loading: isLoading,
              onPressed: updateProduct,
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
