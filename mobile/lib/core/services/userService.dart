import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';

class UserApiService{
  Future<Map<String, dynamic>?> getMyProfile(String token) async {
    try{
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/user/me'), headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch(e) {
      print("Error alcanzando el perfil: $e");
      return null;
    }
  }

  Future<bool> updateProfile(String token, String username, String? profilePictureUrl, String? location) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/user/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'username': username,
          'profilePicture': profilePictureUrl,
          'currentLocation': location ?? 'Araucanía',
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error al actualizar perfil: $e');
      return false;
    }
  }

  Future<bool> deleteProfile(String token) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/user/me'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (e) {
      print('Error al eliminar perfil: $e');
      return false;
    }
  }

  Future<String?> requestProfessionalUpgrade(String token, String imageUrl) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}/professional/requests').replace(queryParameters: {
        'imageUrl': imageUrl
      });
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return null;
      } else {
        print('Error backend status: ${response.statusCode}, body: ${response.body}');
        try {
          final body = jsonDecode(response.body);
          return body['error'] ?? 'Error desconocido al solicitar ascenso';
        } catch (_) {
          return 'Error desconocido al solicitar ascenso';
        }
      }
    } catch (e) {
      print('Error al solicitar ascenso a profesional (Excepción): $e');
      return 'Error de conexión';
    }
  }

  Future<bool> updateProfessionalProfile(String token, Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}/professional/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error al actualizar perfil profesional: $e');
      return false;
    }
  }
}