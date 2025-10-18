import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/product_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductService {
  final _firestore = FirebaseFirestore.instance;
  final _uuid = Uuid();

  // Replace these with your actual values from Cloudinary
  static const String _cloudName = 'dsfaxtl6u'; // e.g., 'mycloud123'
  static const String _uploadPreset = 'Flutter_ app'; // e.g., 'flutter_test'

  Future<String> uploadImage(XFile file) async {
    final Uint8List bytes = await file.readAsBytes();
    final Uri uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    final request =
        http.MultipartRequest('POST', uri)
          ..fields['upload_preset'] = _uploadPreset
          ..files.add(
            http.MultipartFile.fromBytes(
              'file',
              bytes,
              filename: '${_uuid.v4()}.jpg',
            ),
          );

    final response = await request.send();

    if (response.statusCode == 200) {
      final resStr = await response.stream.bytesToString();
      final data = jsonDecode(resStr);
      return data['secure_url'];
    } else {
      throw Exception('Failed to upload image to Cloudinary');
    }
  }

  Future<void> addProduct(ProductModel product) async {
    await _firestore
        .collection('products')
        .doc(product.id)
        .set(product.toMap());
  }
}
