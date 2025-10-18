import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _productService = ProductService();
  bool _loading = false;

  List<XFile> _pickedImages = [];
  String _selectedCategory = 'Electronics';
  String _productCondition = 'New';

  final picker = ImagePicker();
  final Color primaryColor = const Color.fromARGB(255, 59, 86, 63);
  final bgColor = const Color(0xFFF6F6F6);

  Future<void> _pickImages() async {
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty && _pickedImages.length < 4) {
      setState(() {
        _pickedImages.addAll(picked.take(4 - _pickedImages.length));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _pickedImages.removeAt(index);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _pickedImages.isEmpty) return;

    setState(() => _loading = true);

    try {
      List<String> uploadedUrls = [];
      for (final image in _pickedImages) {
        final url = await _productService.uploadImage(image);
        uploadedUrls.add(url);
      }

      final user = FirebaseAuth.instance.currentUser;

      final product = ProductModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        price: double.parse(_priceController.text.trim()),
        category: _selectedCategory,
        imageUrls: uploadedUrls,
        ownerId: user!.uid,
        condition: _productCondition,
        sellerName: user.displayName ?? 'Seller',
        sellerImageUrl: user.photoURL ?? '',
        createdAt: DateTime.now(),
      );

      await _productService.addProduct(product);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Product posted successfully!")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("❌ Error: $e")));
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildImageGrid() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(_pickedImages.length + 1, (index) {
        if (index == _pickedImages.length && _pickedImages.length < 4) {
          return GestureDetector(
            onTap: _pickImages,
            child: Container(
              width: 100,
              height: 100,
              color: Colors.grey[300],
              child: const Icon(Icons.add, size: 30),
            ),
          );
        } else if (index < _pickedImages.length) {
          return Stack(
            children: [
              Image.file(
                File(_pickedImages[index].path),
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _removeImage(index),
                  child: Container(
                    color: Colors.black54,
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          'Post New Product',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildImageGrid(),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(labelText: 'Title'),
                        validator:
                            (v) => v!.isEmpty ? 'Enter product title' : null,
                      ),
                      TextFormField(
                        controller: _descController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                        maxLines: 2,
                        validator:
                            (v) => v!.isEmpty ? 'Enter description' : null,
                      ),
                      TextFormField(
                        controller: _priceController,
                        decoration: const InputDecoration(labelText: 'Price'),
                        keyboardType: TextInputType.number,
                        validator: (v) => v!.isEmpty ? 'Enter price' : null,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField(
                        value: _selectedCategory,
                        dropdownColor: Color(0xFFF2F2F2),

                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        items:
                            ['Electronics', 'Clothing', 'Books', 'Furniture']
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (value) =>
                                setState(() => _selectedCategory = value!),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField(
                        value: _productCondition,
                        dropdownColor: Color(0xFFF2F2F2),

                        decoration: const InputDecoration(
                          labelText: 'Condition',
                        ),
                        items:
                            ['New', 'Used']
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (value) =>
                                setState(() => _productCondition = value!),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.cloud_upload),
                        label: const Text("Post Product"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            vertical: 19,
                            horizontal: 30,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(27),
                          ),
                          elevation: 5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
