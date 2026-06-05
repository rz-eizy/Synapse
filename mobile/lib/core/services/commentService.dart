import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';

class CommentApiService {
  Future<List<dynamic>> fetchComments(String jwtToken, String idPublication, {int page = 0, int size = 20}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/comment/$idPublication?page=$page&size=$size');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $jwtToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        return decodedData['content'] ?? [];
      } else {
        throw Exception('Error al cargar comentarios: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }


  Future<bool> addComment(String jwtToken, String idPublication, String content) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/comment/$idPublication?content=${Uri.encodeComponent(content)}');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $jwtToken',
        },
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}