// ignore_for_file: unnecessary_brace_in_string_interps

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/brans.dart';
import '../../domain/entities/donem.dart';
import '../../domain/entities/tus_veri_ana.dart';

class TusScoresSupabaseDataSource {
  final supabase = Supabase.instance.client;

  Future<List<Brans>> getBranslar() async {
    final response = await supabase.from('branslar').select('bransid, bransadi').order('bransadi');
    return (response as List).map((e) => Brans.fromJson(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getKontenjanlar() async {
    final response = await supabase.from('tus_kontenjanlar').select().order('tusDonemi');
    return (response as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getBransKontenjanDegisimleri() async {
    final response = await supabase.from('tus_brans_kontenjan_degisimleri').select();
    return (response as List).cast<Map<String, dynamic>>();
  }

  Future<List<Donem>> getDonemler() async {
    final response = await supabase.from('donemler').select();
    return (response as List).map((e) => Donem.fromJson(e)).toList();
  }

  Future<List<TusVeriAna>> getTusVerileriAna() async {
    final response = await supabase.from('tus_verileri_ana').select();
    return (response as List).map((e) => TusVeriAna.fromJson(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getKurumlar() async {
    final response = await supabase.from('kurumlar').select();
    return (response as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>?> getKurumById(int kurumId) async {
    final response = await supabase.from('kurumlar').select().eq('kurum_id', kurumId).single();
    return response as Map<String, dynamic>?;
  }

  Future<List<TusVeriAna>> getTusVerileriAnaFiltered({
    int? donemId,
    int? bransId,
    int? kurumId,
    String? kontenjanTuru,
    String? puanTuru,
    double? minTabanPuan,
    double? maxTabanPuan,
  }) async {
    var query = supabase.from('tus_verileri_ana').select();
    if (donemId != null) query = query.eq('donem_id', donemId);
    if (bransId != null) query = query.eq('brans_id', bransId);
    if (kurumId != null) query = query.eq('kurum_id', kurumId);
    if (kontenjanTuru != null) query = query.eq('kontenjan_turu', kontenjanTuru);
    if (puanTuru != null) query = query.eq('puan_turu', puanTuru);
    if (minTabanPuan != null) query = query.gte('taban_puan', minTabanPuan);
    if (maxTabanPuan != null) query = query.lte('taban_puan', maxTabanPuan);
    final response = await query;
    return (response as List).map((e) => TusVeriAna.fromJson(e)).toList();
  }

  // ignore: unused_element
  String _normalizePeriod(String period) {
    return period
        .replaceAll(' ', '')
        .replaceAll('/', '_')
        .replaceAll('ö', 'o')
        .replaceAll('Ö', 'O')
        .toLowerCase();
  }

  Future<List<Map<String, dynamic>>> getKurumlarByDonem(Donem donem) async {
    final year = donem.sinavyili;
    final period = donem.sinavdonemiadi.trim().toLowerCase().replaceAll(' ', '');
    final tableName = 'kurumlar_${year}_${period}';
    if (kDebugMode) {
      print('Tablo adı: $tableName, donemid: ${donem.donemid}');
    }
    final response = await supabase.from(tableName).select().eq('donemid', donem.donemid);
    if (kDebugMode) {
      print('Kurumlar tablosu response: $response');
    }
    return (response as List).cast<Map<String, dynamic>>();
  }
} 