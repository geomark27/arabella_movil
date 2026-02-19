import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/transaction/transaction_model.dart';
import '../../../data/repositories/transaction_repository.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository();
});

final transactionsProvider =
    FutureProvider.autoDispose<TransactionListResponse>((ref) async {
      return ref.read(transactionRepositoryProvider).getTransactions();
    });
