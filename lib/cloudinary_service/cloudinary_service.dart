import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:mime/mime.dart';

class CloudinaryService {
  final String cloudName = "dzg4kohus";
  final String uploadPreset = "trendera_upload";

  Future<String?> uploadImage(File imageFile) async {
    final mimeType = lookupMimeType(imageFile.path);

    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/image/upload",
    );
    final request =
        http.MultipartRequest('POST', uri)
          ..fields['upload_preset'] = uploadPreset
          ..files.add(
            await http.MultipartFile.fromPath(
              'file',
              imageFile.path,
              contentType: mimeType != null ? MediaType.parse(mimeType) : null,
            ),
          );

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final jsonResponse = json.decode(responseData);
      return jsonResponse['secure_url'];
    } else {
      Get.snackbar("upload failed image", "with code: ${response.statusCode}");
      return null;
    }
  }
}

Future<String?> loadProfileImage() async {
  final doc =
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
  return doc.data()?['profile_image'];
}

