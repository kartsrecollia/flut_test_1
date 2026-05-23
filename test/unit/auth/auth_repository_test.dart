import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flut_test_1/data/models/user_model.dart';
import 'package:flut_test_1/data/repositories/auth_repository.dart';
import 'package:flut_test_1/data/services/i_auth_service.dart';
import 'package:flut_test_1/domain/entities/user.dart';

class MockAuthService extends Mock implements IAuthService {}

const _model = UserModel(id: '1', email: 'test@example.com', name: 'Test');
const _user = User(id: '1', email: 'test@example.com', name: 'Test');

void main() {
  late MockAuthService mockService;
  late AuthRepository repo;

  setUp(() {
    mockService = MockAuthService();
    repo = AuthRepository(mockService);
  });

  tearDown(() => repo.dispose());

  group('AuthRepository', () {
    test('login converts UserModel DTO → User domain entity', () async {
      when(
        () => mockService.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => _model);

      final result = await repo.login(
        email: 'test@example.com',
        password: 'pass',
      );

      expect(result, equals(_user));
    });

    test('login caches currentUser after success', () async {
      when(
        () => mockService.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => _model);

      expect(repo.currentUser, isNull);
      await repo.login(email: 'test@example.com', password: 'pass');
      expect(repo.currentUser, equals(_user));
    });

    test('login emits the new user on authStateStream', () async {
      when(
        () => mockService.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => _model);

      expectLater(repo.authStateStream, emits(equals(_user)));
      await repo.login(email: 'test@example.com', password: 'pass');
    });

    test('logout clears currentUser and emits null on authStateStream',
        () async {
      when(
        () => mockService.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => _model);
      when(() => mockService.logout()).thenAnswer((_) async {});

      await repo.login(email: 'test@example.com', password: 'pass');

      expectLater(repo.authStateStream, emits(isNull));
      await repo.logout();

      expect(repo.currentUser, isNull);
    });

    test('login propagates exceptions from the service', () async {
      when(
        () => mockService.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(Exception('Server error'));

      await expectLater(
        repo.login(email: 'bad@example.com', password: 'wrong'),
        throwsException,
      );
    });
  });
}
