import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/user/user_model.dart';

class UserRepository {
  final Dio _dio = ApiClient.instance;

  Future<List<UserModel>> getUsers() async {
    final response = await _dio.get(ApiConstants.users);
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((e) => UserModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<UserModel> getUserById(int id) async {
    final response = await _dio.get('${ApiConstants.users}/$id');
    return UserModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> updateUser(int id, UpdateUserRequest request) async {
    await _dio.put('${ApiConstants.users}/$id', data: request.toJson());
  }

  Future<void> deleteUser(int id) async {
    await _dio.delete('${ApiConstants.users}/$id');
  }
}
