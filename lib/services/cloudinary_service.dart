import 'dart:io' as io;
import 'package:dio/dio.dart';

class CloudinaryService {
  static const String cloudName = 'dsfaxtl6u';
  static const String uploadPreset = 'Flutter_ app';
  static Future<String?> uploadFile(io.File file) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        'upload_preset': uploadPreset,
      });

      final response = await Dio().post(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      if (response.statusCode == 200) {
        print('✅ Cloudinary upload successful');
        return response.data['secure_url'];
      } else {
        print('❌ Cloudinary upload failed');
        print('Response: ${response.data}');
        return null;
      }
    } catch (e, stack) {
      print('❌ Cloudinary upload error: $e');
      print('Stack trace:\n$stack');
      return null;
    }
  }
}
