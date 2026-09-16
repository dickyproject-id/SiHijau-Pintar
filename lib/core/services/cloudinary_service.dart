import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  static final String _cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? 'kumpulanimage';
  
  static final String _uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? 'data_sihijau';

  final cloudinary = CloudinaryPublic(_cloudName, _uploadPreset, cache: false);

  /// Fungsi untuk mengupload gambar ke Cloudinary
  /// Mengembalikan URL HTTPS dari gambar yang berhasil diupload
  Future<String?> uploadImage(File imageFile, {String? folderName}) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: folderName ?? 'sihijau_app', // Nama folder di Cloudinary
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      
      return response.secureUrl; 
    } catch (e) {
      debugPrint("Error uploading image to Cloudinary: $e");
      return null;
    }
  }
}
