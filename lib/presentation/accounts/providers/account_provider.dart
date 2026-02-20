import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/account/account_model.dart';
import '../../../data/models/currency/currency_model.dart';
import '../../../data/repositories/account_repository.dart';
import '../../../data/repositories/currency_repository.dart';

// ─── Repositories ────────────────────────────────────────────────────────────

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepository();
});

final currencyRepositoryProvider = Provider<CurrencyRepository>((ref) {
  return CurrencyRepository();
});

// ─── Currencies (para el formulario) ─────────────────────────────────────────

final currenciesProvider = FutureProvider.autoDispose<List<CurrencyModel>>((
  ref,
) async {
  return ref.read(currencyRepositoryProvider).getCurrencies();
});

// ─── Accounts AsyncNotifier ───────────────────────────────────────────────────

class AccountsNotifier extends AsyncNotifier<List<AccountModel>> {
  @override
  Future<List<AccountModel>> build() async {
    return ref.read(accountRepositoryProvider).getAccounts();
  }

  Future<void> create(CreateAccountRequest request) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(accountRepositoryProvider).createAccount(request);
      return ref.read(accountRepositoryProvider).getAccounts();
    });
  }

  Future<void> editAccount(int id, UpdateAccountRequest request) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(accountRepositoryProvider).updateAccount(id, request);
      return ref.read(accountRepositoryProvider).getAccounts();
    });
  }

  Future<void> delete(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(accountRepositoryProvider).deleteAccount(id);
      return ref.read(accountRepositoryProvider).getAccounts();
    });
  }
}

final accountsProvider =
    AsyncNotifierProvider<AccountsNotifier, List<AccountModel>>(
      AccountsNotifier.new,
    );
