import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';

class ReportApiService {
  Future<bool> createReport(
    String jwtToken,
    String type,
    String description, {
    String? idReportedUser,
    String? idComment,
    String? idPublication,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/report');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $jwtToken',
        },
        body: jsonEncode({
          'type': type,
          'description': description,
          'idReportedUser': idReportedUser,
          'idComment': idComment,
          'idPublication': idPublication,
        }),
      );
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        print('Error en POST report: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception en POST report: $e');
      return false;
    }
  }

  static String mapUIMotifToReportType(String reason) {
    switch (reason) {
      case 'Contenido inapropiado':
        return 'INAPPROPRIATE';
      case 'Acoso o bullying':
        return 'BULLYING';
      case 'Desinformación':
        return 'DISINFORMATION';
      case 'Spam o publicidad':
        return 'SPAM';
      case 'Discurso de odio':
        return 'HATE';
      case 'Otro':
      default:
        return 'OTHER';
    }
  }
}
