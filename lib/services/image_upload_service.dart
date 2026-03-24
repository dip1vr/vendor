import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class ImageUploadService {
  static const String _apiKey = '87ac08b1fe96f1eec8ec5a764548dd56';
  static const String _uploadUrl = 'https://api.imgbb.com/1/upload';

  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    return image;
  }

  Future<String?> uploadImage(XFile imageFile) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(_uploadUrl));
      request.fields['key'] = _apiKey;

      final Uint8List bytes = await imageFile.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes('image', bytes, filename: imageFile.name),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final json = jsonDecode(responseData);

      if (response.statusCode == 200) {
        return json['data']['url'];
      } else {
        print("Image upload failed: ${json['error']['message']}");
        return null;
      }
    } catch (e) {
      print("Error uploading image: $e");
      return null;
    }
  }
}
