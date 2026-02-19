import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../utils/storage_service.dart';

/// Interceptor que:
/// 1. Inyecta el Access Token en cada request protegido.
/// 2. Al recibir 401, intenta hacer refresh y reintenta el request.
class AuthInterceptor extends Interceptor {
  final Dio _dio;
  bool _isRefreshing = false;

  AuthInterceptor(this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await StorageService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshToken = await StorageService.getRefreshToken();
        if (refreshToken == null) {
          _isRefreshing = false;
          await StorageService.clearAll();
          return handler.next(err);
        }

        // Intentar refresh con un Dio limpio para evitar bucle
        final refreshDio = Dio(
          BaseOptions(
            baseUrl: ApiConstants.baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 30),
          ),
        );

        final response = await refreshDio.post(
          ApiConstants.refresh,
          data: {'refresh_token': refreshToken},
        );

        final newAccessToken = response.data['access_token'] as String;
        final newRefreshToken = response.data['refresh_token'] as String;

        await StorageService.saveAccessToken(newAccessToken);
        await StorageService.saveRefreshToken(newRefreshToken);

        // Reintentar el request original con el nuevo token
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newAccessToken';

        final retryResponse = await _dio.fetch(opts);
        _isRefreshing = false;
        return handler.resolve(retryResponse);
      } catch (_) {
        _isRefreshing = false;
        await StorageService.clearAll();
        handler.next(err);
      }
    } else {
      handler.next(err);
    }
  }
}
