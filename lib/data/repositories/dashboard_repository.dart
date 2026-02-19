import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/dashboard/dashboard_model.dart';

class DashboardRepository {
  final Dio _dio = ApiClient.instance;

  Future<DashboardModel> getDashboard() async {
    final response = await _dio.get(ApiConstants.dashboard);
    final data = response.data['data'] as Map<String, dynamic>;
    return DashboardModel.fromJson(data);
  }

  Future<RunwayModel> getRunway() async {
    final response = await _dio.get(ApiConstants.dashboardRunway);
    final data = response.data['data'] as Map<String, dynamic>;
    return RunwayModel.fromJson(data);
  }

  Future<MonthlyStatsModel> getMonthlyStats({int? month, int? year}) async {
    final response = await _dio.get(
      ApiConstants.dashboardMonthlyStats,
      queryParameters: {
        if (month != null) 'month': month,
        if (year != null) 'year': year,
      },
    );
    final data = response.data['data'] as Map<String, dynamic>;
    return MonthlyStatsModel.fromJson(data);
  }
}
