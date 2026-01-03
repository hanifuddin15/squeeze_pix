import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class AIService extends GetxService {
  // TODO: REPLACE WITH YOUR KEY from https://replicate.com/account/api-tokens
  static const String apiKey = "r8_YOUR_REPLICATE_API_KEY_HERE";

  static const String _baseUrl = "https://api.replicate.com/v1/predictions";

  // Models
  static const String _codeFormerVersion =
      "7de2ea26c616d5bf2245ad0d5e24f0ff9a6204578a5c876db53142edd9d2cd56";
  // instant-id might change versions, check replicate.com/instant-id/instant-id
  static const String _rembgVersion = 
      "fb8af171cfa1616ddcf1242c093f9c46bcada5ad4cf6f2fbe8b81b330ec5c003"; // cjwbw/rembg

  Future<File?> removeBackground(File imageFile) async {
    try {
      final String imageUri = await _convertToDataUri(imageFile);

      final body = {
        "version": _rembgVersion,
        "input": {
          "image": imageUri,
        }
      };

      return await _runPrediction(body);
    } catch (e) {
      log("Remove BG Error: $e");
      rethrow;
    }
  }

  Future<File?> enhancePhoto(File imageFile) async {
    try {
      final String imageUri = await _convertToDataUri(imageFile);

      final body = {
        "version": _codeFormerVersion,
        "input": {
          "image": imageUri,
          "codeformer_fidelity": 0.7,
          "background_enhance": true,
          "face_upsample": true,
          "upscale": 2
        }
      };

      return await _runPrediction(body);
    } catch (e) {
      log("Enhance Error: $e");
      rethrow;
    }
  }

  Future<File?> generateHeadshot(
    File imageFile,
    String prompt, {
    String negativePrompt =
        "(lowres, low quality, worst quality:1.2), (text:1.2), watermark, (frame:1.2), deformed, ugly, deformed eyes, blur, out of focus, blurry, deformed cat, deformed, photo, anthropomorphic cat, monochrome, photo, pet collar, gun, weapon, blue, 3d, drones, drone, buildings in background, green",
  }) async {
    try {
      final String imageUri = await _convertToDataUri(imageFile);

      // Using InstantID for face preservation
      // We will use a known stable version or the 'latest' slug logic if possible, but API requires version hash
      // Using a recent specific hash for stability.
      final body = {
        "version":
            "c1e13a4ac654497e88383c2763f04494a8f9024f02a8fc8872583d7350392393", 
        "input": {
          "image": imageUri,
          "prompt": "photo of a person, $prompt, 8k, realistic, high detail, professional photography",
          "negative_prompt": negativePrompt,
          "width": 640,
          "height": 854, // Portrait
          "num_inference_steps": 30,
          "guidance_scale": 5,
          "ip_adapter_scale": 0.8, // High face fidelity
          "control_depth_strength": 0.8
        }
      };

      return await _runPrediction(body);
    } catch (e) {
      log("Headshot Error: $e");
      rethrow;
    }
  }

  Future<File?> _runPrediction(Map<String, dynamic> body) async {
    // 1. Start Prediction
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        "Authorization": "Token $apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 201) {
      throw Exception("Failed to start prediction: ${response.body}");
    }

    final data = jsonDecode(response.body);
    final String getUrl = data['urls']['get'];
    String status = data['status'];

    // 2. Poll for result
    while (status != "succeeded" && status != "failed" && status != "canceled") {
      await Future.delayed(const Duration(seconds: 2));
      final pollResponse = await http.get(
        Uri.parse(getUrl),
        headers: {"Authorization": "Token $apiKey"},
      );
      final pollData = jsonDecode(pollResponse.body);
      status = pollData['status'];
      log("Prediction Status: $status");

      if (status == "succeeded") {
        final output = pollData['output'];
        // Output can be a string (url) or list of strings
        String? resultUrl;
        if (output is List && output.isNotEmpty) {
          resultUrl = output.first;
        } else if (output is String) {
          resultUrl = output;
        }

        if (resultUrl != null) {
          return await _downloadImage(resultUrl);
        }
      } else if (status == "failed" || status == "canceled") {
        throw Exception("Prediction failed: ${pollData['error']}");
      }
    }
    return null;
  }

  Future<String> _convertToDataUri(File file) async {
    final bytes = await file.readAsBytes();
    final String base64Image = base64Encode(bytes);
    return "data:image/jpeg;base64,$base64Image";
  }

  Future<File> _downloadImage(String url) async {
    final response = await http.get(Uri.parse(url));
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/ai_result_${DateTime.now().millisecondsSinceEpoch}.png', // png is safer for remove bg output
    );
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }
}
