import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/account/account_model.dart';
import '../../../data/models/system_value/system_value_model.dart';
import '../../../data/providers/system_value_provider.dart';
import '../providers/account_provider.dart';

// ─── Mapeo local de íconos por value del catálogo ─────────────────────────────
// El label y el value vienen del backend; el ícono se asigna aquí en el cliente.

IconData _iconForAccountType(String value) {
  switch (value) {
    case 'BANK':
      return Icons.account_balance_rounded;
    case 'CASH':
      return Icons.payments_rounded;
    case 'CREDIT_CARD':
      return Icons.credit_card_rounded;
    case 'SAVINGS':
      return Icons.savings_rounded;
    case 'INVESTMENT':
      return Icons.show_chart_rounded;
    default:
      return Icons.account_balance_wallet_rounded;
  }
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class AccountFormScreen extends ConsumerStatefulWidget {
  /// null = modo creación · non-null = modo edición
  final AccountModel? account;

  const AccountFormScreen({super.key, this.account});

  @override
  ConsumerState<AccountFormScreen> createState() => _AccountFormScreenState();
}

class _AccountFormScreenState extends ConsumerState<AccountFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;
  String? _selectedType;
  int? _selectedCurrencyId;
  late bool _isActive;
  bool _isSubmitting = false;

  bool get _isEditing => widget.account != null;

  @override
  void initState() {
    super.initState();
    final a = widget.account;
    _nameController = TextEditingController(text: a?.name ?? '');
    _balanceController = TextEditingController(
      text: _isEditing ? a!.balance : '0',
    );
    _selectedType = a?.accountType;
    _selectedCurrencyId = a?.currencyId;
    _isActive = a?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  // ─── Submit ───────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedType == null) {
      _showSnack('Selecciona un tipo de cuenta', isError: true);
      return;
    }
    if (_selectedCurrencyId == null) {
      _showSnack('Selecciona una moneda', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final notifier = ref.read(accountsProvider.notifier);

      if (_isEditing) {
        await notifier.editAccount(
          widget.account!.id,
          UpdateAccountRequest(
            name: _nameController.text.trim(),
            accountType: _selectedType,
            currencyId: _selectedCurrencyId,
            isActive: _isActive,
          ),
        );
      } else {
        await notifier.create(
          CreateAccountRequest(
            name: _nameController.text.trim(),
            accountType: _selectedType!,
            currencyId: _selectedCurrencyId!,
            balance: _balanceController.text.trim(),
          ),
        );
      }

      if (mounted) {
        _showSnack(
          _isEditing
              ? 'Cuenta actualizada correctamente'
              : 'Cuenta creada correctamente',
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

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final accountTypesAsync = ref.watch(
      catalogProvider(CatalogType.accountType),
    );
    final currenciesAsync = ref.watch(currenciesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar cuenta' : 'Nueva cuenta'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          children: [
            // ── Nombre ───────────────────────────────────────────────────────
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Nombre de la cuenta',
                prefixIcon: Icon(Icons.label_outline),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Ingresa un nombre para la cuenta';
                }
                if (v.trim().length < 2) return 'Mínimo 2 caracteres';
                return null;
              },
            ),
            const SizedBox(height: 24),

            // ── Tipo de cuenta (dinámico desde backend) ───────────────────────
            _SectionLabel(label: 'Tipo de cuenta'),
            const SizedBox(height: 10),
            accountTypesAsync.when(
              loading:
                  () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: LinearProgressIndicator(),
                  ),
              error:
                  (_, __) => OutlinedButton.icon(
                    onPressed:
                        () => ref.invalidate(
                          catalogProvider(CatalogType.accountType),
                        ),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar cargar tipos de cuenta'),
                  ),
              data:
                  (types) => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        types.map((type) => _buildTypeChip(type)).toList(),
                  ),
            ),
            const SizedBox(height: 24),

            // ── Moneda ────────────────────────────────────────────────────────
            currenciesAsync.when(
              loading:
                  () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: LinearProgressIndicator(),
                  ),
              error:
                  (_, __) => OutlinedButton.icon(
                    onPressed: () => ref.invalidate(currenciesProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar cargar monedas'),
                  ),
              data:
                  (currencies) => DropdownButtonFormField<int>(
                    value: _selectedCurrencyId,
                    decoration: const InputDecoration(
                      labelText: 'Moneda',
                      prefixIcon: Icon(Icons.currency_exchange_rounded),
                    ),
                    dropdownColor: AppTheme.surface,
                    isExpanded: true,
                    items:
                        currencies
                            .map(
                              (c) => DropdownMenuItem(
                                value: c.id,
                                child: Row(
                                  children: [
                                    Text(
                                      c.code,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        c.name,
                                        style: const TextStyle(fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                    onChanged: (v) => setState(() => _selectedCurrencyId = v),
                    validator:
                        (v) => v == null ? 'Selecciona una moneda' : null,
                  ),
            ),
            const SizedBox(height: 24),

            // ── Balance inicial (solo creación) ───────────────────────────────
            if (!_isEditing) ...[
              TextFormField(
                controller: _balanceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Balance inicial',
                  prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                  hintText: '0.00',
                ),
                validator: (v) {
                  if (v != null && v.isNotEmpty) {
                    if (double.tryParse(v) == null) {
                      return 'Ingresa un número válido';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
            ],

            // ── Cuenta activa (solo edición) ──────────────────────────────────
            if (_isEditing) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.toggle_on_outlined,
                      color: AppTheme.onSurfaceMuted,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Cuenta activa',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppTheme.onSurface,
                        ),
                      ),
                    ),
                    Switch(
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                      activeColor: AppTheme.primary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ── Botón guardar ─────────────────────────────────────────────────
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              child:
                  _isSubmitting
                      ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                      : Text(_isEditing ? 'Guardar cambios' : 'Crear cuenta'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── ChoiceChip por tipo de cuenta ────────────────────────────────────────

  Widget _buildTypeChip(SystemValueModel type) {
    final isSelected = _selectedType == type.value;
    return ChoiceChip(
      avatar: Icon(
        _iconForAccountType(type.value),
        size: 16,
        color: isSelected ? Colors.white : AppTheme.onSurfaceMuted,
      ),
      label: Text(type.label),
      selected: isSelected,
      selectedColor: AppTheme.primary,
      backgroundColor: AppTheme.surfaceVariant,
      labelStyle: TextStyle(
        fontSize: 13,
        color: isSelected ? Colors.white : AppTheme.onSurface,
      ),
      tooltip: type.description,
      onSelected: (_) => setState(() => _selectedType = type.value),
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
