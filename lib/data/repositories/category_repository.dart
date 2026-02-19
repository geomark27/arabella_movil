import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/category/category_model.dart';

class CategoryRepository {
  final Dio _dio = ApiClient.instance;

  Future<List<CategoryModel>> getCategories({String? type}) async {
    final response = await _dio.get(
      ApiConstants.categories,
      queryParameters: {if (type != null) 'type': type},
    );
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CategoryModel> getCategoryById(int id) async {
    final response = await _dio.get('${ApiConstants.categories}/$id');
    return CategoryModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<CategoryModel> createCategory(CreateCategoryRequest request) async {
    final response = await _dio.post(
      ApiConstants.categories,
      data: request.toJson(),
    );
    return CategoryModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<void> updateCategory(int id, UpdateCategoryRequest request) async {
    await _dio.put('${ApiConstants.categories}/$id', data: request.toJson());
  }

  Future<void> deleteCategory(int id) async {
    await _dio.delete('${ApiConstants.categories}/$id');
  }
}
