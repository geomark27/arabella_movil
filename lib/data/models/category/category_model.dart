class CategoryModel {
  final int id;
  final String name;
  final String type; // INCOME | EXPENSE
  final int userId;
  final bool isActive;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.userId,
    required this.isActive,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
    id: json['id'] as int,
    name: json['name'] as String,
    type: json['type'] as String,
    userId: json['user_id'] as int? ?? 0,
    isActive: json['is_active'] as bool? ?? true,
  );
}

class CreateCategoryRequest {
  final String name;
  final String type;

  const CreateCategoryRequest({required this.name, required this.type});

  Map<String, dynamic> toJson() => {'name': name, 'type': type};
}

class UpdateCategoryRequest {
  final String? name;
  final bool? isActive;

  const UpdateCategoryRequest({this.name, this.isActive});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (isActive != null) map['is_active'] = isActive;
    return map;
  }
}
