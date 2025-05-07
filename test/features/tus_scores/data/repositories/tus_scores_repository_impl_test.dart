import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';
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

@GenerateMocks([TusScoresRemoteDataSource, PlacementPredictionService, Database, Connectivity])
void main() {
  late TusScoresRepositoryImpl repository;
  late MockTusScoresRemoteDataSource mockRemoteDataSource;
  late MockPlacementPredictionService mockPredictionService;
  late MockDatabase mockDatabase;
  late MockConnectivity mockConnectivity;

  setUp(() {
    mockRemoteDataSource = MockTusScoresRemoteDataSource();
    mockPredictionService = MockPlacementPredictionService();
    mockDatabase = MockDatabase();
    mockConnectivity = MockConnectivity();
    repository = TusScoresRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      predictionService: mockPredictionService,
      database: mockDatabase,
      connectivity: mockConnectivity,
    );
  });

  group('getDepartments', () {
    final tDepartments = [
      Department(
        id: '1',
        name: 'Test Department',
        university: 'Test University',
        faculty: 'Test Faculty',
        city: 'Test City',
        quota: 10,
        minScore: 80.0,
        maxScore: 90.0,
        examPeriod: DateTime.now(),
      ),
    ];

    test(
      'should return departments when remote data source is successful',
      () async {
        // arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);
        when(mockRemoteDataSource.getDepartments(const FilterParams()))
            .thenAnswer((_) async => tDepartments);
        when(mockDatabase.batch()).thenReturn(MockBatch());

        // act
        final result = await repository.getDepartments(const FilterParams());

        // assert
        expect(result.isRight(), true);
        result.fold(
          (l) => fail('should not return failure'),
          (r) => expect(r, tDepartments),
        );
        verify(mockRemoteDataSource.getDepartments(const FilterParams()));
      },
    );

    test(
      'should return failure when remote data source throws exception',
      () async {
        // arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);
        when(mockRemoteDataSource.getDepartments(const FilterParams()))
            .thenThrow(Exception());

        // act
        final result = await repository.getDepartments(const FilterParams());

        // assert
        expect(result.isLeft(), true);
        verify(mockRemoteDataSource.getDepartments(const FilterParams()));
      },
    );
  });
} 