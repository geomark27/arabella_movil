import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/account/account_model.dart';
import '../../../data/models/category/category_model.dart';
import '../../../data/models/transaction/transaction_model.dart';
import '../../accounts/providers/account_provider.dart';
import '../providers/transaction_provider.dart';

// ─── Íconos y colores por tipo de transacción ─────────────────────────────────

IconData _iconForType(String value) {
  switch (value) {
    case 'INCOME':
      return Icons.add_circle_outline_rounded;
    case 'EXPENSE':
      return Icons.remove_circle_outline_rounded;
    case 'TRANSFER':
      return Icons.swap_horiz_rounded;
    default:
      return Icons.receipt_long_rounded;
  }
}

Color _colorForType(String value) {
  switch (value) {
    case 'INCOME':
      return AppTheme.income;
    case 'EXPENSE':
      return AppTheme.expense;
    case 'TRANSFER':
      return AppTheme.primary;
    default:
      return AppTheme.primary;
  }
}

String _labelForType(String value) {
  switch (value) {
    case 'INCOME':
      return 'Ingreso';
    case 'EXPENSE':
      return 'Gasto';
    case 'TRANSFER':
      return 'Transferencia';
    default:
      return value;
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class TransactionFormScreen extends ConsumerStatefulWidget {
  /// null = modo creación · non-null = modo edición
  final TransactionModel? transaction;

  const TransactionFormScreen({super.key, this.transaction});

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState
    extends ConsumerState<TransactionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _notesController;
  late final TextEditingController _exchangeRateController;

  String _selectedType = 'EXPENSE';
  int? _selectedAccountFromId;
  int? _selectedAccountToId;
  int? _selectedCategoryId;
  late DateTime _selectedDate;
  bool _isSubmitting = false;

  static const _types = ['INCOME', 'EXPENSE', 'TRANSFER'];

  bool get _isEditing => widget.transaction != null;
  bool get _needsCategory =>
      _selectedType == 'INCOME' || _selectedType == 'EXPENSE';
  bool get _needsAccountTo => _selectedType == 'TRANSFER';

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;
    _amountController = TextEditingController(text: t?.amount ?? '');
    _descriptionController = TextEditingController(
      text: t?.description ?? '',
    );
    _notesController = TextEditingController(text: t?.notes ?? '');
    _exchangeRateController = TextEditingController(
      text: t?.exchangeRate ?? '1',
    );
    _selectedType = t?.type ?? 'EXPENSE';
    _selectedAccountFromId = t?.accountFrom?.id;
    _selectedAccountToId = t?.accountTo?.id;
    _selectedCategoryId = t?.category?.id;
    _selectedDate =
        t != null ? _parseDate(t.transactionDate) : DateTime.now();
  }

  DateTime _parseDate(String raw) {
    try {
      return DateTime.parse(raw).toLocal();
    } catch (_) {
      return DateTime.now();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    _exchangeRateController.dispose();
    super.dispose();
  }

  // ─── Submit ───────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedAccountFromId == null) {
      _showSnack('Selecciona una cuenta de origen', isError: true);
      return;
    }
    if (_needsAccountTo && _selectedAccountToId == null) {
      _showSnack('Selecciona una cuenta de destino', isError: true);
      return;
    }
    if (_selectedAccountToId != null &&
        _selectedAccountFromId == _selectedAccountToId) {
      _showSnack('Las cuentas de origen y destino deben ser distintas',
          isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final notifier = ref.read(transactionsProvider.notifier);
      final dateIso = _selectedDate.toUtc().toIso8601String();
      final exchangeRate = _exchangeRateController.text.trim().isEmpty
          ? '1'
          : _exchangeRateController.text.trim();

      if (_isEditing) {
        await notifier.editTransaction(
          widget.transaction!.id,
          UpdateTransactionRequest(
            description: _descriptionController.text.trim(),
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
            transactionDate: dateIso,
          ),
        );
      } else {
        await notifier.create(
          CreateTransactionRequest(
            type: _selectedType,
            description: _descriptionController.text.trim(),
            amount: _amountController.text.trim(),
            accountFromId: _selectedAccountFromId!,
            accountToId: _needsAccountTo ? _selectedAccountToId : null,
            categoryId: _needsCategory ? _selectedCategoryId : null,
            transactionDate: dateIso,
            notes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
            exchangeRate: exchangeRate == '1' ? null : exchangeRate,
          ),
        );
      }

      if (mounted) {
        _showSnack(
          _isEditing
              ? 'Transacción actualizada'
              : 'Transacción creada correctamente',
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) _showSnack('Error: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppTheme.error : AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ─── Date picker ──────────────────────────────────────────────────────────

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppTheme.primary,
            surface: AppTheme.surface,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar transacción' : 'Nueva transacción'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            // ── Tipo de transacción (solo en creación) ────────────────────
            if (!_isEditing) ...[
              const _SectionLabel(label: 'Tipo'),
              const SizedBox(height: 10),
              Row(
                children: _types.map((type) {
                  final isSelected = _selectedType == type;
                  final color = _colorForType(type);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _selectedType = type;
                          // Limpiar selecciones dependientes del tipo
                          _selectedCategoryId = null;
                          _selectedAccountToId = null;
                        }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withOpacity(0.15)
                                : AppTheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  isSelected ? color : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _iconForType(type),
                                color: isSelected
                                    ? color
                                    : AppTheme.onSurfaceMuted,
                                size: 22,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _labelForType(type),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? color
                                      : AppTheme.onSurfaceMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // ── Monto (solo en creación) ───────────────────────────────────
            if (!_isEditing) ...[
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d*\.?\d*'),
                  ),
                ],
                decoration: InputDecoration(
                  labelText: 'Monto',
                  prefixIcon: Icon(
                    _iconForType(_selectedType),
                    color: _colorForType(_selectedType),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Ingresa el monto';
                  }
                  final parsed = double.tryParse(v.trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Ingresa un monto válido mayor a 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
            ],

            // ── Descripción ───────────────────────────────────────────────
            TextFormField(
              controller: _descriptionController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Ingresa una descripción';
                }
                if (v.trim().length < 2) return 'Mínimo 2 caracteres';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // ── Fecha ─────────────────────────────────────────────────────
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      color: AppTheme.onSurfaceMuted,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        DateFormat('dd MMM yyyy', 'es').format(_selectedDate),
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppTheme.onSurface,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppTheme.onSurfaceMuted,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Cuenta origen ─────────────────────────────────────────────
            const _SectionLabel(label: 'Cuenta de origen'),
            const SizedBox(height: 10),
            accountsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => const Text('Error cargando cuentas',
                  style: TextStyle(color: AppTheme.error)),
              data: (accounts) => _buildAccountDropdown(
                accounts: accounts,
                value: _selectedAccountFromId,
                hint: 'Selecciona una cuenta',
                onChanged: (v) =>
                    setState(() => _selectedAccountFromId = v),
              ),
            ),
            const SizedBox(height: 16),

            // ── Cuenta destino (solo TRANSFER) ────────────────────────────
            if (_needsAccountTo) ...[
              const _SectionLabel(label: 'Cuenta de destino'),
              const SizedBox(height: 10),
              accountsAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (_, __) => const Text('Error cargando cuentas',
                    style: TextStyle(color: AppTheme.error)),
                data: (accounts) {
                  // Excluir la cuenta de origen de las opciones de destino
                  final filtered = accounts
                      .where((a) => a.id != _selectedAccountFromId)
                      .toList();
                  return _buildAccountDropdown(
                    accounts: filtered,
                    value: _selectedAccountToId,
                    hint: 'Selecciona cuenta destino',
                    onChanged: (v) =>
                        setState(() => _selectedAccountToId = v),
                  );
                },
              ),
              const SizedBox(height: 16),
            ],

            // ── Categoría (INCOME / EXPENSE) ──────────────────────────────
            if (_needsCategory && !_isEditing) ...[
              const _SectionLabel(label: 'Categoría (opcional)'),
              const SizedBox(height: 10),
              Consumer(
                builder: (context, ref, _) {
                  final catsAsync =
                      ref.watch(categoriesByTypeProvider(_selectedType));
                  return catsAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const Text('Error cargando categorías',
                        style: TextStyle(color: AppTheme.error)),
                    data: (cats) {
                      if (cats.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Sin categorías para este tipo. Crea una en la sección de Categorías.',
                            style: const TextStyle(
                              color: AppTheme.onSurfaceMuted,
                              fontSize: 13,
                            ),
                          ),
                        );
                      }
                      return _buildCategoryDropdown(cats);
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
            ],

            // ── Tasa de cambio (solo en creación, opcional) ───────────────
            if (!_isEditing) ...[
              TextFormField(
                controller: _exchangeRateController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Tasa de cambio (opcional)',
                  prefixIcon: Icon(Icons.currency_exchange_rounded),
                  helperText: 'Deja en 1 si es en tu moneda base',
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ── Notas ─────────────────────────────────────────────────────
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Notas (opcional)',
                prefixIcon: Icon(Icons.edit_note_rounded),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32),

            // ── Botón submit ──────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isEditing
                      ? AppTheme.primary
                      : _colorForType(_selectedType),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        _isEditing
                            ? 'Guardar cambios'
                            : 'Registrar ${_labelForType(_selectedType).toLowerCase()}',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Helpers de UI ────────────────────────────────────────────────────────

  Widget _buildAccountDropdown({
    required List<AccountModel> accounts,
    required int? value,
    required String hint,
    required ValueChanged<int?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          hint: Text(hint,
              style: const TextStyle(color: AppTheme.onSurfaceMuted)),
          isExpanded: true,
          dropdownColor: AppTheme.surface,
          style: const TextStyle(color: AppTheme.onSurface, fontSize: 15),
          items: accounts
              .map(
                (a) => DropdownMenuItem(
                  value: a.id,
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet_rounded,
                          size: 16, color: AppTheme.onSurfaceMuted),
                      const SizedBox(width: 8),
                      Expanded(child: Text(a.name)),
                      Text(
                        a.balance,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.onSurfaceMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown(List<CategoryModel> cats) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedCategoryId,
          hint: const Text('Sin categoría',
              style: TextStyle(color: AppTheme.onSurfaceMuted)),
          isExpanded: true,
          dropdownColor: AppTheme.surface,
          style: const TextStyle(color: AppTheme.onSurface, fontSize: 15),
          items: [
            const DropdownMenuItem<int>(
              value: null,
              child: Text('Sin categoría',
                  style: TextStyle(color: AppTheme.onSurfaceMuted)),
            ),
            ...cats.map(
              (c) => DropdownMenuItem(
                value: c.id,
                child: Text(c.name),
              ),
            ),
          ],
          onChanged: (v) => setState(() => _selectedCategoryId = v),
        ),
      ),
    );
  }
}

// ─── Widget auxiliar ──────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppTheme.onSurfaceMuted,
      ),
    );
  }
}