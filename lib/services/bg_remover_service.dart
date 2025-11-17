// lib/services/bg_remover_service.dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class BgRemoverService {
  static const String apiKey = "your_remove_bg_key"; // Get free from remove.bg

  Future<File?> remove(File input) async {
    final url = Uri.parse('https://api.remove.bg/v1.0/removebg');
    final request = http.MultipartRequest('POST', url);
    request.headers['X-Api-Key'] = apiKey;
    request.files.add(
      http.MultipartFile.fromBytes('image_file', await input.readAsBytes()),
    );

    final response = await request.send();
    if (response.statusCode == 200) {
      final bytes = await response.stream.toBytes();
      final dir = await getTemporaryDirectory();
      final output = File('${dir.path}/no_bg.png');
      await output.writeAsBytes(bytes);
      return output;
    }
    return null;
  }
}
