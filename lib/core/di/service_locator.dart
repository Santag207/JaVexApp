import 'package:get_it/get_it.dart';
import '../../data/api_service.dart';
import '../../data/api/supabase_api_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../data/repositories/inventory_repository_impl.dart';
import '../../data/repositories/forms_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../domain/repositories/forms_repository.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/home/bloc/home_bloc.dart';
import '../../features/menu/bloc/menu_bloc.dart';
import '../../features/pending/bloc/pending_bloc.dart';
import '../../features/profile/bloc/profile_bloc.dart';
import '../../features/inventory/bloc/inventory_bloc.dart';
import '../../features/add_hours/bloc/add_hours_bloc.dart';
import '../../features/forms/bloc/forms_bloc.dart';
import '../services/biometric_service.dart';
import '../services/secure_storage_service.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // ==================== SINGLETONS (Servicios Globales) ====================

  // API Service (Supabase como fuente de datos)
  getIt.registerSingleton<ApiService>(SupabaseApiService());

  // Servicios de seguridad y biometría
  getIt.registerSingleton<SecureStorageService>(SecureStorageService());
  getIt.registerSingleton<BiometricService>(BiometricService());

  // Repositories
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(
      getIt<ApiService>(),
      getIt<SecureStorageService>(),
      getIt<BiometricService>(),
    ),
  );
  getIt.registerSingleton<TaskRepository>(
    TaskRepositoryImpl(getIt<ApiService>()),
  );
  getIt.registerSingleton<UserRepository>(
    UserRepositoryImpl(getIt<ApiService>()),
  );
  getIt.registerSingleton<InventoryRepository>(
    InventoryRepositoryImpl(getIt<ApiService>()),
  );
  getIt.registerSingleton<FormsRepository>(
    FormsRepositoryImpl(getIt<ApiService>()),
  );

  // ==================== FACTORIES (BLoCs) ====================

  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(authRepository: getIt<AuthRepository>()),
  );

  getIt.registerFactory<HomeBloc>(
    () => HomeBloc(
      taskRepository: getIt<TaskRepository>(),
      userRepository: getIt<UserRepository>(),
    ),
  );

  getIt.registerFactory<MenuBloc>(
    () => MenuBloc(),
  );

  getIt.registerFactory<PendingBloc>(
    () => PendingBloc(taskRepository: getIt<TaskRepository>()),
  );

  getIt.registerFactory<ProfileBloc>(
    () => ProfileBloc(userRepository: getIt<UserRepository>()),
  );

  getIt.registerFactory<InventoryBloc>(
    () => InventoryBloc(inventoryRepository: getIt<InventoryRepository>()),
  );

  getIt.registerFactory<AddHoursBloc>(
    () => AddHoursBloc(),
  );

  getIt.registerFactory<FormsBloc>(
    () => FormsBloc(formsRepository: getIt<FormsRepository>()),
  );
}
