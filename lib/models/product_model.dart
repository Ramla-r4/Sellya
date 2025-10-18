// class ProductModel {
//   final String id;
//   final String title;
//   final String description;
//   final double price;
//   final String category;
//   final List<String> imageUrls;
//   final String ownerId;
//   // final DateTime createdAt;
//   final String condition; // 'New' or 'Used'

//   ProductModel({
//     required this.id,
//     required this.title,
//     required this.description,
//     required this.price,
//     required this.category,
//     required this.imageUrls,
//     required this.ownerId,
//     // required this.createdAt,
//     required this.condition,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'title': title,
//       'description': description,
//       'price': price,
//       'category': category,
//       'imageUrls': imageUrls,
//       'ownerId': ownerId,
//       // 'createdAt': createdAt.toIso8601String(),
//       'condition': condition,
//     };
//   }

//   factory ProductModel.fromMap(Map<String, dynamic> map, String docId) {
//     return ProductModel(
//       id: docId,
//       title: map['title'] ?? '',
//       description: map['description'] ?? '',
//       price: (map['price'] as num?)?.toDouble() ?? 0.0,
//       category: map['category'] ?? '',
//       ownerId: map['ownerId'] ?? '',
//       imageUrls: (map['imageUrls'] as List?)?.cast<String>() ?? [],
//       condition: map['condition'] ?? 'New',
//       // createdAt: map['createdAt'] ?? Timestamp.now(),
//     );
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String category;
  final List<String> imageUrls;
  final String ownerId;
  final String condition; // 'New' or 'Used'
  final String sellerName;
  final String sellerImageUrl;
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrls,
    required this.ownerId,
    required this.condition,
    required this.sellerName,
    required this.sellerImageUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'category': category,
      'imageUrls': imageUrls,
      'ownerId': ownerId,
      'condition': condition,
      'sellerName': sellerName,
      'sellerImageUrl': sellerImageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map, String docId) {
    return ProductModel(
      id: docId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] ?? '',
      imageUrls: (map['imageUrls'] as List?)?.cast<String>() ?? [],
      ownerId: map['ownerId'] ?? '',
      condition: map['condition'] ?? 'New',
      sellerName: map['sellerName'] ?? '',
      sellerImageUrl: map['sellerImageUrl'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  /// 🔴 ADD THIS METHOD
  Future<void> delete() async {
    await FirebaseFirestore.instance.collection('products').doc(id).delete();
  }
}
