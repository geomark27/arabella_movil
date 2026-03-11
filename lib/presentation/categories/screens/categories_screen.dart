import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/category/category_model.dart';
import '../providers/category_provider.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Categorías'),
          actions: [
            IconButton(
              tooltip: 'Nueva categoría',
              icon: const Icon(Icons.add_rounded),
              onPressed: () => _showCategoryForm(context, ref, type: 'EXPENSE'),
            ),
          ],
          bottom: const TabBar(
            tabs: [Tab(text: 'Gastos'), Tab(text: 'Ingresos')],
            indicatorColor: AppTheme.primary,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.onSurfaceMuted,
          ),
        ),
        body: categoriesAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          ),
          error: (err, _) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    color: AppTheme.error, size: 48),
                const SizedBox(height: 12),
                Text(
                  err.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.onSurfaceMuted),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(categoriesProvider),
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          ),
          data: (categories) {
            final expense =
                categories.where((c) => c.type == 'EXPENSE').toList();
            final income =
                categories.where((c) => c.type == 'INCOME').toList();
            return TabBarView(
              children: [
                _CategoryList(
                  categories: expense,
                  type: 'EXPENSE',
                  onRefresh: () => ref.invalidate(categoriesProvider),
                  onAdd: () =>
                      _showCategoryForm(context, ref, type: 'EXPENSE'),
                  onEdit: (c) => _showCategoryForm(context, ref, category: c),
                  onDelete: (c) => _confirmDelete(context, ref, c),
                  onToggleActive: (c) => ref
                      .read(categoriesProvider.notifier)
                      .edit(c.id, UpdateCategoryRequest(isActive: !c.isActive)),
                ),
                _CategoryList(
                  categories: income,
                  type: 'INCOME',
                  onRefresh: () => ref.invalidate(categoriesProvider),
                  onAdd: () =>
                      _showCategoryForm(context, ref, type: 'INCOME'),
                  onEdit: (c) => _showCategoryForm(context, ref, category: c),
                  onDelete: (c) => _confirmDelete(context, ref, c),
                  onToggleActive: (c) => ref
                      .read(categoriesProvider.notifier)
                      .edit(c.id, UpdateCategoryRequest(isActive: !c.isActive)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ─── Bottom sheet formulario ──────────────────────────────────────────────

  void _showCategoryForm(
    BuildContext context,
    WidgetRef ref, {
    String? type,
    CategoryModel? category,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _CategoryFormSheet(
        ref: ref,
        initialType: category?.type ?? type ?? 'EXPENSE',
        category: category,
      ),
    );
  }

  // ─── Confirmar eliminación ────────────────────────────────────────────────

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    CategoryModel category,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar categoría'),
        content: Text(
          '¿Eliminar "${category.name}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar',
                style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      try {
        await ref.read(categoriesProvider.notifier).delete(category.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Categoría "${category.name}" eliminada'),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: AppTheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    }
  }
}

// ─── Lista de categorías ───────────────────────────────────────────────────────

class _CategoryList extends StatelessWidget {
  final List<CategoryModel> categories;
  final String type;
  final VoidCallback onRefresh;
  final VoidCallback onAdd;
  final ValueChanged<CategoryModel> onEdit;
  final ValueChanged<CategoryModel> onDelete;
  final ValueChanged<CategoryModel> onToggleActive;

  const _CategoryList({
    required this.categories,
    required this.type,
    required this.onRefresh,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = type == 'EXPENSE';
    final color = isExpense ? AppTheme.expense : AppTheme.income;

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: AppTheme.primary,
      child: categories.isEmpty
          ? CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isExpense
                                ? Icons.remove_circle_outline_rounded
                                : Icons.add_circle_outline_rounded,
                            size: 64,
                            color: AppTheme.onSurfaceMuted,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            isExpense
                                ? 'Sin categorías de gasto'
                                : 'Sin categorías de ingreso',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Crea categorías para organizar\ntus ${isExpense ? 'gastos' : 'ingresos'}.',
                            style: const TextStyle(
                                fontSize: 13, color: AppTheme.onSurfaceMuted),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: onAdd,
                            icon: const Icon(Icons.add_rounded),
                            label: Text(
                                'Nueva categoría de ${isExpense ? 'gasto' : 'ingreso'}'),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: color),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) => _CategoryCard(
                category: categories[i],
                onEdit: () => onEdit(categories[i]),
                onDelete: () => onDelete(categories[i]),
                onToggleActive: () => onToggleActive(categories[i]),
              ),
            ),
    );
  }
}

// ─── Tarjeta de categoría ──────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleActive;

  const _CategoryCard({
    required this.category,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleActive,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = category.type == 'EXPENSE';
    final color = isExpense ? AppTheme.expense : AppTheme.income;

    return Opacity(
      opacity: category.isActive ? 1.0 : 0.5,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            // ── Ícono ──────────────────────────────────────────────────────
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isExpense
                    ? Icons.remove_circle_outline_rounded
                    : Icons.add_circle_outline_rounded,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // ── Nombre + estado ─────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  if (!category.isActive)
                    const Text(
                      'Inactiva',
                      style: TextStyle(
                          fontSize: 11, color: AppTheme.onSurfaceMuted),
                    ),
                ],
              ),
            ),

            // ── Menú ────────────────────────────────────────────────────────
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded,
                  color: AppTheme.onSurfaceMuted, size: 20),
              color: AppTheme.surfaceVariant,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'toggle') onToggleActive();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(children: [
                    Icon(Icons.edit_outlined, size: 18, color: AppTheme.onSurface),
                    SizedBox(width: 10),
                    Text('Renombrar'),
                  ]),
                ),
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(children: [
                    Icon(
                      category.isActive
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 18,
                      color: AppTheme.onSurface,
                    ),
                    const SizedBox(width: 10),
                    Text(category.isActive ? 'Desactivar' : 'Activar'),
                  ]),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    Icon(Icons.delete_outline, size: 18, color: AppTheme.error),
                    SizedBox(width: 10),
                    Text('Eliminar', style: TextStyle(color: AppTheme.error)),
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Bottom sheet formulario crear/editar ──────────────────────────────────────

class _CategoryFormSheet extends StatefulWidget {
  final WidgetRef ref;
  final String initialType;
  final CategoryModel? category;

  const _CategoryFormSheet({
    required this.ref,
    required this.initialType,
    this.category,
  });

  @override
  State<_CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends State<_CategoryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late String _selectedType;
  bool _isSubmitting = false;

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.category?.name ?? '');
    _selectedType = widget.initialType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final notifier = widget.ref.read(categoriesProvider.notifier);
      if (_isEditing) {
        await notifier.edit(
          widget.category!.id,
          UpdateCategoryRequest(name: _nameController.text.trim()),
        );
      } else {
        await notifier.create(
          CreateCategoryRequest(
            name: _nameController.text.trim(),
            type: _selectedType,
          ),
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Título ─────────────────────────────────────────────────────
            Text(
              _isEditing ? 'Renombrar categoría' : 'Nueva categoría',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),

            // ── Tipo (solo en creación) ─────────────────────────────────────
            if (!_isEditing) ...[
              const Text(
                'Tipo',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.onSurfaceMuted),
              ),
              const SizedBox(height: 10),
              Row(
                children: ['EXPENSE', 'INCOME'].map((t) {
                  final isSelected = _selectedType == t;
                  final color =
                      t == 'EXPENSE' ? AppTheme.expense : AppTheme.income;
                  final label = t == 'EXPENSE' ? 'Gasto' : 'Ingreso';
                  final icon = t == 'EXPENSE'
                      ? Icons.remove_circle_outline_rounded
                      : Icons.add_circle_outline_rounded;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedType = t),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? color.withValues(alpha: 0.15)
                                : AppTheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? color : Colors.transparent,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(icon,
                                  color: isSelected
                                      ? color
                                      : AppTheme.onSurfaceMuted,
                                  size: 18),
                              const SizedBox(width: 6),
                              Text(
                                label,
                                style: TextStyle(
                                  fontSize: 13,
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
              const SizedBox(height: 20),
            ],

            // ── Nombre ─────────────────────────────────────────────────────
            TextFormField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nombre de la categoría',
                prefixIcon: Icon(Icons.label_outline_rounded),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Ingresa un nombre';
                if (v.trim().length < 2) return 'Mínimo 2 caracteres';
                return null;
              },
            ),
            const SizedBox(height: 24),

            // ── Botón ──────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(_isEditing ? 'Guardar' : 'Crear categoría'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
