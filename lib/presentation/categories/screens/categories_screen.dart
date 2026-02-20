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
              icon: const Icon(Icons.add_rounded),
              onPressed: () {
                // TODO: Crear categoría
              },
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
          loading:
              () => const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              ),
          error:
              (err, _) => Center(
                child: ElevatedButton(
                  onPressed: () => ref.invalidate(categoriesProvider),
                  child: const Text('Reintentar'),
                ),
              ),
          data: (categories) {
            final expense =
                categories.where((c) => c.type == 'EXPENSE').toList();
            final income = categories.where((c) => c.type == 'INCOME').toList();
            return TabBarView(
              children: [
                _CategoryList(categories: expense),
                _CategoryList(categories: income),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  final List<CategoryModel> categories;

  const _CategoryList({required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Center(
        child: Text(
          'Sin categorías',
          style: TextStyle(color: AppTheme.onSurfaceMuted),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      separatorBuilder: (_, _) => const SizedBox(height: 6),
      itemBuilder: (ctx, i) {
        final c = categories[i];
        final isExpense = c.type == 'EXPENSE';
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: (isExpense ? AppTheme.expense : AppTheme.income)
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isExpense
                      ? Icons.remove_circle_outline
                      : Icons.add_circle_outline,
                  color: isExpense ? AppTheme.expense : AppTheme.income,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  c.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.onSurface,
                  ),
                ),
              ),
              if (!c.isActive)
                const Text(
                  'Inactiva',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.onSurfaceMuted,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
