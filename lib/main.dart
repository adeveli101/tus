import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tus/core/firebase/firebase_config.dart';
import 'package:tus/core/providers/app_providers.dart';
import 'package:tus/core/storage/hive_service.dart';
import 'package:tus/config/theme/app_theme.dart';
import 'package:tus/config/router/app_routes.dart';
import 'package:tus/app_background.dart';
import 'package:tus/features/splash/presentation/pages/splash_page.dart';
import 'package:tus/features/home/presentation/pages/home_page.dart';
import 'package:tus/features/tus_scores/presentation/pages/tus_scores_page.dart';
import 'package:tus/features/preferences/presentation/pages/preference_list_page.dart';
import 'package:tus/features/preferences/presentation/pages/preference_simulation_page.dart';
import 'package:tus/features/settings/presentation/pages/settings_page.dart';
import 'package:tus/features/tus_scores/domain/entities/department.dart';
import 'package:tus/features/tus_scores/presentation/pages/department_details_page.dart';
import 'package:tus/core/presentation/widgets/app_bottom_nav.dart';
import 'package:tus/core/presentation/pages/error_page.dart';
import 'package:tus/features/preferences/cubit/preference_list_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'config/theme/app_colors.dart';
import 'config/theme/app_text_styles.dart';

// Özel sayfa geçiş animasyonları
class SlidePageRoute<T> extends MaterialPageRoute<T> {
  SlidePageRoute({required WidgetBuilder builder, RouteSettings? settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOutCubic;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    var offsetAnimation = animation.drive(tween);

    return SlideTransition(position: offsetAnimation, child: child);
  }
}

class FadePageRoute<T> extends MaterialPageRoute<T> {
  FadePageRoute({required WidgetBuilder builder, RouteSettings? settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return FadeTransition(
      opacity: animation,
      child: child,
    );
  }
}

class ScalePageRoute<T> extends MaterialPageRoute<T> {
  ScalePageRoute({required WidgetBuilder builder, RouteSettings? settings})
      : super(builder: builder, settings: settings);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return ScaleTransition(
      scale: animation,
      child: child,
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Ana Sayfa';
      case 1:
        return 'TUS Puanları';
      case 2:
        return 'Tercih Listem';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryLight,
          title: Text(
            _getAppBarTitle(),
            style: AppTextStyles.titleLarge.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          actions: const [
            // Settings icon removed for Home tab
          ],
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildPage(),
        ),
        bottomNavigationBar: AppBottomNav(
          currentIndex: _currentIndex,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }

  Widget _buildPage() {
    final List<Widget> pages = [
      HomePage(onPageChanged: _onPageChanged),
      TusScoresPage(onPageChanged: _onPageChanged),
      BlocProvider(
        create: (_) => PreferenceListCubit()..loadPreferences(),
        child: PreferenceListPage(onPageChanged: _onPageChanged),
      ),
      SettingsPage(onPageChanged: _onPageChanged),
    ];

    return AppBackground(
      child: Stack(
        children: [
          pages[_currentIndex],
        ],
      ),
    );
  }
}

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    
    // Initialize Firebase first
    await FirebaseConfig.initialize();
    
    // Initialize core services
    final sharedPreferences = await SharedPreferences.getInstance();
    final hiveService = HiveService();
    await hiveService.init();
    
    // Initialize SQLite database
    final database = await openDatabase(
      join(await getDatabasesPath(), 'tus_database.db'),
      onCreate: (db, version) async {
        // Departments table
        await db.execute('''
          CREATE TABLE departments(
            id TEXT PRIMARY KEY,
            institution TEXT,
            department TEXT,
            type TEXT,
            year TEXT,
            quota TEXT,
            score REAL,
            ranking INTEGER,
            name TEXT,
            university TEXT,
            faculty TEXT,
            city TEXT,
            min_score REAL,
            max_score REAL,
            exam_period TEXT,
            is_favorite INTEGER
          )
        ''');

        // Department scores table
        await db.execute('''
          CREATE TABLE department_scores(
            id TEXT PRIMARY KEY,
            departmentId TEXT,
            examPeriodId TEXT,
            scoreType TEXT,
            minScore REAL,
            maxScore REAL,
            averageScore REAL,
            totalApplications INTEGER,
            successRate REAL,
            yearlyTrends TEXT,
            correlationFactors TEXT,
            lastUpdated TEXT,
            FOREIGN KEY (departmentId) REFERENCES departments (id)
          )
        ''');
      },
      version: 1,
    );
    
    // Initialize connectivity
    final connectivity = Connectivity();
    
    // Initialize Firestore
    final firestore = FirebaseFirestore.instance;
    
    runApp(
      AppBackground(
        child: AppProviders(
          database: database,
          connectivity: connectivity,
          firestore: firestore,
          child: const MyApp(),
        ),
      ),
    );
  } catch (e) {
    if (kDebugMode) {
      print('Uygulama başlatma hatası: $e');
    }
    // Hata durumunda da uygulamayı başlat
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TUS',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const SplashPage(),
        AppRoutes.home: (context) => HomePage(onPageChanged: (index) {
          Navigator.pushReplacementNamed(context, AppRoutes.main);
        }),
        AppRoutes.main: (context) => const MainPage(),
        AppRoutes.settings: (context) => const MainPage(),
        AppRoutes.preferenceSimulation: (context) => const PreferenceSimulationPage(),
        AppRoutes.error: (context) => const ErrorPage(message: 'Sayfa bulunamadı'),
      },
      onGenerateRoute: (settings) {
        if (settings.name?.startsWith('/department/') ?? false) {
          final departmentId = settings.name!.split('/').last;
          return MaterialPageRoute(
            builder: (context) => DepartmentDetailsPage(
              department: Department(
                id: departmentId,
                institution: 'Örnek Kurum',
                department: 'Örnek Bölüm',
                type: 'Genel',
                year: '2024',
                quota: '5',
                score: 85.5,
                ranking: 1000,
                name: 'Örnek Bölüm',
                university: 'Örnek Üniversite',
                faculty: 'Tıp Fakültesi',
                city: 'İstanbul',
                minScore: 80.0,
                maxScore: 90.0,
                examPeriod: '2024-1',
              ),
            ),
          );
        }
        return null;
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const ErrorPage(message: 'Bilinmeyen sayfa'),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
