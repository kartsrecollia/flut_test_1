import 'package:equatable/equatable.dart';

// Domain entity — the app's pure internal model of a User.
// It has zero knowledge of JSON, HTTP, or databases.
// Both the UI and business logic talk in these terms.
class User extends Equatable {
  final String id;
  final String email;
  final String name;

  const User({
    required this.id,
    required this.email,
    required this.name,
  });

  @override
  List<Object?> get props => [id, email, name];
}
