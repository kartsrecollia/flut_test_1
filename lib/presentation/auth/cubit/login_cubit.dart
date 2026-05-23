import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/i_auth_repository.dart';
import 'login_state.dart';

// LoginCubit is the ViewModel in MVVM.
// It holds NO business logic — it translates UI events into repository
// calls and emits states the View renders. It does not know about widgets.
class LoginCubit extends Cubit<LoginState> {
  final IAuthRepository _repository;

  LoginCubit(this._repository) : super(const LoginInitial());

  Future<void> login({required String email, required String password}) async {
    if (email.isEmpty || password.isEmpty) {
      emit(const LoginFailure('Email and password are required.'));
      return;
    }

    emit(const LoginLoading());

    try {
      final user = await _repository.login(email: email, password: password);
      emit(LoginSuccess(user));
      // GoRouter reacts to the repository's authStateStream — no manual
      // navigation call needed here. The Cubit stays navigation-agnostic.
    } catch (e) {
      emit(LoginFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    emit(const LoginInitial());
  }
}
