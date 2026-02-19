import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/dashboard/dashboard_model.dart';
import '../../../data/repositories/dashboard_repository.dart';

// ─── Dashboard ────────────────────────────────────────────────────────────────

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository();
});

final dashboardProvider = FutureProvider.autoDispose<DashboardModel>((
  ref,
) async {
  return ref.read(dashboardRepositoryProvider).getDashboard();
});

// ─── Runway ───────────────────────────────────────────────────────────────────

final runwayProvider = FutureProvider.autoDispose<RunwayModel>((ref) async {
  return ref.read(dashboardRepositoryProvider).getRunway();
});

// ─── Monthly Stats ────────────────────────────────────────────────────────────

final monthlyStatsProvider = FutureProvider.autoDispose<MonthlyStatsModel>((
  ref,
) async {
  return ref.read(dashboardRepositoryProvider).getMonthlyStats();
});
