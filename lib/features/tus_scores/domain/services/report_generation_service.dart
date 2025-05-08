import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:tus/features/tus_scores/domain/entities/department.dart';
import 'package:tus/features/tus_scores/domain/entities/department_score.dart';
import 'package:tus/features/tus_scores/domain/entities/placement_prediction.dart';
import 'package:intl/intl.dart';

class ReportGenerationService {
  Future<File> generateDepartmentReport({
    required Department department,
    required List<DepartmentScore> scores,
    required List<PlacementPrediction> predictions,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          _buildHeader(department),
          _buildDepartmentInfo(department),
          _buildScoreAnalysis(scores),
          _buildPredictions(predictions),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/department_report.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  pw.Widget _buildHeader(Department department) {
    return pw.Header(
      level: 0,
      child: pw.Text(
        '${department.name} - TUS Raporu',
        style: pw.TextStyle(
          fontSize: 24,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  pw.Widget _buildDepartmentInfo(Department department) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Bölüm Bilgileri',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          _buildInfoRow('Üniversite', department.university),
          _buildInfoRow('Fakülte', department.faculty),
          _buildInfoRow('Şehir', department.city),
          _buildInfoRow('Kontenjan', department.quota.toString()),
          _buildInfoRow(
            'Minimum Puan',
            department.minScore.toStringAsFixed(2),
          ),
          _buildInfoRow(
            'Maximum Puan',
            department.maxScore.toStringAsFixed(2),
          ),
          _buildInfoRow(
            'Sınav Dönemi',
            department.examPeriod,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildScoreAnalysis(List<DepartmentScore> scores) {
    final scoreData = scores.map((score) => score.score.toDouble()).toList();
    final average = scoreData.reduce((a, b) => a + b) / scoreData.length;
    final min = scoreData.reduce((a, b) => a < b ? a : b);
    final max = scoreData.reduce((a, b) => a > b ? a : b);

    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Puan Analizi',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          _buildInfoRow('Ortalama Puan', average.toStringAsFixed(2)),
          _buildInfoRow('Minimum Puan', min.toStringAsFixed(2)),
          _buildInfoRow('Maximum Puan', max.toStringAsFixed(2)),
          _buildInfoRow('Toplam Veri Sayısı', scores.length.toString()),
        ],
      ),
    );
  }

  pw.Widget _buildPredictions(List<PlacementPrediction> predictions) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 20),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Yerleşme Tahminleri',
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(),
            children: [
              pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('Olasılık'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('Ortalama Puan'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('Min Puan'),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8.0),
                    child: pw.Text('Max Puan'),
                  ),
                ],
              ),
              ...predictions.map((prediction) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(
                          '${(prediction.probability * 100).toStringAsFixed(1)}%',
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(
                          prediction.averageScore.toStringAsFixed(2),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(
                          prediction.minScore.toStringAsFixed(2),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8.0),
                        child: pw.Text(
                          prediction.maxScore.toStringAsFixed(2),
                        ),
                      ),
                    ],
                  )),
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(value),
        ],
      ),
    );
  }
} 