import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/i_auth_repository.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/mock_auth_service.dart';
import '../network/dio_client.dart';

// AppDependencies wires the entire dependency graph in one place.
// Every concrete type is constructed here; everything else in the app
// receives interfaces (IAuthRepository, etc.) via constructor injection.
class AppDependencies {
  // ╔══════════════════════════════════════════════════╗
  // ║  ONE-LINE TOGGLE                                 ║
  // ║  true  → MockAuthService  (no backend needed)   ║
  // ║  false → AuthService      (real Dio HTTP calls) ║
  static bool useMock = true;
  // ╚══════════════════════════════════════════════════╝

  final IAuthRepository authRepository;

  AppDependencies._({required this.authRepository});

  factory AppDependencies.setup() {
    final authService =
        useMock ? MockAuthService() : AuthService(DioClient.instance);

    return AppDependencies._(
      authRepository: AuthRepository(authService),
    );
  }
}
