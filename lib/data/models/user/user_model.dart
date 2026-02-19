class UserModel {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String? userName;
  final String? avatarUrl;
  final bool? isActive;

  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.userName,
    this.avatarUrl,
    this.isActive,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as int,
    firstName: json['first_name'] as String,
    lastName: json['last_name'] as String,
    email: json['email'] as String,
    userName: json['user_name'] as String?,
    avatarUrl: json['avatar_url'] as String?,
    isActive: json['is_active'] as bool?,
  );

  String get fullName => '$firstName $lastName';

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$f$l';
  }
}

class UpdateUserRequest {
  final String? firstName;
  final String? lastName;
  final String? userName;
  final String? email;
  final String? avatarUrl;

  const UpdateUserRequest({
    this.firstName,
    this.lastName,
    this.userName,
    this.email,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (firstName != null) map['first_name'] = firstName;
    if (lastName != null) map['last_name'] = lastName;
    if (userName != null) map['user_name'] = userName;
    if (email != null) map['email'] = email;
    if (avatarUrl != null) map['avatar_url'] = avatarUrl;
    return map;
  }
}
