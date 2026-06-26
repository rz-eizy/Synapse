import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/publicationModel.dart';
import 'dart:io';

class PublicationApiService {
  Future<List<PublicationModel>> fetchPublications(String jwtToken, String region, {int page = 0, int size = 20, bool? hasPhoto}) async {
    String urlString = '${ApiConfig.baseUrl}/publication/feed?region=$region&page=$page&size=$size';
    if (hasPhoto != null) {
      urlString += '&hasPhoto=$hasPhoto';
    }
    final url = Uri.parse(urlString);

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

  Future<Map<String, String>?> getUploadURLs(String jwtToken, String contentType) async{
    final url = Uri.parse('${ApiConfig.baseUrl}/publication/upload-url?contentType=$contentType');
    try{
      final response = await http.get(url, headers: {'Authorization': 'Bearer $jwtToken'});
      if (response.statusCode == 200) {
        return Map<String, String>.from(jsonDecode(response.body));
      }
      return null;
    }catch(e){
      print('Exception en getUploadUrls: $e');
      return null;
    }
  }

  Future<bool> uploadImageToCloudFlare(String presignedUrl, File imageFile, String contentType) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final response = await http.put(Uri.parse(presignedUrl), headers: {'Content-Type': contentType, 'Content-Length': bytes.length.toString()}, body: bytes);
      return response.statusCode == 200;
    }catch(e){
      print('Exception al subir a Cloudflare: $e');
      return false;
    }
  }
}