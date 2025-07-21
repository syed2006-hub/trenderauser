import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trendera/model_providers/product_model.dart';

class GeminiService {
  final String apiKey = "AIzaSyCkjFbB0hHX20av3NMG-TteO4dEuzmmPIc";
  static const _geminiEndpoint =
      "https://generativelanguage.googleapis.com/v1/models/gemini-1.5-flash:generateContent";

  Future<Map<String, List<ProductModel>>> fetchSimilarProducts({
    required File imageFile,
    required List<ProductModel> listProducts,
  }) async {
    final base64Image = base64Encode(await imageFile.readAsBytes());

    String  buildPrompt(List<ProductModel> products) {
      final simplifiedList = products.map((p) {
        return {
          "id": p.id,
          "title": p.title,
          "description": p.productDescription,
          "visual_hint": "This is a ${p.category} item.",
        };
      }).toList();

      return '''
You are given a product image (sent separately) and a list of products.

Each product includes:
- id
- title
- description
- visual_hint

Your task is to analyze the image and compare it with the product list.

Return exactly **two JSON arrays**:
1. "similar_ids" → visually similar products (≥40% match by shape, color, and style)
2. "related_ids" → same type or category, even if not visually similar

⚠️ Format the output as a raw JSON object (no markdown), like:
{
  "similar_ids": ["p1", "p2"],
  "related_ids": ["p3", "p4"]
}

⚠️ DO NOT include explanations or formatting.

Products:
${jsonEncode(simplifiedList)}
''';
    }

    final promptText =  buildPrompt(listProducts);

    final requestBody = {
      "contents": [
        {
          "parts": [
            {
              "inline_data": {"mime_type": "image/jpeg", "data": base64Image},
            },
            {"text": promptText},
          ],
        },
      ],
    };

    try {
      final response = await http.post(
        Uri.parse("$_geminiEndpoint?key=$apiKey"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestBody),
      );

      debugPrint("Gemini response [${response.statusCode}]: ${response.body}");

      if (response.statusCode == 200) {
        return _parseGeminiResponse(response.body, listProducts);
      } else {
        throw Exception("Gemini API error: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Gemini error: $e");
      rethrow;
    }
  }

  /// Parse response and extract matching ProductModel list
  Map<String, List<ProductModel>> _parseGeminiResponse(
    String responseBody,
    List<ProductModel> allProducts,
  ) {
    final decoded = jsonDecode(responseBody);
    final rawOutput = decoded['candidates'][0]['content']['parts'][0]['text'];
    debugPrint("Gemini raw output: $rawOutput");

    final jsonString = _extractJson(rawOutput);
    final Map<String, dynamic> result = jsonDecode(jsonString);

    final List<String> similarIds = (result['similar_ids'] as List<dynamic>)
        .map((e) => e.toString())
        .toList();
    final List<String> relatedIds = (result['related_ids'] as List<dynamic>)
        .map((e) => e.toString())
        .toList();

    final similarProducts =
        allProducts.where((p) => similarIds.contains(p.id)).toList();
    final relatedProducts =
        allProducts.where((p) => relatedIds.contains(p.id)).toList();

    return {
      "similar": similarProducts,
      "related": relatedProducts,
    };
  }

  /// Extract clean JSON from response
  String _extractJson(String raw) {
    final cleaned = raw.trim();

    if (cleaned.startsWith('```')) {
      final match = RegExp(r'```(?:json)?\s*([\s\S]*?)\s*```').firstMatch(cleaned);
      if (match != null) {
        return match.group(1)?.trim() ?? '{}';
      } else {
        throw FormatException("Could not extract JSON from Markdown block.");
      }
    }

    return cleaned;
  }
}
