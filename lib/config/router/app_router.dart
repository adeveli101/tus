import 'package:go_router/go_router.dart';
import 'package:tus/core/presentation/pages/error_page.dart';
import 'package:tus/features/home/presentation/pages/home_page.dart';
import 'package:tus/features/preferences/presentation/pages/preference_list_page.dart';
import 'package:tus/features/preferences/presentation/pages/preference_simulation_page.dart';
import 'package:tus/features/settings/presentation/pages/settings_page.dart';
import 'package:tus/features/splash/presentation/pages/splash_page.dart';
import 'package:tus/features/tus_scores/presentation/pages/department_details_page.dart';
import 'package:tus/features/tus_scores/presentation/pages/tus_scores_page.dart';
import 'package:tus/features/tus_scores/domain/entities/department.dart';

import 'app_routes.dart';

final router = GoRouter(
  initialLocation: AppRoutes.splash,
  errorBuilder: (context, state) => const ErrorPage(
    message: 'Sayfa bulunamadı',
    code: '404',
  ),
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: AppRoutes.tusScores,
      builder: (context, state) => const TusScoresPage(),
    ),
    GoRoute(
      path: '${AppRoutes.tusScores}/:id',
      builder: (context, state) {
        final departmentId = state.pathParameters['id']!;
        return DepartmentDetailsPage(
          department: Department(
            id: departmentId,
            name: '',
            university: '',
            faculty: '',
            city: '',
            quota: 0,
            minScore: 0.0,
            maxScore: 0.0,
            examPeriod: DateTime.now(),
          ),
        );
      },
    ),
    GoRoute(
      path: AppRoutes.preferenceSimulation,
      builder: (context, state) => const PreferenceSimulationPage(),
    ),
    GoRoute(
      path: AppRoutes.preferenceList,
      builder: (context, state) => const PreferenceListPage(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsPage(),
    ),
  ],
); 