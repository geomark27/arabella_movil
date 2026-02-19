import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/storage_service.dart';
import '../models/auth/auth_models.dart';

class AuthRepository {
  final Dio _dio = ApiClient.instance;

  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _dio.post(
      ApiConstants.login,
      data: request.toJson(),
    );
    final auth = AuthResponse.fromJson(response.data as Map<String, dynamic>);
    await StorageService.saveAccessToken(auth.accessToken);
    await StorageService.saveRefreshToken(auth.refreshToken);
    return auth;
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    final response = await _dio.post(
      ApiConstants.register,
      data: request.toJson(),
    );
    final auth = AuthResponse.fromJson(response.data as Map<String, dynamic>);
    await StorageService.saveAccessToken(auth.accessToken);
    await StorageService.saveRefreshToken(auth.refreshToken);
    return auth;
  }

  Future<RefreshResponse> refreshToken(String refreshToken) async {
    final response = await _dio.post(
      ApiConstants.refresh,
      data: RefreshRequest(refreshToken: refreshToken).toJson(),
    );
    final result = RefreshResponse.fromJson(
      response.data as Map<String, dynamic>,
    );
    await StorageService.saveAccessToken(result.accessToken);
    await StorageService.saveRefreshToken(result.refreshToken);
    return result;
  }

  Future<void> changePassword(ChangePasswordRequest request) async {
    await _dio.put(ApiConstants.changePassword, data: request.toJson());
  }

  Future<void> logout() async {
    await StorageService.clearAll();
  }

  Future<bool> isLoggedIn() async {
    final token = await StorageService.getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
