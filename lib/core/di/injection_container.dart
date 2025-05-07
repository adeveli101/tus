import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:tus/core/firebase/firebase_service.dart';
import 'package:tus/core/network/dio_client.dart';
import 'package:tus/core/storage/hive_service.dart';
import 'package:tus/features/tus_scores/data/datasources/tus_scores_remote_data_source.dart';
import 'package:tus/features/tus_scores/data/repositories/tus_scores_repository_impl.dart';
import 'package:tus/features/tus_scores/data/services/placement_prediction_service_impl.dart';
import 'package:tus/features/tus_scores/data/services/comparison_service_impl.dart';
import 'package:tus/features/tus_scores/data/services/sync_service_impl.dart';
import 'package:tus/features/tus_scores/domain/repositories/tus_scores_repository.dart';
import 'package:tus/features/tus_scores/domain/services/placement_prediction_service.dart';
import 'package:tus/features/tus_scores/domain/services/comparison_service.dart';
import 'package:tus/features/tus_scores/domain/services/sync_service.dart';
import 'package:tus/features/tus_scores/domain/usecases/add_department_score_usecase.dart';
import 'package:tus/features/tus_scores/domain/usecases/add_department_usecase.dart';
import 'package:tus/features/tus_scores/domain/usecases/add_exam_period_usecase.dart';
import 'package:tus/features/tus_scores/domain/usecases/get_department_by_id_usecase.dart';
import 'package:tus/features/tus_scores/domain/usecases/get_department_scores_usecase.dart';
import 'package:tus/features/tus_scores/domain/usecases/get_departments_usecase.dart';
import 'package:tus/features/tus_scores/domain/usecases/get_exam_periods_usecase.dart';
import 'package:tus/features/tus_scores/domain/usecases/get_user_by_id_usecase.dart';
import 'package:tus/features/tus_scores/domain/usecases/get_placement_predictions_usecase.dart';
import 'package:tus/features/tus_scores/domain/usecases/get_recommended_departments_usecase.dart';
import 'package:tus/features/tus_scores/domain/usecases/update_user_preferences_usecase.dart';
import 'package:tus/features/tus_scores/domain/usecases/update_user_score_usecase.dart';
import 'package:tus/features/tus_scores/presentation/cubit/tus_scores_cubit.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // External Dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerSingleton<SharedPreferences>(sharedPreferences);
  
  // Initialize SQLite database
  final database = await openDatabase(
    join(await getDatabasesPath(), 'tus_database.db'),
    onCreate: (db, version) async {
      // Departments table
      await db.execute('''
        CREATE TABLE departments(
          id TEXT PRIMARY KEY,
          name TEXT,
          university TEXT,
          faculty TEXT,
          city TEXT,
          quota INTEGER,
          minScore REAL,
          maxScore REAL,
          examPeriod TEXT,
          lastSynced TEXT
        )
      ''');

      // Department scores table
      await db.execute('''
        CREATE TABLE department_scores(
          id TEXT PRIMARY KEY,
          departmentId TEXT,
          score INTEGER,
          ranking INTEGER,
          examPeriod TEXT,
          lastSynced TEXT,
          FOREIGN KEY (departmentId) REFERENCES departments (id)
        )
      ''');

      // User preferences table
      await db.execute('''
        CREATE TABLE user_preferences(
          id TEXT PRIMARY KEY,
          userId TEXT,
          departmentId TEXT,
          priority INTEGER,
          notes TEXT,
          tags TEXT,
          createdAt TEXT,
          updatedAt TEXT,
          FOREIGN KEY (departmentId) REFERENCES departments (id)
        )
      ''');

      // Department statistics table
      await db.execute('''
        CREATE TABLE department_statistics(
          departmentId TEXT PRIMARY KEY,
          totalApplications INTEGER,
          successRate REAL,
          yearlyTrends TEXT,
          correlationFactors TEXT,
          lastUpdated TEXT,
          FOREIGN KEY (departmentId) REFERENCES departments (id)
        )
      ''');
    },
    version: 1,
  );
  sl.registerSingleton<Database>(database);
  
  // Core
  sl.registerLazySingleton<FirebaseService>(() => FirebaseService());
  sl.registerLazySingleton<DioClient>(() => DioClient());
  sl.registerLazySingleton<HiveService>(() => HiveService());
  
  // Firebase
  sl.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );
  
  // Data sources
  sl.registerLazySingleton<TusScoresRemoteDataSource>(
    () => TusScoresRemoteDataSourceImpl(
      firestore: sl(),
    ),
  );
  
  // Repositories
  sl.registerLazySingleton<TusScoresRepository>(
    () => TusScoresRepositoryImpl(
      remoteDataSource: sl(),
      predictionService: sl(),
      database: sl(),
    ),
  );
  
  // Use Cases
  sl.registerLazySingleton(() => GetExamPeriodsUseCase(sl()));
  sl.registerLazySingleton(() => GetDepartmentsUseCase(sl()));
  sl.registerLazySingleton(() => GetDepartmentScoresUseCase(sl()));
  sl.registerLazySingleton(() => AddExamPeriodUseCase(sl()));
  sl.registerLazySingleton(() => AddDepartmentUseCase(sl()));
  sl.registerLazySingleton(() => AddDepartmentScoreUseCase(sl()));
  sl.registerLazySingleton<GetDepartmentByIdUseCase>(
    () => GetDepartmentByIdUseCase(sl()),
  );
  sl.registerLazySingleton(() => GetUserByIdUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserPreferencesUseCase(sl()));
  sl.registerLazySingleton(() => GetPlacementPredictionsUseCase(sl()));
  sl.registerLazySingleton(() => GetRecommendedDepartmentsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserScoreUseCase(sl()));
  
  // Cubits
  sl.registerFactory<TusScoresCubit>(
    () => TusScoresCubit(
      getDepartmentsUseCase: sl(),
    ),
  );
  
  // Services
  sl.registerLazySingleton<PlacementPredictionService>(
    () => PlacementPredictionServiceImpl(),
  );
  sl.registerLazySingleton<ComparisonService>(
    () => ComparisonServiceImpl(sl()),
  );
  sl.registerLazySingleton<SyncService>(
    () => SyncServiceImpl(sl(), sl(), Connectivity()),
  );
  
  // Initialize Hive
  await sl<HiveService>().init();
} 