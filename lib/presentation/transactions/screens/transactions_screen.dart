import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/transaction/transaction_model.dart';
import '../providers/transaction_provider.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txAsync = ref.watch(transactionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transacciones'),
        actions: [
          IconButton(
            tooltip: 'Nueva transacción',
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.push('/transactions/new'),
          ),
        ],
      ),
      body: txAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppTheme.error, size: 48),
              const SizedBox(height: 12),
              const Text(
                'No se pudo cargar las transacciones',
                style: TextStyle(color: AppTheme.onSurfaceMuted),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(transactionsProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (transactions) {
          if (transactions.isEmpty) {
            return _EmptyState(onAdd: () => context.push('/transactions/new'));
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(transactionsProvider),
            color: AppTheme.primary,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) => _TransactionCard(tx: transactions[i]),
            ),
          );
        },
      ),
    );
  }
}

// ─── Transaction Card ─────────────────────────────────────────────────────────

class _TransactionCard extends ConsumerWidget {
  final TransactionModel tx;
  const _TransactionCard({required this.tx});

  Color get _typeColor {
    switch (tx.type) {
      case 'INCOME':
        return AppTheme.income;
      case 'EXPENSE':
        return AppTheme.expense;
      case 'TRANSFER':
        return AppTheme.primary;
      default:
        return AppTheme.onSurfaceMuted;
    }
  }

  IconData get _typeIcon {
    switch (tx.type) {
      case 'INCOME':
        return Icons.arrow_downward_rounded;
      case 'EXPENSE':
        return Icons.arrow_upward_rounded;
      case 'TRANSFER':
        return Icons.swap_horiz_rounded;
      default:
        return Icons.receipt_rounded;
    }
  }

  String get _amountPrefix => tx.type == 'INCOME' ? '+' : tx.type == 'EXPENSE' ? '-' : '';

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Eliminar transacción'),
        content: Text(
          '¿Eliminar "${tx.description}"?\nEsta acción revertirá los movimientos contables.',
          style: const TextStyle(color: AppTheme.onSurfaceMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(transactionsProvider.notifier).delete(tx.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Transacción eliminada'),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: AppTheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = DateTime.tryParse(tx.transactionDate);
    final dateStr = date != null
        ? DateFormat('dd MMM, HH:mm', 'es').format(date.toLocal())
        : tx.transactionDate;

    final subtitle = tx.type == 'TRANSFER'
        ? '${tx.accountFrom?.name ?? ''} → ${tx.accountTo?.name ?? ''}'
        : [
            if (tx.category != null) tx.category!.name,
            tx.accountFrom?.name ?? '',
          ].join(' · ');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          // ── Ícono tipo ───────────────────────────────────────────────
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _typeColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_typeIcon, color: _typeColor, size: 20),
          ),
          const SizedBox(width: 12),

          // ── Info ─────────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.onSurfaceMuted,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.onSurfaceMuted,
                  ),
                ),
              ],
            ),
          ),

          // ── Monto ────────────────────────────────────────────────────
          Text(
            '$_amountPrefix${tx.amount}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _typeColor,
            ),
          ),
          const SizedBox(width: 4),

          // ── Menú contextual ──────────────────────────────────────────
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded,
                size: 18, color: AppTheme.onSurfaceMuted),
            color: AppTheme.surface,
            onSelected: (action) {
              if (action == 'edit') {
                context.push('/transactions/${tx.id}/edit', extra: tx);
              } else if (action == 'delete') {
                _confirmDelete(context, ref);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded, size: 16),
                    SizedBox(width: 8),
                    Text('Editar'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded,
                        size: 16, color: AppTheme.error),
                    const SizedBox(width: 8),
                    Text('Eliminar',
                        style: TextStyle(color: AppTheme.error)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.receipt_long_outlined,
              size: 64, color: AppTheme.onSurfaceMuted),
          const SizedBox(height: 16),
          const Text(
            'Sin transacciones',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Registra un ingreso, gasto o transferencia.',
            style: TextStyle(fontSize: 14, color: AppTheme.onSurfaceMuted),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Nueva transacción'),
          ),
        ],
      ),
    );
  }
}