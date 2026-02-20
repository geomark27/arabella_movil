/// Modelo que representa un valor del catálogo del sistema.
/// Mapea directamente al struct SystemValue del backend Go.
class SystemValueModel {
  final int id;
  final String catalogType;
  final String value;
  final String label;
  final String? description;
  final int displayOrder;
  final bool isActive;

  const SystemValueModel({
    required this.id,
    required this.catalogType,
    required this.value,
    required this.label,
    this.description,
    required this.displayOrder,
    required this.isActive,
  });

  factory SystemValueModel.fromJson(Map<String, dynamic> json) =>
      SystemValueModel(
        id: json['id'] as int,
        catalogType: json['catalog_type'] as String,
        value: json['value'] as String,
        label: json['label'] as String,
        description: json['description'] as String?,
        displayOrder: json['display_order'] as int? ?? 0,
        isActive: json['is_active'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'catalog_type': catalogType,
    'value': value,
    'label': label,
    if (description != null) 'description': description,
    'display_order': displayOrder,
    'is_active': isActive,
  };

  @override
  String toString() => 'SystemValueModel($catalogType.$value — $label)';
}

/// Tipos de catálogo disponibles en el backend
class CatalogType {
  CatalogType._();

  static const String accountType = 'ACCOUNT_TYPE';
  static const String accountClassification = 'ACCOUNT_CLASSIFICATION';
  static const String transactionType = 'TRANSACTION_TYPE';
  static const String categoryType = 'CATEGORY_TYPE';
  static const String journalEntryType = 'JOURNAL_ENTRY_TYPE';
}
