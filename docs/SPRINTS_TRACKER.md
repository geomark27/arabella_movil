# 📱 Arabella Mobile — Sprint Planning

**Proyecto:** arabella_movil  
**Stack:** Flutter · Riverpod · GoRouter · Dio · flutter_dotenv  
**Backend:** arabella-api (Go · Gin · PostgreSQL)  
**Última actualización:** Febrero 2026  

---

## 🗂️ Arquitectura del Proyecto

```
lib/
├── core/
│   ├── constants/       # ApiConstants, rutas de endpoints
│   ├── network/         # ApiClient (Dio), AuthInterceptor
│   ├── theme/           # AppTheme (dark theme)
│   └── utils/           # CurrencyFormatter
├── data/
│   ├── models/          # DTOs y modelos de respuesta
│   └── repositories/    # Llamadas a la API
├── presentation/
│   ├── auth/            # Login, Register, ChangePassword
│   ├── dashboard/       # Dashboard principal
│   ├── accounts/        # CRUD completo de cuentas
│   ├── transactions/    # Listado de transacciones
│   ├── categories/      # Listado de categorías
│   ├── profile/         # Perfil de usuario
│   └── home/            # Shell con BottomNavigation
├── router/              # GoRouter con guard de autenticación
└── main.dart            # Entrada + carga de .env
```

---

## ✅ Sprint 0 — Infraestructura y Configuración
> Estado: **COMPLETADO**

| Tarea | Archivo | Estado |
|---|---|---|
| Cliente HTTP con Dio | `core/network/api_client.dart` | ✅ |
| Interceptor JWT (attach + refresh automático) | `core/network/auth_interceptor.dart` | ✅ |
| Constantes de endpoints | `core/constants/api_constants.dart` | ✅ |
| Dark theme global | `core/theme/app_theme.dart` | ✅ |
| Formateador de moneda | `core/utils/currency_formatter.dart` | ✅ |
| Router con guard de auth | `router/app_router.dart` | ✅ |
| Shell con BottomNavigation | `presentation/home/screens/home_screen.dart` | ✅ |
| Config de entorno (flutter_dotenv) | `.env` / `.env.example` | ✅ |
| Fallback de URL por plataforma | `core/constants/api_constants.dart` | ✅ |

---

## ✅ Sprint 1 — Autenticación
> Estado: **COMPLETADO**

| Pantalla | Archivo | Estado |
|---|---|---|
| Login | `presentation/auth/screens/login_screen.dart` | ✅ |
| Registro | `presentation/auth/screens/register_screen.dart` | ✅ |
| Cambiar contraseña | `presentation/auth/screens/change_password_screen.dart` | ✅ |
| AuthRepository | `data/repositories/auth_repository.dart` | ✅ |
| AuthProvider (Riverpod Notifier) | `presentation/auth/providers/auth_provider.dart` | ✅ |
| Persistencia de tokens (flutter_secure_storage) | `auth_provider.dart` | ✅ |
| Logout con confirmación | `presentation/profile/screens/profile_screen.dart` | ✅ |

---

## ✅ Sprint 2 — Dashboard
> Estado: **COMPLETADO**

| Componente | Estado |
|---|---|
| Tarjeta Runway (meses de supervivencia) | ✅ |
| Tarjeta Net Worth (activos totales) | ✅ |
| Estadísticas mensuales (ingresos / gastos / flujo neto) | ✅ |
| Listado de balances por cuenta | ✅ |
| DashboardRepository | ✅ |
| DashboardProvider | ✅ |

---

## ✅ Sprint 3 — Cuentas (CRUD completo)
> Estado: **COMPLETADO**

| Tarea | Archivo | Estado |
|---|---|---|
| Listado de cuentas | `presentation/accounts/screens/accounts_screen.dart` | ✅ |
| Crear cuenta (form) | `presentation/accounts/screens/account_form_screen.dart` | ✅ |
| Editar cuenta (form) | `presentation/accounts/screens/account_form_screen.dart` | ✅ |
| Detalle de cuenta | `presentation/accounts/screens/account_detail_screen.dart` | ✅ |
| Eliminar cuenta con confirmación | `accounts_screen.dart` + `account_detail_screen.dart` | ✅ |
| Selección de tipo (BANK, CASH, CREDIT_CARD, SAVINGS, INVESTMENT) | `account_form_screen.dart` | ✅ |
| Selección de moneda (endpoint /currencies) | `account_provider.dart` → `currenciesProvider` | ✅ |
| AccountRepository POST / PUT / DELETE | `data/repositories/account_repository.dart` | ✅ |
| AccountProvider AsyncNotifier para CRUD | `presentation/accounts/providers/account_provider.dart` | ✅ |

### 📝 Notas de implementación
- `AccountFormScreen` es reutilizable: recibe `AccountModel? account` — si es `null` opera en modo **creación**, si tiene valor opera en modo **edición**.
- `AccountsNotifier` extiende `AsyncNotifier` (Riverpod 2.x). El método `update` fue renombrado a `editAccount` por conflicto con el método reservado de `AsyncNotifierBase`.
- Las rutas `/accounts/new`, `/accounts/:id` y `/accounts/:id/edit` usan `parentNavigatorKey: _rootNavigatorKey` para renderizarse **sin** el shell de BottomNavigation.
- Cada `_AccountCard` tiene un `PopupMenuButton` con opciones de editar y eliminar, además de `onTap` para ir al detalle.
- El estado vacío (`_EmptyState`) incluye un botón directo para crear la primera cuenta.
- Snackbars de éxito y error en todas las operaciones CRUD.
- **Los tipos de cuenta NO están hardcodeados** — se consumen dinámicamente desde el endpoint `GET /api/v1/system-values/catalog/ACCOUNT_TYPE`. Los íconos se mapean localmente por `value` en el cliente ya que el backend no los provee.
- Se crearon `SystemValueModel`, `SystemValueRepository` y `catalogProvider` (Riverpod `family`) reutilizables para cualquier catálogo del sistema (`ACCOUNT_TYPE`, `ACCOUNT_CLASSIFICATION`, `TRANSACTION_TYPE`, `CATEGORY_TYPE`, etc.).
- `CatalogType` es una clase de constantes que centraliza los nombres de los catálogos disponibles.

### 📡 Endpoints activados
| Endpoint | Método | Estado |
|---|---|---|
| `/api/v1/accounts` | GET | ✅ |
| `/api/v1/accounts` | POST | ✅ |
| `/api/v1/accounts/:id` | GET | ✅ |
| `/api/v1/accounts/:id` | PUT | ✅ |
| `/api/v1/accounts/:id` | DELETE | ✅ |
| `/api/v1/currencies` | GET | ✅ (usado en el form) |
| `/api/v1/system-values/catalog/ACCOUNT_TYPE` | GET | ✅ (tipos de cuenta dinámicos) |

---

## 🔄 Sprint 4 — Transacciones (CRUD completo)
> Estado: **EN PROGRESO** — Listado hecho, formularios pendientes

| Tarea | Estado |
|---|---|
| Listado de transacciones | ✅ |
| Crear transacción (form) | ❌ |
| Editar transacción | ❌ |
| Detalle de transacción | ❌ |
| Eliminar con confirmación | ❌ |
| Selección de tipo (INCOME / EXPENSE / TRANSFER) | ❌ |
| Selección de cuenta origen / destino | ❌ |
| Selección de categoría | ❌ |
| Date picker | ❌ |
| Filtros (tipo, cuenta, categoría, fechas) | ❌ |
| Paginación | ❌ |
| TransactionRepository POST / PUT / DELETE | ❌ |

---

## 🔄 Sprint 5 — Categorías (CRUD completo)
> Estado: **EN PROGRESO** — Listado hecho, formularios pendientes

| Tarea | Estado |
|---|---|
| Listado con tabs (Gastos / Ingresos) | ✅ |
| Crear categoría (form) | ❌ |
| Editar categoría | ❌ |
| Eliminar con confirmación | ❌ |
| Activar / desactivar categoría | ❌ |
| CategoryRepository POST / PUT / DELETE | ❌ |

---

## ⏳ Sprint 6 — Perfil y Configuración
> Estado: **PENDIENTE**

| Tarea | Estado |
|---|---|
| Vista básica de perfil + logout | ✅ |
| Editar perfil (nombre, email, username) | ❌ |
| Pantalla de monedas disponibles | ❌ |
| Foto / avatar de usuario | ❌ |

---

## ⏳ Sprint 7 — UX & Polish
> Estado: **PENDIENTE**

| Tarea | Estado |
|---|---|
| Mensajes de error amigables al usuario | ❌ |
| Snackbars de éxito / error en CRUD | ❌ |
| Loading skeletons en listas | ❌ |
| Validaciones de formulario consistentes | ❌ |
| ConfirmDialog reutilizable | ❌ |
| Pantalla de error genérica (red / 500) | ❌ |
| Animaciones de transición | ❌ |

---

## ⏳ Sprint 8 — Features Avanzados
> Estado: **PENDIENTE**

| Feature | Estado |
|---|---|
| Búsqueda de transacciones | ❌ |
| Filtros avanzados | ❌ |
| Paginación / scroll infinito | ❌ |
| Historial de transacciones por cuenta | ❌ |
| Journal Entries viewer | ❌ |
| Gráficas de estadísticas / reportes | ❌ |
| Multi-moneda en dashboard | ❌ |

---

## ⏳ Sprint 9 — Testing
> Estado: **PENDIENTE**

| Tipo | Estado |
|---|---|
| Unit tests — providers | ❌ |
| Unit tests — repositories | ❌ |
| Widget tests — pantallas críticas | ❌ |
| Integration tests — flujos completos | ❌ |

---

## 📡 Endpoints del Backend

| Endpoint | Método | En Mobile |
|---|---|---|
| `/api/v1/auth/register` | POST | ✅ |
| `/api/v1/auth/login` | POST | ✅ |
| `/api/v1/auth/refresh` | POST | ✅ auto |
| `/api/v1/auth/change-password` | PUT | ✅ |
| `/api/v1/dashboard` | GET | ✅ |
| `/api/v1/dashboard/runway` | GET | ✅ |
| `/api/v1/dashboard/monthly-stats` | GET | ✅ |
| `/api/v1/accounts` | GET / POST | ✅ |
| `/api/v1/accounts/:id` | GET / PUT / DELETE | ✅ |
| `/api/v1/transactions` | GET / POST | GET ✅ · POST ❌ |
| `/api/v1/transactions/:id` | GET / PUT / DELETE | ❌ |
| `/api/v1/categories` | GET / POST | GET ✅ · POST ❌ |
| `/api/v1/categories/:id` | GET / PUT / DELETE | ❌ |
| `/api/v1/users/:id` | GET / PUT | ❌ |
| `/api/v1/currencies` | GET | ✅ (form cuentas) |
| `/api/v1/system-values/catalog/:catalogType` | GET | ✅ (ACCOUNT_TYPE activo) |
| `/api/v1/system-values/account-types` | GET | — (reemplazado por catalog) |
| `/api/v1/system-values/account-classifications` | GET | ❌ |
| `/api/v1/system-values/transaction-types` | GET | — (pendiente Sprint 4) |
| `/api/v1/system-values/category-types` | GET | — (pendiente Sprint 5) |
| `/api/v1/journal-entries/transaction/:id` | GET | ❌ |

---

## 📊 Progreso General

| Sprint | Descripción | Estado | % |
|---|---|---|---|
| Sprint 0 | Infraestructura | ✅ Completo | 100% |
| Sprint 1 | Autenticación | ✅ Completo | 100% |
| Sprint 2 | Dashboard | ✅ Completo | 100% |
| Sprint 3 | Cuentas CRUD | ✅ Completo | 100% |
| Sprint 4 | Transacciones CRUD | 🔄 En progreso | 10% |
| Sprint 5 | Categorías CRUD | 🔄 En progreso | 15% |
| Sprint 6 | Perfil & Config | ⏳ Pendiente | 20% |
| Sprint 7 | UX & Polish | ⏳ Pendiente | 0% |
| Sprint 8 | Features Avanzados | ⏳ Pendiente | 0% |
| Sprint 9 | Testing | ⏳ Pendiente | 0% |

**Progreso total estimado: ~50%**

---

*Mantenido por: Marcos Ramos*