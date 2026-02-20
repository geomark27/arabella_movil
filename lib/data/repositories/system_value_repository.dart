import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/system_value/system_value_model.dart';

class SystemValueRepository {
  final Dio _dio = ApiClient.instance;

  /// Obtiene todos los valores activos de un catálogo específico.
  /// Endpoint: GET /api/v1/system-values/catalog/{catalogType}
  ///
  /// Catálogos disponibles:
  ///   - ACCOUNT_TYPE
  ///   - ACCOUNT_CLASSIFICATION
  ///   - TRANSACTION_TYPE
  ///   - CATEGORY_TYPE
  ///   - JOURNAL_ENTRY_TYPE
  Future<List<SystemValueModel>> getCatalog(String catalogType) async {
    final response = await _dio.get(
      ApiConstants.systemValuesCatalogByType(catalogType),
    );
    final data = response.data['data'] as List<dynamic>;
    return data
        .map((e) => SystemValueModel.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
  }
}
