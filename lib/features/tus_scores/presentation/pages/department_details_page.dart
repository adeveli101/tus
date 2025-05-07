import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tus/features/tus_scores/domain/entities/department.dart';

class DepartmentDetailsPage extends StatelessWidget {
  final Department department;

  const DepartmentDetailsPage({
    Key? key,
    required this.department,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(department.name),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              title: 'Bölüm Bilgileri',
              content: {
                'Üniversite': department.university,
                'Fakülte': department.faculty,
                'Şehir': department.city,
                'Kontenjan': department.quota.toString(),
                'Minimum Puan': department.minScore.toStringAsFixed(2),
                'Maximum Puan': department.maxScore.toStringAsFixed(2),
                'Sınav Dönemi': DateFormat('dd.MM.yyyy').format(department.examPeriod),
              },
            ),
            const SizedBox(height: 16),
            _buildScoreChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required Map<String, String> content,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...content.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(entry.value),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Puan Dağılımı',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Center(
                child: Text(
                  'Min: ${department.minScore.toStringAsFixed(2)} - Max: ${department.maxScore.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 