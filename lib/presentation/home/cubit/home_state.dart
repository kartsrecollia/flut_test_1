import 'package:equatable/equatable.dart';
import '../../../domain/entities/user.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoaded extends HomeState {
  final User user;
  const HomeLoaded(this.user);

  @override
  List<Object?> get props => [user];
}
