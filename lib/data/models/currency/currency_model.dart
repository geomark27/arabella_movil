class CurrencyModel {
  final int id;
  final String code;
  final String name;
  final String symbol;
  final bool isActive;

  const CurrencyModel({
    required this.id,
    required this.code,
    required this.name,
    required this.symbol,
    required this.isActive,
  });

  factory CurrencyModel.fromJson(Map<String, dynamic> json) => CurrencyModel(
    id: json['id'] as int,
    code: json['code'] as String,
    name: json['name'] as String,
    symbol: json['symbol'] as String,
    isActive: json['is_active'] as bool? ?? true,
  );
}
