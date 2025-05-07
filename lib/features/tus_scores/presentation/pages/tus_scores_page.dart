// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tus/config/router/app_routes.dart';
import 'package:tus/config/theme/app_colors.dart';
import 'package:tus/config/theme/app_text_styles.dart';
import 'package:tus/features/tus_scores/domain/entities/department.dart';
import 'package:tus/features/tus_scores/presentation/cubit/tus_scores_cubit.dart';
import 'package:tus/features/tus_scores/presentation/cubit/tus_scores_state.dart';
import 'package:tus/features/tus_scores/presentation/widgets/department_card.dart';
import 'package:tus/features/tus_scores/presentation/widgets/score_filter_widget.dart';

class TusScoresPage extends StatelessWidget {
  const TusScoresPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TUS Puanları'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: 10, // Örnek veri
        itemBuilder: (context, index) {
          final department = Department(
            id: index.toString(),
            name: 'Örnek Bölüm $index',
            university: 'Örnek Üniversite',
            faculty: 'Tıp Fakültesi',
            city: 'Örnek Şehir',
            quota: 5,
            minScore: 80.0 + index,
            maxScore: 90.0 + index,
            examPeriod: DateTime.now(),
          );
          return DepartmentCard(department: department);
        },
      ),
    );
  }
} 