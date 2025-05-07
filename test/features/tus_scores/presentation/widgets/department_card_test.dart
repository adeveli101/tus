import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tus/features/tus_scores/domain/entities/department.dart';
import 'package:tus/features/tus_scores/presentation/widgets/department_card.dart';

void main() {
  final testDepartment = Department(
    id: '1',
    name: 'Test Department',
    university: 'Test University',
    faculty: 'Test Faculty',
    city: 'Test City',
    quota: 10,
    minScore: 80.0,
    maxScore: 90.0,
    examPeriod: DateTime.now(),
  );

  testWidgets('DepartmentCard displays department information correctly',
      (WidgetTester tester) async {
    // Build our widget and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DepartmentCard(department: testDepartment),
        ),
      ),
    );

    // Verify that the department information is displayed
    expect(find.text(testDepartment.name), findsOneWidget);
    expect(find.text('${testDepartment.university} - ${testDepartment.faculty}'), findsOneWidget);
    expect(find.text('Kontenjan: ${testDepartment.quota}'), findsOneWidget);
    expect(find.text('Şehir: ${testDepartment.city}'), findsOneWidget);
    expect(find.text('Min: ${testDepartment.minScore.toStringAsFixed(2)}'), findsOneWidget);
    expect(find.text('Max: ${testDepartment.maxScore.toStringAsFixed(2)}'), findsOneWidget);
  });

  testWidgets('DepartmentCard is tappable', (WidgetTester tester) async {
    // Build our widget and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DepartmentCard(department: testDepartment),
        ),
      ),
    );

    // Verify that the card is tappable
    expect(find.byType(InkWell), findsOneWidget);
  });
} 