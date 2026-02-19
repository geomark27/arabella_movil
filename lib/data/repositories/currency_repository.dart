import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/currency/currency_model.dart';

class CurrencyRepository {
  final Dio _dio = ApiClient.instance;

  Future<List<CurrencyModel>> getCurrencies() async {
    final response = await _dio.get(ApiConstants.currencies);
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((e) => CurrencyModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CurrencyModel> getCurrencyByCode(String code) async {
    final response = await _dio.get('${ApiConstants.currencies}/$code');
    return CurrencyModel.fromJson(
      response.data['data'] as Map<String, dynamic>,
    );
  }
}
