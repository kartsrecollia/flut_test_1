import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flut_test_1/data/repositories/i_auth_repository.dart';
import 'package:flut_test_1/domain/entities/user.dart';
import 'package:flut_test_1/presentation/auth/cubit/login_cubit.dart';
import 'package:flut_test_1/presentation/auth/cubit/login_state.dart';

// Mocktail generates a mock by extending the abstract interface.
// No code-gen step needed (unlike mockito).
class MockAuthRepository extends Mock implements IAuthRepository {}

const _testUser = User(id: '1', email: 'test@example.com', name: 'Test User');

void main() {
  late MockAuthRepository mockRepo;
  late LoginCubit cubit;

  setUp(() {
    mockRepo = MockAuthRepository();
    cubit = LoginCubit(mockRepo);
  });

  tearDown(() => cubit.close());

  group('LoginCubit', () {
    blocTest<LoginCubit, LoginState>(
      'emits [LoginLoading, LoginSuccess] on valid credentials',
      build: () {
        when(
          () => mockRepo.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => _testUser);
        return cubit;
      },
      act: (c) => c.login(email: 'test@example.com', password: 'password123'),
      expect: () => [isA<LoginLoading>(), isA<LoginSuccess>()],
      verify: (_) => verify(
        () => mockRepo.login(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).called(1),
    );

    blocTest<LoginCubit, LoginState>(
      'emits [LoginLoading, LoginFailure] when repository throws',
      build: () {
        when(
          () => mockRepo.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenThrow(Exception('Invalid credentials'));
        return cubit;
      },
      act: (c) => c.login(email: 'bad@example.com', password: 'wrong'),
      expect: () => [isA<LoginLoading>(), isA<LoginFailure>()],
    );

    blocTest<LoginCubit, LoginState>(
      'emits [LoginFailure] immediately when email is empty — no repo call',
      build: () => cubit,
      act: (c) => c.login(email: '', password: 'anything'),
      expect: () => [isA<LoginFailure>()],
      verify: (_) => verifyNever(
        () => mockRepo.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ),
    );

    blocTest<LoginCubit, LoginState>(
      'emits [LoginInitial] after logout',
      build: () {
        when(() => mockRepo.logout()).thenAnswer((_) async {});
        return cubit;
      },
      act: (c) => c.logout(),
      expect: () => [isA<LoginInitial>()],
    );

    test('LoginSuccess carries the returned user', () async {
      when(
        () => mockRepo.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => _testUser);

      await cubit.login(email: 'test@example.com', password: 'password123');

      expect(cubit.state, isA<LoginSuccess>());
      expect((cubit.state as LoginSuccess).user, equals(_testUser));
    });
  });
}
