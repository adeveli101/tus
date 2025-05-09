/// Uygulama içindeki tüm route'ları tanımlayan sınıf.
/// 
/// Bu sınıf, uygulama içindeki tüm sayfa geçişlerini merkezi olarak yönetir.
/// Route'ları string yerine sabit değerler olarak tanımlar ve tip güvenliği sağlar.
class AppRoutes {
  /// Splash sayfası route'u
  static const String splash = '/splash';
  
  /// Ana sayfa route'u
  static const String home = '/';
  
  /// Ana uygulama sayfası route'u (bottom navigation bar içeren sayfa)
  static const String main = '/main';
  
  /// Ayarlar sayfası route'u
  static const String settings = '/settings';
  
  /// Tercih simülasyonu sayfası route'u
  static const String preferenceSimulation = '/preference-simulation';
  
  /// Tercih simülasyonu sonuçları sayfası route'u
  static const String preferenceSimulationResults = '/preference-simulation-results';
  
  /// Bölüm detay sayfası route'u
  /// 
  /// [departmentId] parametresi ile bölüm ID'si alır
  static String departmentDetails(String departmentId) => '/department/$departmentId';
  
  /// Tercih detay sayfası route'u
  /// 
  /// [preferenceId] parametresi ile tercih ID'si alır
  static String preferenceDetails(String preferenceId) => '/preference/$preferenceId';
  
  /// Çalışma programı sayfası route'u
  static const String studySchedule = '/study-schedule';
  
  /// Profil sayfası route'u
  static const String profile = '/profile';
  
  /// Hata sayfası route'u
  static const String error = '/error';
} 