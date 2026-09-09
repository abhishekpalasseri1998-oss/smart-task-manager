import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.createdAt,
    super.themeMode = 'system',
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    DateTime parseCreatedAt(dynamic raw) {
      if (raw is Timestamp) {
        return raw.toDate();
      } else if (raw is String) {
        return DateTime.tryParse(raw) ?? DateTime.now();
      } else if (raw is int) {
        return DateTime.fromMillisecondsSinceEpoch(raw);
      }
      return DateTime.now();
    }

    return UserModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      createdAt: parseCreatedAt(data['createdAt']),
      themeMode: data['themeMode'] as String? ?? 'system',
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json, String id) {
    return UserModel(
      id: id,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      themeMode: json['themeMode'] as String? ?? 'system',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
      'themeMode': themeMode,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'themeMode': themeMode,
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      createdAt: entity.createdAt,
      themeMode: entity.themeMode,
    );
  }
}
