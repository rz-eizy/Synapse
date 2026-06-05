import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/publicationModel.dart';

class PublicationApiService {
  Future<List<PublicationModel>> fetchPublications(String jwtToken, String region, {int page = 0, int size = 20}) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/publication/feed?region=$region&page=$page&size=$size');

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
        final List<dynamic> publicationsJson = decodedData['content'] ?? [];
        return publicationsJson.map((item) => PublicationModel.fromJson(item)).toList();
      } else {
        print('Error en GET feed: ${response.statusCode} - ${response.body}');
        throw Exception('Error al cargar publicaciones: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception en GET feed: $e');
      throw Exception('Error de conexión: $e');
    }
  }

  Future<bool> createPublication(String jwtToken, String content, String? imageUrl, String region) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/publication');

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
          'regionTag': region,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        print('Error en POST publicación: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception en POST publicación: $e');
      return false;
    }
  }

  Future<bool> toggleLike(String jwtToken, String idPublication, bool isLike) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/publication/$idPublication/like?isLike=$isLike');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $jwtToken',
        },
      );
      
      if (response.statusCode != 200) {
        print('Error en POST Like: ${response.statusCode} - ${response.body}');
      }
      return response.statusCode == 200;
    } catch (e) {
      print('Exception en Like: $e');
      return false;
    }
  }
}