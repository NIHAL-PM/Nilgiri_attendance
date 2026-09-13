import 'dart:convert';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  static final AuthService instance = AuthService._();
  AuthService._();

  User? _currentUser;
  User? get currentUser => _currentUser;

  Future<User?> login(String email, String password) async {
    final response = await ApiService.instance.post('/auth/login/json', {
      'email': email,
      'password': password,
    });

    if (response != null && response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['access_token'];
      ApiService.instance.setAuthToken(token);

      // Fetch me
      final meResponse = await ApiService.instance.get('/auth/me');
      if (meResponse != null && meResponse.statusCode == 200) {
        final userData = jsonDecode(meResponse.body);
        _currentUser = User(
          id: userData['id'],
          name: userData['name'],
          email: userData['email'],
          avatarUrl: userData['avatar_url'] ?? 'https://i.pravatar.cc/150?img=33',
          isVerified: userData['is_verified'] ?? false,
          totalEvents: userData['total_events'] ?? 0,
          presentCount: userData['present_count'] ?? 0,
          currentStreak: userData['current_streak'] ?? 0,
          accuracyScore: (userData['accuracy_score'] as num?)?.toDouble() ?? 0.912,
        );
        return _currentUser;
      }
    }

    // Demo fallback when server is offline or during testing
    await Future.delayed(const Duration(milliseconds: 600));
    _currentUser = User.demo;
    return _currentUser;
  }

  Future<void> logout() async {
    _currentUser = null;
    ApiService.instance.setAuthToken('');
  }
}
