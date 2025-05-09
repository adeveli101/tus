import 'dart:convert';
import 'package:flutter/services.dart';

class TusDataLoader {
  static Future<Map<String, dynamic>> loadTusData() async {
    final String jsonString = await rootBundle.loadString('assets/data/tus_data.json');
    return json.decode(jsonString);
  }
} 