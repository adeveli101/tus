import 'package:supabase_flutter/supabase_flutter.dart';

class TusDataLoader {
  static Future<List<Map<String, dynamic>>> loadTusData() async {
    final supabase = Supabase.instance.client;
    final data = await supabase.from('tus').select();
    return (data as List).cast<Map<String, dynamic>>();
  }
} 