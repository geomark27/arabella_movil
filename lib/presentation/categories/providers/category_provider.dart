import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/category/category_model.dart';
import '../../../data/repositories/category_repository.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});

class CategoriesNotifier extends AsyncNotifier<List<CategoryModel>> {
  @override
  Future<List<CategoryModel>> build() async {
    return ref.read(categoryRepositoryProvider).getCategories();
  }

  Future<void> create(CreateCategoryRequest request) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(categoryRepositoryProvider).createCategory(request);
      return ref.read(categoryRepositoryProvider).getCategories();
    });
  }

  Future<void> edit(int id, UpdateCategoryRequest request) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(categoryRepositoryProvider).updateCategory(id, request);
      return ref.read(categoryRepositoryProvider).getCategories();
    });
  }

  Future<void> delete(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(categoryRepositoryProvider).deleteCategory(id);
      return ref.read(categoryRepositoryProvider).getCategories();
    });
  }
}

final categoriesProvider =
    AsyncNotifierProvider<CategoriesNotifier, List<CategoryModel>>(
      CategoriesNotifier.new,
    );
