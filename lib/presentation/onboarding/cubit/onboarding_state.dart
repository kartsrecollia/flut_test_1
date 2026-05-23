import 'package:equatable/equatable.dart';

class OnboardingState extends Equatable {
  final int  page;
  final bool completed;

  const OnboardingState({this.page = 0, this.completed = false});

  OnboardingState copyWith({int? page, bool? completed}) => OnboardingState(
        page:      page      ?? this.page,
        completed: completed ?? this.completed,
      );

  @override
  List<Object> get props => [page, completed];
}
