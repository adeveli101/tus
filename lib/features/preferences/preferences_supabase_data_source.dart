import 'package:supabase_flutter/supabase_flutter.dart';

class PreferencesSupabaseDataSource {
  final supabase = Supabase.instance.client;

  // Tercih Listesi CRUD
  Future<List<Map<String, dynamic>>> getUserPreferenceLists(String userId) async {
    final response = await supabase
        .from('tercih_listeleri')
        .select()
        .eq('user_id', userId)
        .order('created_at');
    return (response as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>?> createPreferenceList({
    required String userId,
    required String title,
  }) async {
    final response = await supabase
        .from('tercih_listeleri')
        .insert({
          'user_id': userId,
          'title': title,
        })
        .select()
        .single();
    return response as Map<String, dynamic>?;
  }

  Future<void> deletePreferenceList(int listId) async {
    await supabase.from('tercih_listeleri').delete().eq('id', listId);
  }

  // Tercih Satırı CRUD
  Future<List<Map<String, dynamic>>> getPreferenceListItems(int listId) async {
    final response = await supabase
        .from('tercih_listesi_satirlari')
        .select()
        .eq('tercih_listesi_id', listId)
        .order('sira');
    return (response as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>?> addPreferenceListItem({
    required int listId,
    required int tusVeriAnaId,
    required double kullaniciPuani,
    required int sira,
    String? aciklama,
  }) async {
    final response = await supabase
        .from('tercih_listesi_satirlari')
        .insert({
          'tercih_listesi_id': listId,
          'tus_veri_ana_id': tusVeriAnaId,
          'kullanici_puani': kullaniciPuani,
          'sira': sira,
          if (aciklama != null) 'aciklama': aciklama,
        })
        .select()
        .single();
    return response as Map<String, dynamic>?;
  }

  Future<void> updatePreferenceListItem({
    required int itemId,
    double? kullaniciPuani,
    int? sira,
    String? aciklama,
  }) async {
    final updateData = <String, dynamic>{};
    if (kullaniciPuani != null) updateData['kullanici_puani'] = kullaniciPuani;
    if (sira != null) updateData['sira'] = sira;
    if (aciklama != null) updateData['aciklama'] = aciklama;
    await supabase
        .from('tercih_listesi_satirlari')
        .update(updateData)
        .eq('id', itemId);
  }

  Future<void> deletePreferenceListItem(int itemId) async {
    await supabase.from('tercih_listesi_satirlari').delete().eq('id', itemId);
  }

  // Diğer kullanıcıların ilk iki tercihi ve puanları (anonim)
  Future<List<Map<String, dynamic>>> getOtherUsersTopPreferences(int tusVeriAnaId, int limit) async {
    final response = await supabase.rpc('get_other_users_top_preferences', params: {
      'tus_veri_ana_id': tusVeriAnaId,
      'limit': limit,
    });
    return (response as List).cast<Map<String, dynamic>>();
  }
} 