import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/category/category_model.dart';
import '../../../data/repositories/category_repository.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository();
});

final categoriesProvider = FutureProvider.autoDispose<List<CategoryModel>>((
  ref,
) async {
  return ref.read(categoryRepositoryProvider).getCategories();
});
