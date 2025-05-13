import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:tus/core/firebase/firebase_service.dart';
import 'package:tus/core/network/dio_client.dart';
import 'package:tus/core/firebase/firebase_auth_service.dart';
import 'package:tus/core/storage/hive_service.dart';
import 'package:tus/features/tus_scores/data/repositories/tus_scores_repository_impl.dart';
import 'package:tus/features/tus_scores/data/services/placement_prediction_service_impl.dart';
import 'package:tus/features/tus_scores/data/services/comparison_service_impl.dart';
import 'package:tus/features/tus_scores/domain/repositories/tus_scores_repository.dart';
import 'package:tus/features/tus_scores/domain/services/placement_prediction_service.dart';
import 'package:tus/features/tus_scores/domain/services/comparison_service.dart';
import 'package:tus/features/tus_scores/domain/services/sync_service.dart';
import 'package:tus/features/tus_scores/domain/services/department_service.dart';
import 'package:tus/features/tus_scores/domain/services/sync_service_impl.dart' as sync_impl;
import 'package:tus/features/tus_scores/domain/services/department_service_impl.dart';
import 'package:tus/features/tus_scores/presentation/cubit/tus_scores_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tus/features/tus_scores/data/datasources/tus_scores_supabase_data_source.dart';

import '../../features/tus_scores/domain/usecases/add_department_score_usecase.dart';
import '../../features/tus_scores/domain/usecases/add_department_usecase.dart';
import '../../features/tus_scores/domain/usecases/add_exam_period_usecase.dart';
import '../../features/tus_scores/domain/usecases/get_department_by_id_usecase.dart';
import '../../features/tus_scores/domain/usecases/get_department_scores_usecase.dart';
import '../../features/tus_scores/domain/usecases/get_departments_usecase.dart';
import '../../features/tus_scores/domain/usecases/get_exam_periods_usecase.dart';
import '../../features/tus_scores/domain/usecases/get_placement_predictions_usecase.dart';
import '../../features/tus_scores/domain/usecases/get_recommended_departments_usecase.dart';
import '../../features/tus_scores/domain/usecases/get_user_by_id_usecase.dart';
import '../../features/tus_scores/domain/usecases/update_user_preferences_usecase.dart';
import '../../features/tus_scores/domain/usecases/update_user_score_usecase.dart';

class AppProviders extends StatelessWidget {
  final Widget child;
  final Database database;
  final Connectivity connectivity;
  final FirebaseFirestore firestore;

  const AppProviders({
    Key? key,
    required this.child,
    required this.database,
    required this.connectivity,
    required this.firestore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<Connectivity>(
          create: (_) => connectivity,
        ),
        Provider<Database>(
          create: (_) => database,
        ),
        Provider<FirebaseFirestore>(
          create: (_) => firestore,
        ),
        Provider<FirebaseAuthService>(
          create: (_) => FirebaseAuthService(),
        ),

        Provider<PlacementPredictionService>(
          create: (_) => PlacementPredictionServiceImpl(),
        ),
        Provider<TusScoresSupabaseDataSource>(
          create: (_) => TusScoresSupabaseDataSource(),
        ),
        Provider<TusScoresRepository>(
          create: (context) => TusScoresRepositoryImpl(
            predictionService: context.read<PlacementPredictionService>(),
            database: context.read<Database>(),
            connectivity: context.read<Connectivity>(),
          ),
        ),
        Provider<SyncService>(
          create: (context) => sync_impl.SyncServiceImpl(
            repository: context.read<TusScoresRepository>(),
            database: context.read<Database>(),
            connectivity: context.read<Connectivity>(),
          ),
        ),
        Provider<DepartmentService>(
          create: (context) => DepartmentServiceImpl(
            repository: context.read<TusScoresRepository>(),
          ),
        ),
        Provider<ComparisonService>(
          create: (context) => ComparisonServiceImpl(
            context.read<TusScoresRepository>(),
          ),
        ),
        BlocProvider<TusScoresCubit>(
          create: (context) => TusScoresCubit(
            context.read<DepartmentService>(),
          ),
        ),
      ],
      child: child,
    );
  }
} 