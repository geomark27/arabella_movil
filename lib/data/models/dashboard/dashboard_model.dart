class AccountBalanceSummary {
  final int id;
  final String name;
  final String type;
  final String balance;
  final String currencyCode;
  final String currencySymbol;
  final bool isActive;

  const AccountBalanceSummary({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.currencyCode,
    required this.currencySymbol,
    required this.isActive,
  });

  factory AccountBalanceSummary.fromJson(Map<String, dynamic> json) =>
      AccountBalanceSummary(
        id: json['id'] as int,
        name: json['name'] as String,
        type: json['type'] as String,
        balance: json['balance']?.toString() ?? '0',
        currencyCode: json['currency_code'] as String? ?? 'USD',
        currencySymbol: json['currency_symbol'] as String? ?? '\$',
        isActive: json['is_active'] as bool? ?? true,
      );
}

class DashboardModel {
  final String totalAssets;
  final String totalLiabilities;
  final String netWorth;
  final String liquidAssets;
  final String monthlyIncome;
  final String monthlyExpenses;
  final String monthlyNetCashFlow;
  final double runway;
  final int runwayDays;
  final String averageMonthlyExpenses;
  final List<AccountBalanceSummary> accountBalances;
  final String asOf;
  final String baseCurrency;

  const DashboardModel({
    required this.totalAssets,
    required this.totalLiabilities,
    required this.netWorth,
    required this.liquidAssets,
    required this.monthlyIncome,
    required this.monthlyExpenses,
    required this.monthlyNetCashFlow,
    required this.runway,
    required this.runwayDays,
    required this.averageMonthlyExpenses,
    required this.accountBalances,
    required this.asOf,
    required this.baseCurrency,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) => DashboardModel(
    totalAssets: json['total_assets']?.toString() ?? '0',
    totalLiabilities: json['total_liabilities']?.toString() ?? '0',
    netWorth: json['net_worth']?.toString() ?? '0',
    liquidAssets: json['liquid_assets']?.toString() ?? '0',
    monthlyIncome: json['monthly_income']?.toString() ?? '0',
    monthlyExpenses: json['monthly_expenses']?.toString() ?? '0',
    monthlyNetCashFlow: json['monthly_net_cash_flow']?.toString() ?? '0',
    runway: (json['runway'] as num?)?.toDouble() ?? 0.0,
    runwayDays: json['runway_days'] as int? ?? 0,
    averageMonthlyExpenses: json['average_monthly_expenses']?.toString() ?? '0',
    accountBalances:
        (json['account_balances'] as List<dynamic>?)
            ?.map(
              (e) => AccountBalanceSummary.fromJson(e as Map<String, dynamic>),
            )
            .toList() ??
        [],
    asOf: json['as_of'] as String? ?? '',
    baseCurrency: json['base_currency'] as String? ?? 'USD',
  );
}

// ─── Runway Model ─────────────────────────────────────────────────────────────

class RunwayModel {
  final String liquidAssets;
  final String shortTermLiabilities;
  final String availableFunds;
  final String averageMonthlyExpenses;
  final double runwayMonths;
  final int runwayDays;
  final String calculationDate;
  final String baseCurrency;
  final List<AccountBalanceSummary> bankAccounts;
  final List<AccountBalanceSummary> cashAccounts;
  final List<AccountBalanceSummary> creditCardAccounts;
  final String status; // HEALTHY | WARNING | CRITICAL
  final String message;

  const RunwayModel({
    required this.liquidAssets,
    required this.shortTermLiabilities,
    required this.availableFunds,
    required this.averageMonthlyExpenses,
    required this.runwayMonths,
    required this.runwayDays,
    required this.calculationDate,
    required this.baseCurrency,
    required this.bankAccounts,
    required this.cashAccounts,
    required this.creditCardAccounts,
    required this.status,
    required this.message,
  });

  factory RunwayModel.fromJson(Map<String, dynamic> json) => RunwayModel(
    liquidAssets: json['liquid_assets']?.toString() ?? '0',
    shortTermLiabilities: json['short_term_liabilities']?.toString() ?? '0',
    availableFunds: json['available_funds']?.toString() ?? '0',
    averageMonthlyExpenses: json['average_monthly_expenses']?.toString() ?? '0',
    runwayMonths: (json['runway_months'] as num?)?.toDouble() ?? 0.0,
    runwayDays: json['runway_days'] as int? ?? 0,
    calculationDate: json['calculation_date'] as String? ?? '',
    baseCurrency: json['base_currency'] as String? ?? 'USD',
    bankAccounts:
        (json['bank_accounts'] as List<dynamic>?)
            ?.map(
              (e) => AccountBalanceSummary.fromJson(e as Map<String, dynamic>),
            )
            .toList() ??
        [],
    cashAccounts:
        (json['cash_accounts'] as List<dynamic>?)
            ?.map(
              (e) => AccountBalanceSummary.fromJson(e as Map<String, dynamic>),
            )
            .toList() ??
        [],
    creditCardAccounts:
        (json['credit_card_accounts'] as List<dynamic>?)
            ?.map(
              (e) => AccountBalanceSummary.fromJson(e as Map<String, dynamic>),
            )
            .toList() ??
        [],
    status: json['status'] as String? ?? 'CRITICAL',
    message: json['message'] as String? ?? '',
  );
}

// ─── Monthly Stats Model ──────────────────────────────────────────────────────

class MonthlyStatsModel {
  final int month;
  final int year;
  final String income;
  final String expenses;
  final String netCashFlow;
  final int transactionCount;

  const MonthlyStatsModel({
    required this.month,
    required this.year,
    required this.income,
    required this.expenses,
    required this.netCashFlow,
    required this.transactionCount,
  });

  factory MonthlyStatsModel.fromJson(Map<String, dynamic> json) =>
      MonthlyStatsModel(
        month: json['month'] as int? ?? 0,
        year: json['year'] as int? ?? 0,
        income: json['income']?.toString() ?? '0',
        expenses: json['expenses']?.toString() ?? '0',
        netCashFlow: json['net_cash_flow']?.toString() ?? '0',
        transactionCount: json['transaction_count'] as int? ?? 0,
      );
}
