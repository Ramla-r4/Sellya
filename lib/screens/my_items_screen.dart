import 'package:flutter/material.dart';
import 'package:ownsell/screens/My%20Items.dart';
import '../models/product_model.dart';

class MyItemsScreen extends StatelessWidget {
  final List<ProductModel> myProducts;

  const MyItemsScreen({super.key, required this.myProducts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F2F2),
      appBar: AppBar(title: const Text("My Items")),
      body: ListView.builder(
        itemCount: myProducts.length,
        itemBuilder: (context, index) {
          return ProductItemCard(product: myProducts[index]);
        },
      ),
    );
  }
}
