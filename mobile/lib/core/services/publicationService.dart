import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/publicationModel.dart';

class PublicationApiService {
  Future<List<PublicationModel>> fetchPublications(String jwtToken, String tabType) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/publications?tab=$tabType');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $jwtToken', // Inyección del JWT
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> decodedData = jsonDecode(response.body);
        return decodedData.map((item) => PublicationModel.fromJson(item)).toList();
      } else {
        throw Exception('Error al cargar publicaciones: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  Future<bool> createPublication(String jwtToken, String content, String? imageUrl) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/publications');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({
          'content': content,
          'imageUrl': imageUrl,
        }),
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}