import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._();

  /// Lee API_BASE_URL desde el archivo .env.
  /// Si no está definido, usa un fallback según la plataforma:
  ///   - Android  → 10.0.2.2  (alias del host en el emulador)
  ///   - iOS/Mac  → localhost
  ///   - Otros    → localhost
  static String get baseUrl =>
      dotenv.maybeGet('API_BASE_URL') ?? _platformDefaultUrl;

  static String get _platformDefaultUrl {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080/api/v1';
    }
    return 'http://localhost:8080/api/v1';
  }

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String changePassword = '/auth/change-password';

  // Users
  static const String users = '/users';

  // Accounts
  static const String accounts = '/accounts';

  // Transactions
  static const String transactions = '/transactions';

  // Categories
  static const String categories = '/categories';

  // Dashboard
  static const String dashboard = '/dashboard';
  static const String dashboardRunway = '/dashboard/runway';
  static const String dashboardMonthlyStats = '/dashboard/monthly-stats';

  // Currencies
  static const String currencies = '/currencies';

  // System Values
  static const String systemValuesCatalog = '/system-values/catalog';
  static const String accountTypes = '/system-values/account-types';
  static const String accountClassifications =
      '/system-values/account-classifications';
  static const String transactionTypes = '/system-values/transaction-types';
  static const String categoryTypes = '/system-values/category-types';

  /// Construye la ruta dinámica del catálogo: /system-values/catalog/{catalogType}
  static String systemValuesCatalogByType(String catalogType) =>
      '$systemValuesCatalog/$catalogType';

  // Journal Entries
  static const String journalEntries = '/journal-entries';
}
