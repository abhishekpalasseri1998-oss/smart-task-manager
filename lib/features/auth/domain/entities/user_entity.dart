import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
  final String themeMode;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    this.themeMode = 'system',
  });

  UserEntity copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? createdAt,
    String? themeMode,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  List<Object?> get props => [id, name, email, createdAt, themeMode];
}
