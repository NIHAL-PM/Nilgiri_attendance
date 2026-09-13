import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static final ApiService instance = ApiService._();
  ApiService._();

  // Change this to your deployed backend URL or 10.0.2.2 for Android emulator / localhost
  static const String baseUrl = 'http://10.0.2.2:8000/api/v1';

  String? _authToken;
  String? get token => _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Future<http.Response?> get(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      return await http.get(url, headers: _headers).timeout(const Duration(seconds: 4));
    } catch (_) {
      return null; // Fallback to local mock if offline
    }
  }

  Future<http.Response?> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      return await http.post(url, headers: _headers, body: jsonEncode(body)).timeout(const Duration(seconds: 5));
    } catch (_) {
      return null; // Fallback to local mock if offline
    }
  }
}
