import 'package:arabella_movil/data/models/category/category_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/transaction/transaction_model.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../categories/providers/category_provider.dart';

// ─── Repository provider ──────────────────────────────────────────────────────

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

// ─── Transactions AsyncNotifier ───────────────────────────────────────────────

class TransactionsNotifier extends AsyncNotifier<List<TransactionModel>> {
  @override
  Future<List<TransactionModel>> build() async {
    final response = await ref
        .read(transactionRepositoryProvider)
        .getTransactions(pageSize: 50);
    return response.transactions;
  }

  Future<void> create(CreateTransactionRequest request) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(transactionRepositoryProvider).createTransaction(request);
      // Invalidar dashboard para que el Runway se recalcule
      ref.invalidateSelf();
      final response = await ref
          .read(transactionRepositoryProvider)
          .getTransactions(pageSize: 50);
      return response.transactions;
    });
  }

  Future<void> editTransaction(int id, UpdateTransactionRequest request) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(transactionRepositoryProvider)
          .updateTransaction(id, request);
      final response = await ref
          .read(transactionRepositoryProvider)
          .getTransactions(pageSize: 50);
      return response.transactions;
    });
  }

  Future<void> delete(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(transactionRepositoryProvider).deleteTransaction(id);
      final response = await ref
          .read(transactionRepositoryProvider)
          .getTransactions(pageSize: 50);
      return response.transactions;
    });
  }
}

final transactionsProvider =
    AsyncNotifierProvider<TransactionsNotifier, List<TransactionModel>>(
      TransactionsNotifier.new,
    );

// ─── Provider de categorías filtrado por tipo (para el form) ─────────────────
// Usa el categoriesProvider existente y filtra client-side

final categoriesByTypeProvider =
    Provider.family<AsyncValue<List<CategoryModel>>, String>((ref, type) {
      return ref
          .watch(categoriesProvider)
          .whenData(
            (cats) => cats.where((c) => c.type == type && c.isActive).toList(),
          );
    });
