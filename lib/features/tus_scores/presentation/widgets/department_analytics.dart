import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tus/features/tus_scores/domain/entities/department_score.dart';
import 'package:statistics/statistics.dart';

class DepartmentAnalytics extends StatelessWidget {
  final List<DepartmentScore> scores;
  final double minScore;
  final double maxScore;
  final double averageScore;

  const DepartmentAnalytics({
    Key? key,
    required this.scores,
    required this.minScore,
    required this.maxScore,
    required this.averageScore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildScoreDistributionChart(),
        const SizedBox(height: 16),
        _buildTrendAnalysis(),
        const SizedBox(height: 16),
        _buildStatisticalAnalysis(),
      ],
    );
  }

  Widget _buildScoreDistributionChart() {
    final scoreData = scores.map((score) => score.score.toDouble()).toList();
    final scoreRange = maxScore - minScore;
    const binCount = 10;
    final binSize = scoreRange / binCount;
    
    final histogram = List<int>.filled(binCount, 0);
    for (final score in scoreData) {
      final binIndex = ((score - minScore) / binSize).floor().clamp(0, binCount - 1);
      histogram[binIndex]++;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Puan Dağılımı',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: histogram.reduce((a, b) => a > b ? a : b).toDouble(),
                  barGroups: List.generate(binCount, (index) {
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: histogram[index].toDouble(),
                          color: Colors.blue,
                          width: 20,
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendAnalysis() {
    final sortedScores = scores.toList()
      ..sort((a, b) => a.examPeriod.compareTo(b.examPeriod));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Puan Trendi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: SfCartesianChart(
                primaryXAxis: const DateTimeAxis(),
                series: <CartesianSeries>[
                  LineSeries<DepartmentScore, DateTime>(
                    dataSource: sortedScores,
                    xValueMapper: (DepartmentScore data, _) => data.examPeriod,
                    yValueMapper: (DepartmentScore data, _) => data.score.toDouble(),
                    name: 'Puan',
                    markerSettings: const MarkerSettings(isVisible: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticalAnalysis() {
    final scoreData = scores.map((score) => score.score.toDouble()).toList();
    final statistics = scoreData.statistics;
    
    // Calculate variance manually
    final mean = statistics.mean;
    final variance = scoreData.fold<double>(
      0,
      (sum, score) => sum + (score - mean) * (score - mean),
    ) / scoreData.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'İstatistiksel Analiz',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow('Ortalama', statistics.mean.toStringAsFixed(2)),
            _buildStatRow('Medyan', statistics.median.toStringAsFixed(2)),
            _buildStatRow('Standart Sapma', statistics.standardDeviation.toStringAsFixed(2)),
            _buildStatRow('Varyans', variance.toStringAsFixed(2)),
            _buildStatRow('Minimum', minScore.toStringAsFixed(2)),
            _buildStatRow('Maximum', maxScore.toStringAsFixed(2)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }
} 