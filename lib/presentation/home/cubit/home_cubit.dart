import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/i_auth_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final IAuthRepository _repository;

  HomeCubit(this._repository) : super(const HomeInitial());

  // Called once when the HomePage mounts. The router only allows reaching
  // this page when a user is logged in, so currentUser is guaranteed non-null.
  void loadUser() {
    final user = _repository.currentUser;
    if (user != null) emit(HomeLoaded(user));
  }
}
