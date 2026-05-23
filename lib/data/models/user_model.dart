import '../../domain/entities/user.dart';

// DTO (Data Transfer Object) — mirrors exactly what the API returns.
// This class knows about JSON. The Repository's job is to convert
// this into a domain User so the rest of the app never sees raw API shapes.
class UserModel {
  final String id;
  final String email;
  final String name;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as String,
        email: json['email'] as String,
        name: json['name'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
      };

  // Converts this DTO into the domain entity. Only the Repository calls this.
  User toDomain() => User(id: id, email: email, name: name);
}
