import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthServices {
  static Future<Map<String, dynamic>> fetchAzureUserDetails(
      String accessToken) async {
    final response = await http.get(
      Uri.parse("https://graph.microsoft.com/v1.0/me"),
      headers: {"Authorization": "Bearer $accessToken"},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Failed to fetch user details");
    }
  }
}
