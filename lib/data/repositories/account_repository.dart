import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/account/account_model.dart';

class AccountRepository {
  final Dio _dio = ApiClient.instance;

  Future<List<AccountModel>> getAccounts() async {
    final response = await _dio.get(ApiConstants.accounts);
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((e) => AccountModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AccountModel> getAccountById(int id) async {
    final response = await _dio.get('${ApiConstants.accounts}/$id');
    return AccountModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<AccountModel> createAccount(CreateAccountRequest request) async {
    final response = await _dio.post(
      ApiConstants.accounts,
      data: request.toJson(),
    );
    return AccountModel.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  Future<void> updateAccount(int id, UpdateAccountRequest request) async {
    await _dio.put('${ApiConstants.accounts}/$id', data: request.toJson());
  }

  Future<void> deleteAccount(int id) async {
    await _dio.delete('${ApiConstants.accounts}/$id');
  }
}
