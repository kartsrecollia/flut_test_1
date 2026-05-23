import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  static const _kDoneKey = 'recollia_onboarding_done';

  OnboardingCubit() : super(const OnboardingState());

  void setPage(int page) => emit(state.copyWith(page: page));

  /// Writes the completion flag and signals the router to redirect to /login.
  Future<void> complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDoneKey, true);
    emit(state.copyWith(completed: true));
  }

  static Future<bool> hasBeenSeen() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kDoneKey) ?? false;
  }
}
