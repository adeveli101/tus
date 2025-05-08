import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tus/features/tus_scores/domain/entities/department.dart';
import 'package:tus/features/tus_scores/presentation/widgets/department_card.dart';

void main() {
  testWidgets('DepartmentCard displays department information correctly',
      (WidgetTester tester) async {
    const department = Department(
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
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DepartmentCard(
            department: department,
            onFavoriteToggle: (String id) {},
          ),
        ),
      ),
    );

    expect(find.text('Test Department'), findsOneWidget);
    expect(find.text('Test University'), findsOneWidget);
    expect(find.text('YÖK'), findsOneWidget);
    expect(find.text('2024/2'), findsOneWidget);
    expect(find.text('5/5'), findsOneWidget);
    expect(find.text('75.5'), findsOneWidget);
    expect(find.text('1000'), findsOneWidget);
  });
} 