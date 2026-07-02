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
}