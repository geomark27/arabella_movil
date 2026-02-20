import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_formatter.dart';
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
            icon: const Icon(Icons.add_rounded),
            onPressed: () {
              // TODO: Navegar a crear transacción
            },
          ),
        ],
      ),
      body: txAsync.when(
        loading:
            () => const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            ),
        error:
            (err, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppTheme.error,
                    size: 48,
                  ),
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
        data: (response) {
          if (response.transactions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: AppTheme.onSurfaceMuted,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Sin transacciones',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Registra un ingreso, gasto o transferencia.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.onSurfaceMuted,
                    ),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(transactionsProvider),
            color: AppTheme.primary,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: response.transactions.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder:
                  (ctx, i) => _TransactionCard(tx: response.transactions[i]),
            ),
          );
        },
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final TransactionModel tx;

  const _TransactionCard({required this.tx});

  Color get _typeColor {
    switch (tx.type) {
      case 'INCOME':
        return AppTheme.income;
      case 'EXPENSE':
        return AppTheme.expense;
      case 'TRANSFER':
        return AppTheme.transfer;
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

  String get _sign => tx.type == 'INCOME' ? '+' : '-';

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(tx.transactionDate);
    final dateStr =
        date != null
            ? DateFormat('dd MMM, HH:mm', 'es').format(date)
            : tx.transactionDate;

    return Container(
      padding: const EdgeInsets.all(14),
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
            child: Icon(_typeIcon, color: _typeColor, size: 20),
          ),
          const SizedBox(width: 12),
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
                Text(
                  '${tx.category?.name ?? tx.type} · $dateStr',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.onSurfaceMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$_sign${CurrencyFormatter.format(tx.amount, symbol: tx.accountFrom?.currencySymbol ?? '\$')}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _typeColor,
            ),
          ),
        ],
      ),
    );
  }
}
