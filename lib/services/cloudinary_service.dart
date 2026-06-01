import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  CloudinaryService({
    this.cloudName = 'dpo8yz8cf',
    required this.uploadPreset,
  });

  final String cloudName;
  final String uploadPreset;


  /// Uploads the given images to Cloudinary and returns secure URLs.
  ///
  /// NOTE: This uploads directly from the app and therefore exposes your
  /// credentials inside the mobile app.
  Future<List<String>> uploadImages({
    required List<XFile> images,
  }) async {
    if (images.isEmpty) return const [];

    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    // Unsigned upload using an upload preset (recommended for mobile apps).
    // IMPORTANT: no api_secret / no Authorization header.

    Future<String> uploadOne(XFile xfile) async {
      // On Android/iOS, image_picker may return a non-filesystem "path"


      // (e.g. content://...). Using File(xfile.path) can crash.
      // XFile provides bytes(), which works with those cases.
      final bytes = await xfile.readAsBytes();
      if (bytes.isEmpty) {
        throw Exception('Image bytes are empty for: ${xfile.name}');
      }

      final request = http.MultipartRequest('POST', url);

      // Extra safety: ensure we never accidentally hit HTTP.
      // (If it ever becomes http://, Cloudinary may reject.)
      if (request.url.scheme != 'https') {
        throw Exception('Cloudinary URL must use https. Got: ${request.url}');
      }


      request.fields['folder'] = 'houses';
      request.fields['upload_preset'] = uploadPreset;


      // Helpful for debugging misconfigured accounts/presets.
      debugPrint('Cloudinary upload URL: ${request.url}');


      final filename = xfile.name.isNotEmpty ? xfile.name : 'upload_${DateTime.now().millisecondsSinceEpoch}.jpg';

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: filename,
        ),
      );

      final streamed = await request.send();
      final resp = await http.Response.fromStream(streamed);

      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        throw Exception(
          'Cloudinary upload failed (${resp.statusCode}): ${resp.body}',
        );
      }

      final decoded = jsonDecode(resp.body) as Map<String, dynamic>;
      final secureUrl = decoded['secure_url'] as String?;
      if (secureUrl == null || secureUrl.isEmpty) {
        throw Exception('Cloudinary response missing secure_url: ${resp.body}');
      }
      return secureUrl;
    }

    final uploaded = <String>[];
    for (final img in images) {
      uploaded.add(await uploadOne(img));
    }
    return uploaded;
  }
}


