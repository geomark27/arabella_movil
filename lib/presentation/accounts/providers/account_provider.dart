import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/account/account_model.dart';
import '../../../data/repositories/account_repository.dart';

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepository();
});

final accountsProvider = FutureProvider.autoDispose<List<AccountModel>>((
  ref,
) async {
  return ref.read(accountRepositoryProvider).getAccounts();
});
