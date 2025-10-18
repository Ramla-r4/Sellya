import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ownsell/models/product_model.dart';
import 'package:intl/intl.dart';
import 'package:ownsell/screens/EditProduct_Screen.dart';

class ProductOwnerViewScreen extends StatelessWidget {
  final ProductModel product;

  const ProductOwnerViewScreen({super.key, required this.product});

  void _deleteProduct(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete Product'),
            content: const Text(
              'Are you sure you want to delete this product?',
            ),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(ctx, false),
              ),
              TextButton(
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: () => Navigator.pop(ctx, true),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(product.id)
          .delete();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Product deleted')));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting product: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = FirebaseAuth.instance.currentUser?.uid == product.ownerId;
    final dateAdded = DateFormat.yMMMd().format(product.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Product"),
        actions:
            isOwner
                ? [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProductScreen(product: product),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteProduct(context),
                  ),
                ]
                : [],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Product Images
          SizedBox(
            height: 250,
            child: PageView.builder(
              itemCount: product.imageUrls.length,
              itemBuilder:
                  (ctx, index) => ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      product.imageUrls[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
            ),
          ),
          const SizedBox(height: 16),
          // Title + Condition
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  product.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Chip(
                label: Text(product.condition),
                backgroundColor:
                    product.condition == 'New'
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Price
          Text(
            "\$${product.price.toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 20, color: Colors.deepPurple),
          ),
          const SizedBox(height: 8),
          // Category
          Text("Category: ${product.category}"),
          const SizedBox(height: 8),
          // Date
          Text("Posted on: $dateAdded"),
          const Divider(height: 32),
          // Description
          const Text(
            "Description",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(product.description, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
