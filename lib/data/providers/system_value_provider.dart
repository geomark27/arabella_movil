import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/system_value/system_value_model.dart';
import '../repositories/system_value_repository.dart';

// ─── Repository provider ──────────────────────────────────────────────────────

final systemValueRepositoryProvider = Provider<SystemValueRepository>((ref) {
  return SystemValueRepository();
});

// ─── Catalog provider (family) ────────────────────────────────────────────────
// Uso: ref.watch(catalogProvider(CatalogType.accountType))
// Sin autoDispose: los catálogos son estáticos durante la sesión y no deben
// descartarse entre setState del formulario, lo que causaría re-fetches infinitos.

final catalogProvider = FutureProvider
    .family<List<SystemValueModel>, String>((ref, catalogType) async {
      return ref.read(systemValueRepositoryProvider).getCatalog(catalogType);
    });
