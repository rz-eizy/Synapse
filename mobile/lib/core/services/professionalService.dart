import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';

class ProfessionalApiService {
  Future<Map<String, dynamic>?> getProfessionals(String token, {int page = 0, int size = 20}) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/professional/list?page=$page&size=$size'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }
      return null;
    } catch (e) {
      print("Error fetching professionals: $e");
      return null;
    }
  }
}
