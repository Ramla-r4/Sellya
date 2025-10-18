import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ownsell/models/product_model.dart';

class EditProductScreen extends StatefulWidget {
  final ProductModel product;

  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late String _selectedCategory;
  late String _condition;
  List<String> _imageUrls = [];
  List<File> _newImages = [];

  final List<String> _categories = ['Electronics', 'Fashion', 'Home', 'Books', 'Other'];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.product.title);
    _descController = TextEditingController(text: widget.product.description);
    _priceController = TextEditingController(text: widget.product.price.toString());
    _selectedCategory = widget.product.category;
    _condition = widget.product.condition;
    _imageUrls = List.from(widget.product.imageUrls);
  }

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _newImages.addAll(pickedFiles.map((e) => File(e.path)));
      });
    }
  }

  Future<List<String>> _uploadNewImages() async {
    List<String> urls = [];
    for (File img in _newImages) {
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final ref = FirebaseStorage.instance.ref().child('product_images/$fileName');
      await ref.putFile(img);
      final url = await ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final newUploadedUrls = await _uploadNewImages();

    final updatedProduct = ProductModel(
      id: widget.product.id,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      price: double.tryParse(_priceController.text.trim()) ?? 0,
      category: _selectedCategory,
      condition: _condition,
      imageUrls: [..._imageUrls, ...newUploadedUrls],
      ownerId: widget.product.ownerId,
      createdAt: widget.product.createdAt,
      sellerName: widget.product.sellerName,
      sellerImageUrl: widget.product.sellerImageUrl,
    );

    await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.product.id)
        .update(updatedProduct.toMap());

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product updated successfully')),
    );
  }

  void _removeImage(String url) {
    setState(() {
      _imageUrls.remove(url);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Product')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) => value == null || value.isEmpty ? 'Enter title' : null,
                ),
                const SizedBox(height: 10),
                // Description
                TextFormField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 10),
                // Price
                TextFormField(
                  controller: _priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price'),
                  validator: (value) => value == null || value.isEmpty ? 'Enter price' : null,
                ),
                const SizedBox(height: 10),
                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: _categories
                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val!),
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                const SizedBox(height: 10),
                // Condition (New/Used)
                DropdownButtonFormField<String>(
                  value: _condition,
                  items: ['New', 'Used']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setState(() => _condition = val!),
                  decoration: const InputDecoration(labelText: 'Condition'),
                ),
                const SizedBox(height: 10),
                // Existing Images
                if (_imageUrls.isNotEmpty)
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _imageUrls
                        .map(
                          (url) => Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Image.network(url, height: 100, width: 100, fit: BoxFit.cover),
                              IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () => _removeImage(url),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                // New Images Preview
                if (_newImages.isNotEmpty)
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _newImages
                        .map((file) =>
                            Image.file(file, height: 100, width: 100, fit: BoxFit.cover))
                        .toList(),
                  ),
                const SizedBox(height: 12),
                // Add Images Button
                OutlinedButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Add Images'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _updateProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Text('Update Product'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
