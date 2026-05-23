import '../models/user_model.dart';
import 'i_auth_service.dart';

// Fake implementation — no network, no backend required.
// Useful for:
//   • Running the app without a server
//   • Fast unit tests (no IO)
//   • UI development & demos
//
// Credentials: test@example.com / password123
class MockAuthService implements IAuthService {
  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800)); // simulate latency

    if (email == 'test@example.com' && password == 'password123') {
      return const UserModel(
        id: 'user-001',
        email: 'test@example.com',
        name: 'Alex Johnson',
      );
    }

    throw Exception('Invalid credentials');
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
