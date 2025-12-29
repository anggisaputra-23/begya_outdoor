import 'package:equatable/equatable.dart';

/// User Model untuk menyimpan data pengguna
/// Schema Supabase: id, full_name, role, created_at
class User extends Equatable {
  final String id;
  final String fullName;
  final String role; // 'owner' atau 'customer'
  final DateTime createdAt;

  const User({
    required this.id,
    required this.fullName,
    required this.role,
    required this.createdAt,
  });

  User copyWith({
    String? id,
    String? fullName,
    String? role,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'full_name': fullName,
    'role': role,
    'created_at': createdAt.toIso8601String(),
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    fullName: (json['full_name'] as String?) ?? 'User',
    role: (json['role'] as String?) ?? 'customer',
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'] as String)
        : DateTime.now(),
  );

  @override
  List<Object?> get props => [id, fullName, role, createdAt];
}
