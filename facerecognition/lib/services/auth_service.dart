import '../models/user.dart';

/// Authentication service - plug JWT / OAuth flow here.
class AuthService {
  static final AuthService instance = AuthService._();
  AuthService._();

  User? _currentUser;
  User? get currentUser => _currentUser;

  // ignore: unused_field
  static const _baseUrl = 'https://api.pulseattend.dev/v1';

  Future<User?> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 900));
    // TODO: POST $_baseUrl/auth/login { email, password }
    // For demo: any credentials succeed
    _currentUser = User.demo;
    return _currentUser;
  }

  Future<void> logout() async {
    _currentUser = null;
  }
}
