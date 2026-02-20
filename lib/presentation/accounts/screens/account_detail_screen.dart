import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/account/account_model.dart';
import '../providers/account_provider.dart';

class AccountDetailScreen extends ConsumerWidget {
  final int accountId;
  final AccountModel? account;

  const AccountDetailScreen({super.key, required this.accountId, this.account});

  // ─── Helpers ───────────────────────────────────────────────────────────────

  IconData _iconFor(String type) {
    switch (type) {
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

  String _labelFor(String type) {
    switch (type) {
      case 'BANK':
        return 'Banco';
      case 'CASH':
        return 'Efectivo';
      case 'CREDIT_CARD':
        return 'Tarjeta de crédito';
      case 'SAVINGS':
        return 'Ahorro';
      case 'INVESTMENT':
        return 'Inversión';
      default:
        return type;
    }
  }

  // ─── Delete ────────────────────────────────────────────────────────────────

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            backgroundColor: AppTheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Eliminar cuenta'),
            content: const Text(
              '¿Estás seguro? Esta acción no se puede deshacer y se perderá todo el historial asociado.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: AppTheme.error),
                ),
              ),
            ],
          ),
    );

    if (confirm == true && context.mounted) {
      try {
        await ref.read(accountsProvider.notifier).delete(accountId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Cuenta eliminada'),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          context.pop();
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: ${e.toString()}'),
              backgroundColor: AppTheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Intenta obtener datos frescos del provider; usa el objeto pasado como fallback
    final accountsAsync = ref.watch(accountsProvider);
    final current =
        accountsAsync.maybeWhen(
          data: (list) => list.where((a) => a.id == accountId).firstOrNull,
          orElse: () => null,
        ) ??
        account;

    if (current == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle de cuenta')),
        body: const Center(
          child: Text(
            'Cuenta no encontrada',
            style: TextStyle(color: AppTheme.onSurfaceMuted),
          ),
        ),
      );
    }

    final isLiability = current.isLiability;
    final balanceColor = isLiability ? AppTheme.expense : AppTheme.income;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de cuenta'),
        actions: [
          IconButton(
            tooltip: 'Editar',
            icon: const Icon(Icons.edit_outlined),
            onPressed:
                () => context.push(
                  '/accounts/${current.id}/edit',
                  extra: current,
                ),
          ),
          IconButton(
            tooltip: 'Eliminar',
            icon: const Icon(Icons.delete_outline, color: AppTheme.error),
            onPressed: () => _confirmDelete(context, ref),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        children: [
          // ── Balance principal ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    _iconFor(current.accountType),
                    color: AppTheme.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  current.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _labelFor(current.accountType),
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.onSurfaceMuted,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  CurrencyFormatter.format(
                    current.balance,
                    symbol: current.currencySymbol,
                  ),
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: balanceColor,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isLiability ? 'Deuda pendiente' : 'Balance disponible',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.onSurfaceMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Información ───────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.currency_exchange_rounded,
                  label: 'Moneda',
                  value: '${current.currencyCode}  (${current.currencySymbol})',
                ),
                _Divider(),
                _InfoRow(
                  icon: Icons.category_outlined,
                  label: 'Tipo',
                  value: _labelFor(current.accountType),
                ),
                _Divider(),
                _InfoRow(
                  icon: Icons.water_drop_outlined,
                  label: 'Liquidez',
                  value: current.isLiquid ? 'Activo líquido' : 'No líquido',
                  valueColor:
                      current.isLiquid
                          ? AppTheme.income
                          : AppTheme.onSurfaceMuted,
                ),
                _Divider(),
                _InfoRow(
                  icon: Icons.circle_outlined,
                  label: 'Estado',
                  value: current.isActive ? 'Activa' : 'Inactiva',
                  valueColor:
                      current.isActive ? AppTheme.success : AppTheme.error,
                ),
                if (current.createdAt != null) ...[
                  _Divider(),
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Creada',
                    value: _formatDate(current.createdAt!),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ── Acciones ──────────────────────────────────────────────────────
          OutlinedButton.icon(
            onPressed:
                () => context.push(
                  '/accounts/${current.id}/edit',
                  extra: current,
                ),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Editar cuenta'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _confirmDelete(context, ref),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.error,
              side: const BorderSide(color: AppTheme.error),
            ),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Eliminar cuenta'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String raw) {
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year}';
    } catch (_) {
      return raw;
    }
  }
}

// ─── Widgets auxiliares ───────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.onSurfaceMuted),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.onSurfaceMuted,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppTheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: AppTheme.surfaceVariant,
      indent: 16,
      endIndent: 16,
    );
  }
}
