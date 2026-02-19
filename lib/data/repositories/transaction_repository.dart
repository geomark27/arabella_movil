import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/transaction/transaction_model.dart';

class TransactionRepository {
  final Dio _dio = ApiClient.instance;

  Future<TransactionListResponse> getTransactions({
    String? type,
    int? accountId,
    int? categoryId,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get(
      ApiConstants.transactions,
      queryParameters: {
        if (type != null) 'type': type,
        if (accountId != null) 'account_id': accountId,
        if (categoryId != null) 'category_id': categoryId,
        'page': page,
        'page_size': pageSize,
      },
    );
    return TransactionListResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  Future<TransactionModel> getTransactionById(int id) async {
    final response = await _dio.get('${ApiConstants.transactions}/$id');
    return TransactionModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<TransactionModel> createTransaction(
    CreateTransactionRequest request,
  ) async {
    final response = await _dio.post(
      ApiConstants.transactions,
      data: request.toJson(),
    );
    return TransactionModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }

  Future<void> updateTransaction(
    int id,
    UpdateTransactionRequest request,
  ) async {
    await _dio.put('${ApiConstants.transactions}/$id', data: request.toJson());
  }

  Future<void> deleteTransaction(int id) async {
    await _dio.delete('${ApiConstants.transactions}/$id');
  }
}
