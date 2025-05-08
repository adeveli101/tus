import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tus/core/error/failures.dart';
import 'package:tus/features/tus_scores/data/datasources/tus_scores_remote_data_source.dart';
import 'package:tus/features/tus_scores/data/repositories/tus_scores_repository_impl.dart';
import 'package:tus/features/tus_scores/domain/entities/department.dart';
import 'package:tus/features/tus_scores/domain/entities/filter_params.dart';
import 'package:tus/features/tus_scores/domain/services/placement_prediction_service.dart';

import 'tus_scores_repository_impl_test.mocks.dart';

class MockBatch extends Mock implements Batch {
  @override
  Future<List<Object?>> commit({bool? exclusive, bool? noResult, bool? continueOnError}) async => [];

  @override
  void insert(String table, Map<String, Object?> values, {String? nullColumnHack, ConflictAlgorithm? conflictAlgorithm}) {}
}

@GenerateMocks([
  TusScoresRemoteDataSource,
  Database,
  Connectivity,
  FirebaseFirestore,
  PlacementPredictionService,
])
void main() {
  late TusScoresRepositoryImpl repository;
  late MockTusScoresRemoteDataSource mockRemoteDataSource;
  late MockDatabase mockDatabase;
  late MockConnectivity mockConnectivity;
  late MockFirebaseFirestore mockFirestore;
  late MockPlacementPredictionService mockPredictionService;

  setUp(() {
    mockRemoteDataSource = MockTusScoresRemoteDataSource();
    mockDatabase = MockDatabase();
    mockConnectivity = MockConnectivity();
    mockFirestore = MockFirebaseFirestore();
    mockPredictionService = MockPlacementPredictionService();

    repository = TusScoresRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      database: mockDatabase,
      connectivity: mockConnectivity,
      firestore: mockFirestore,
      predictionService: mockPredictionService,
    );
  });

  group('getDepartments', () {
    final testDepartments = [
      const Department(
        id: '1',
        institution: 'Test University',
        department: 'Test Department',
        type: 'YÖK',
        year: '2024/2',
        quota: '5/5',
        score: 75.5,
        ranking: 1000,
        name: 'Test Department',
        university: 'Test University',
        faculty: 'Test Faculty',
        city: 'Test City',
        minScore: 70.0,
        maxScore: 80.0,
        examPeriod: '2024/2',
        isFavorite: false,
      ),
    ];

    test('should return departments when remote data source is successful', () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);
      when(mockRemoteDataSource.getDepartments(any))
          .thenAnswer((_) async => testDepartments);

      // act
      final result = await repository.getDepartments(const FilterParams());

      // assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('should not return failure'),
        (departments) {
          expect(departments, testDepartments);
          verify(mockRemoteDataSource.getDepartments(any)).called(1);
        },
      );
    });

    test('should return failure when remote data source fails', () async {
      // arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => ConnectivityResult.wifi);
      when(mockRemoteDataSource.getDepartments(any))
          .thenThrow(Exception('Failed to get departments'));

      // act
      final result = await repository.getDepartments(const FilterParams());

      // assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (departments) => fail('should not return departments'),
      );
    });
  });
} 