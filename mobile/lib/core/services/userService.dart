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
}