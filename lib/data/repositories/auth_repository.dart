import 'dart:async';
import '../../domain/entities/user.dart';
import '../services/i_auth_service.dart';
import 'i_auth_repository.dart';

class AuthRepository implements IAuthRepository {
  final IAuthService _service;
  final _authStateController = StreamController<User?>.broadcast();
  User? _currentUser;

  AuthRepository(this._service);

  @override
  Stream<User?> get authStateStream => _authStateController.stream;

  @override
  User? get currentUser => _currentUser;

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    // 1. Delegate the raw call to the service (returns a DTO)
    final model = await _service.login(email: email, password: password);

    // 2. Convert the DTO into a domain entity — the rest of the app
    //    never sees UserModel, only User
    final user = model.toDomain();

    // 3. Cache and broadcast so GoRouter can redirect
    _currentUser = user;
    _authStateController.add(user);

    return user;
  }

  @override
  Future<void> logout() async {
    await _service.logout();
    _currentUser = null;
    _authStateController.add(null);
  }

  void dispose() => _authStateController.close();
}
