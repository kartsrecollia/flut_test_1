import 'package:dio/dio.dart';
import '../models/user_model.dart';
import 'i_auth_service.dart';

// Real implementation — makes actual HTTP calls via Dio.
// Swap in by setting useMock = false in injection.dart.
class AuthService implements IAuthService {
  final Dio _dio;

  const AuthService(this._dio);

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return UserModel.fromJson(response.data!['user'] as Map<String, dynamic>);
  }

  @override
  Future<void> logout() async {
    await _dio.post<void>('/auth/logout');
  }
}
