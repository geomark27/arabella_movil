import '../currency/currency_model.dart';

class AccountModel {
  final int id;
  final String name;
  final String accountType;
  final String accountTypeLabel;
  final String balance;
  final int currencyId;
  final CurrencyModel? currency;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;

  const AccountModel({
    required this.id,
    required this.name,
    required this.accountType,
    required this.accountTypeLabel,
    required this.balance,
    required this.currencyId,
    this.currency,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) => AccountModel(
    id:               json['id'] as int,
    name:             json['name'] as String,
    accountType:      json['account_type'] as String,
    accountTypeLabel: json['account_type_label'] as String,
    balance:          json['balance']?.toString() ?? '0',
    currencyId:       json['currency_id'] as int,
    currency:
        json['currency'] != null
            ? CurrencyModel.fromJson(json['currency'] as Map<String, dynamic>)
            : null,
    isActive:   json['is_active'] as bool? ?? true,
    createdAt:  json['created_at'] as String?,
    updatedAt:  json['updated_at'] as String?,
  );

  String get currencySymbol => currency?.symbol ?? '\$';
  String get currencyCode => currency?.code ?? 'USD';

  bool get isLiquid => accountType == 'BANK' || accountType == 'CASH';

  bool get isLiability => accountType == 'CREDIT_CARD';
}

class CreateAccountRequest {
  final String name;
  final String accountType;
  final int currencyId;
  final String? balance;
  final bool? isActive;

  const CreateAccountRequest({
    required this.name,
    required this.accountType,
    required this.currencyId,
    this.balance,
    this.isActive,
  });

  Map<String, dynamic> toJson() => {
    'name':         name,
    'account_type': accountType,
    'currency_id':  currencyId,
    if (balance != null) 'balance': balance,
    if (isActive != null) 'is_active': isActive,
  };
}

class UpdateAccountRequest {
  final String? name;
  final String? accountType;
  final int? currencyId;
  final String? balance;
  final bool? isActive;

  const UpdateAccountRequest({
    this.name,
    this.accountType,
    this.currencyId,
    this.balance,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (accountType != null) map['account_type'] = accountType;
    if (currencyId != null) map['currency_id'] = currencyId;
    if (balance != null) map['balance'] = balance;
    if (isActive != null) map['is_active'] = isActive;
    return map;
  }
}
