import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/app_models.dart';

class ApiService {
  // Use 10.0.2.2 for Android Emulator, localhost for iOS/desktop simulator
  static const String defaultBaseUrl = 'http://10.0.2.2:8000/api/v1';

  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String tokenKey = 'jwt_auth_token';

  ApiService({String baseUrl = defaultBaseUrl}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Attach JWT Authorization Interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: tokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer ';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }

  Future<void> saveToken(String token) async {
    await _storage.write(key: tokenKey, value: token);
  }

  Future<void> logout() async {
    await _storage.delete(key: tokenKey);
  }

  Future<bool> hasToken() async {
    final token = await _storage.read(key: tokenKey);
    return token != null && token.isNotEmpty;
  }

  // --- Auth Endpoints ---
  Future<Map<String, dynamic>> login(String emailOrId, String password) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email_or_id': emailOrId, 'password': password},
    );
    final token = response.data['access_token'];
    await saveToken(token);
    return {
      'user': UserModel.fromJson(response.data['user']),
      'token': token,
    };
  }

  // --- Biometrics Registration ---
  Future<bool> registerBiometrics(List<double> embedding) async {
    final response = await _dio.post(
      '/biometrics/register',
      data: {'embedding': embedding},
    );
    return response.data['is_face_registered'] ?? false;
  }

  // --- Events ---
  Future<List<EventModel>> getActiveEvents() async {
    final response = await _dio.get('/events/active');
    final List list = response.data;
    return list.map((e) => EventModel.fromJson(e)).toList();
  }

  // --- Attendance Verification ---
  Future<AttendanceVerifyResult> verifyAttendance({
    required String eventId,
    required List<double> embedding,
    double? latitude,
    double? longitude,
  }) async {
    final response = await _dio.post(
      '/attendance/verify',
      data: {
        'event_id': eventId,
        'embedding': embedding,
        'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      },
    );
    return AttendanceVerifyResult.fromJson(response.data);
  }
}
