import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String tusScoresBox = 'tus_scores';
  static const String preferenceListsBox = 'preference_lists';
  
  Future<void> init() async {
    await Hive.initFlutter();
    // Register adapters here when models are created
    // await Hive.openBox<DepartmentScoreRankingModel>(tusScoresBox);
    // await Hive.openBox<UserPreferenceListModel>(preferenceListsBox);
  }
  
  Future<Box<T>> openBox<T>(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox<T>(boxName);
    }
    return Hive.box<T>(boxName);
  }
  
  Future<void> closeBox(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box(boxName).close();
    }
  }
  
  Future<void> closeAllBoxes() async {
    await Hive.close();
  }
} 