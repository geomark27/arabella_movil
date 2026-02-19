import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/dashboard/dashboard_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardProvider);
            ref.invalidate(monthlyStatsProvider);
          },
          color: AppTheme.primary,
          backgroundColor: AppTheme.surface,
          child: CustomScrollView(
            slivers: [
              // ── AppBar ─────────────────────────────────────────────
              SliverAppBar(
                floating: true,
                backgroundColor: AppTheme.background,
                elevation: 0,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hola, ${authState.user?.firstName ?? 'Bienvenido'} 👋',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.onSurface,
                      ),
                    ),
                    Text(
                      DateFormat(
                        'EEEE, d MMM yyyy',
                        'es',
                      ).format(DateTime.now()),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.onSurfaceMuted,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: AppTheme.onSurfaceMuted,
                    ),
                    onPressed: () {
                      ref.invalidate(dashboardProvider);
                      ref.invalidate(monthlyStatsProvider);
                    },
                  ),
                ],
              ),

              // ── Body content ────────────────────────────────────────
              dashboardAsync.when(
                loading:
                    () => const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                error:
                    (err, _) => SliverFillRemaining(
                      child: _ErrorView(
                        message: err.toString(),
                        onRetry: () => ref.invalidate(dashboardProvider),
                      ),
                    ),
                data:
                    (dashboard) => SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // Runway card
                          _RunwayCard(
                            months: dashboard.runway,
                            days: dashboard.runwayDays,
                            availableFunds: dashboard.liquidAssets,
                          ),
                          const SizedBox(height: 16),

                          // Net worth card
                          _NetWorthCard(dashboard: dashboard),
                          const SizedBox(height: 16),

                          // Monthly stats
                          _MonthlyStatsRow(dashboard: dashboard),
                          const SizedBox(height: 24),

                          // Accounts section
                          const _SectionTitle(title: 'Mis cuentas'),
                          const SizedBox(height: 12),
                          ...dashboard.accountBalances.map(
                            (a) => _AccountBalanceRow(account: a),
                          ),

                          const SizedBox(height: 32),
                        ]),
                      ),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Runway Card ──────────────────────────────────────────────────────────────

class _RunwayCard extends StatelessWidget {
  final double months;
  final int days;
  final String availableFunds;

  const _RunwayCard({
    required this.months,
    required this.days,
    required this.availableFunds,
  });

  Color get _statusColor {
    if (months >= 6) return AppTheme.runwayHealthy;
    if (months >= 3) return AppTheme.runwayWarning;
    return AppTheme.runwayCritical;
  }

  String get _statusLabel {
    if (months >= 6) return 'SALUDABLE';
    if (months >= 3) return 'ATENCIÓN';
    return 'CRÍTICO';
  }

  String get _statusEmoji {
    if (months >= 6) return '🟢';
    if (months >= 3) return '🟡';
    return '🔴';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _statusColor.withOpacity(0.15),
            _statusColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _statusColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_statusEmoji $_statusLabel',
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              Icon(Icons.flight_takeoff_rounded, color: _statusColor, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'RUNWAY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurfaceMuted,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                months.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: _statusColor,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'meses\n($days días)',
                  style: TextStyle(
                    fontSize: 14,
                    color: _statusColor.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Fondos disponibles: ${CurrencyFormatter.format(availableFunds)}',
            style: const TextStyle(
              color: AppTheme.onSurfaceMuted,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (months / 12).clamp(0.0, 1.0),
              backgroundColor: AppTheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(_statusColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Net Worth Card ───────────────────────────────────────────────────────────

class _NetWorthCard extends StatelessWidget {
  final DashboardModel dashboard;

  const _NetWorthCard({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final netWorth = CurrencyFormatter.parseAmount(dashboard.netWorth);
    final isPositive = netWorth >= 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PATRIMONIO NETO',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurfaceMuted,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.format(dashboard.netWorth),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: isPositive ? AppTheme.onSurface : AppTheme.expense,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _MiniStatItem(
                  label: 'Activos',
                  value: CurrencyFormatter.format(dashboard.totalAssets),
                  color: AppTheme.success,
                  icon: Icons.trending_up_rounded,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MiniStatItem(
                  label: 'Pasivos',
                  value: CurrencyFormatter.format(dashboard.totalLiabilities),
                  color: AppTheme.expense,
                  icon: Icons.trending_down_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MiniStatItem({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.onSurfaceMuted,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Monthly Stats Row ────────────────────────────────────────────────────────

class _MonthlyStatsRow extends StatelessWidget {
  final DashboardModel dashboard;

  const _MonthlyStatsRow({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          title:
              'Este mes — ${DateFormat('MMMM yyyy', 'es').format(DateTime.now())}',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MonthStatCard(
                label: 'Ingresos',
                value: CurrencyFormatter.format(dashboard.monthlyIncome),
                color: AppTheme.income,
                icon: Icons.arrow_downward_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MonthStatCard(
                label: 'Gastos',
                value: CurrencyFormatter.format(dashboard.monthlyExpenses),
                color: AppTheme.expense,
                icon: Icons.arrow_upward_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MonthStatCard(
                label: 'Neto',
                value: CurrencyFormatter.format(dashboard.monthlyNetCashFlow),
                color:
                    CurrencyFormatter.parseAmount(
                              dashboard.monthlyNetCashFlow,
                            ) >=
                            0
                        ? AppTheme.income
                        : AppTheme.expense,
                icon: Icons.swap_vert_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MonthStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _MonthStatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.onSurfaceMuted,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Account Balance Row ──────────────────────────────────────────────────────

class _AccountBalanceRow extends StatelessWidget {
  final AccountBalanceSummary account;

  const _AccountBalanceRow({required this.account});

  IconData get _icon {
    switch (account.type) {
      case 'BANK':
        return Icons.account_balance_rounded;
      case 'CASH':
        return Icons.payments_rounded;
      case 'CREDIT_CARD':
        return Icons.credit_card_rounded;
      case 'SAVINGS':
        return Icons.savings_rounded;
      case 'INVESTMENT':
        return Icons.show_chart_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }

  Color get _typeColor {
    switch (account.type) {
      case 'CREDIT_CARD':
        return AppTheme.expense;
      case 'INVESTMENT':
        return AppTheme.secondary;
      default:
        return AppTheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final balance = CurrencyFormatter.format(
      account.balance,
      symbol: account.currencySymbol,
    );
    final isLiability = account.type == 'CREDIT_CARD';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _typeColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_icon, color: _typeColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  account.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurface,
                  ),
                ),
                Text(
                  '${account.type} · ${account.currencyCode}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.onSurfaceMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            balance,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isLiability ? AppTheme.expense : AppTheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Title ────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppTheme.onSurface,
      ),
    );
  }
}

// ─── Error view ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 64,
              color: AppTheme.onSurfaceMuted,
            ),
            const SizedBox(height: 16),
            const Text(
              'No se pudo cargar el dashboard',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Verifica que el backend esté activo y tu conexión sea correcta.',
              style: TextStyle(fontSize: 14, color: AppTheme.onSurfaceMuted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
