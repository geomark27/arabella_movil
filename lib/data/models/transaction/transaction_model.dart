import '../category/category_model.dart';

class TransactionAccount {
  final int id;
  final String name;
  final String type;
  final String? balance;
  final Map<String, dynamic>? currency;

  const TransactionAccount({
    required this.id,
    required this.name,
    required this.type,
    this.balance,
    this.currency,
  });

  factory TransactionAccount.fromJson(Map<String, dynamic> json) =>
      TransactionAccount(
        id: json['id'] as int,
        name: json['name'] as String,
        type: json['type'] as String,
        balance: json['balance']?.toString(),
        currency: json['currency'] as Map<String, dynamic>?,
      );

  String get currencySymbol => currency?['symbol'] as String? ?? '\$';
}

class TransactionModel {
  final int id;
  final int userId;
  final String type; // INCOME | EXPENSE | TRANSFER
  final String description;
  final String amount;
  final String? amountInUsd;
  final String? exchangeRate;
  final String transactionDate;
  final String? notes;
  final bool isReconciled;
  final String? createdAt;
  final String? updatedAt;
  final TransactionAccount? accountFrom;
  final TransactionAccount? accountTo;
  final CategoryModel? category;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.description,
    required this.amount,
    this.amountInUsd,
    this.exchangeRate,
    required this.transactionDate,
    this.notes,
    required this.isReconciled,
    this.createdAt,
    this.updatedAt,
    this.accountFrom,
    this.accountTo,
    this.category,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        id: json['id'] as int,
        userId: json['user_id'] as int? ?? 0,
        type: json['type'] as String,
        description: json['description'] as String,
        amount: json['amount']?.toString() ?? '0',
        amountInUsd: json['amount_in_usd']?.toString(),
        exchangeRate: json['exchange_rate']?.toString(),
        transactionDate: json['transaction_date'] as String,
        notes: json['notes'] as String?,
        isReconciled: json['is_reconciled'] as bool? ?? false,
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
        accountFrom:
            json['account_from'] != null
                ? TransactionAccount.fromJson(
                  json['account_from'] as Map<String, dynamic>,
                )
                : null,
        accountTo:
            json['account_to'] != null
                ? TransactionAccount.fromJson(
                  json['account_to'] as Map<String, dynamic>,
                )
                : null,
        category:
            json['category'] != null
                ? CategoryModel.fromJson(
                  json['category'] as Map<String, dynamic>,
                )
                : null,
      );
}

class TransactionListResponse {
  final List<TransactionModel> transactions;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  const TransactionListResponse({
    required this.transactions,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory TransactionListResponse.fromJson(Map<String, dynamic> json) =>
      TransactionListResponse(
        transactions:
            (json['transactions'] as List<dynamic>?)
                ?.map(
                  (e) => TransactionModel.fromJson(e as Map<String, dynamic>),
                )
                .toList() ??
            [],
        total: json['total'] as int? ?? 0,
        page: json['page'] as int? ?? 1,
        pageSize: json['page_size'] as int? ?? 20,
        totalPages: json['total_pages'] as int? ?? 1,
      );
}

class CreateTransactionRequest {
  final String type;
  final String description;
  final String amount;
  final int accountFromId;
  final int? accountToId;
  final int? categoryId;
  final String transactionDate;
  final String? notes;
  final String? exchangeRate;

  const CreateTransactionRequest({
    required this.type,
    required this.description,
    required this.amount,
    required this.accountFromId,
    this.accountToId,
    this.categoryId,
    required this.transactionDate,
    this.notes,
    this.exchangeRate,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'description': description,
    'amount': amount,
    'account_from_id': accountFromId,
    if (accountToId != null) 'account_to_id': accountToId,
    if (categoryId != null) 'category_id': categoryId,
    'transaction_date': transactionDate,
    if (notes != null && notes!.isNotEmpty) 'notes': notes,
    if (exchangeRate != null) 'exchange_rate': exchangeRate,
  };
}

class UpdateTransactionRequest {
  final String? description;
  final String? notes;
  final String? transactionDate;
  final bool? isReconciled;

  const UpdateTransactionRequest({
    this.description,
    this.notes,
    this.transactionDate,
    this.isReconciled,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (description != null) map['description'] = description;
    if (notes != null) map['notes'] = notes;
    if (transactionDate != null) map['transaction_date'] = transactionDate;
    if (isReconciled != null) map['is_reconciled'] = isReconciled;
    return map;
  }
}
