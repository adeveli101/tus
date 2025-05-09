import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tus/config/theme/app_colors.dart';
import 'preference_list_page.dart';

class PreferenceListHomePage extends StatefulWidget {
  final Function(int) onPageChanged;
  const PreferenceListHomePage({super.key, required this.onPageChanged});

  @override
  State<PreferenceListHomePage> createState() => _PreferenceListHomePageState();
}

class _PreferenceListHomePageState extends State<PreferenceListHomePage> {
  List<Map<String, dynamic>> savedLists = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLists();
  }

  Future<void> _loadLists() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final lists = prefs.getStringList('tus_saved_lists') ?? [];
    savedLists = lists.map((e) => Map<String, dynamic>.from(Map<String, dynamic>.from(e as dynamic))).toList();
    setState(() => isLoading = false);
  }

  void _goToCreateList() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PreferenceListPage(
          onPageChanged: widget.onPageChanged,
        ),
      ),
    );
    _loadLists();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Tercih Listelerim', style: TextStyle(color: AppColors.textPrimary)),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: savedLists.isEmpty
          ? Center(
              child: ElevatedButton(
                onPressed: _goToCreateList,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                  textStyle: const TextStyle(fontSize: 20),
                ),
                child: const Text('Liste Oluştur'),
              ),
            )
          : Container(
              color: Colors.transparent,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Kayıtlı Tercih Listeleri', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textPrimary)),
                        ElevatedButton(
                          onPressed: _goToCreateList,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.textOnPrimary,
                          ),
                          child: const Text('Yeni Liste Oluştur'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: savedLists.length,
                      itemBuilder: (context, idx) {
                        final list = savedLists[idx];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          color: Colors.transparent,
                          elevation: 2,
                          child: ListTile(
                            title: Text(list['title'] ?? 'Tercih Listesi', style: const TextStyle(color: AppColors.textPrimary)),
                            subtitle: Text(list['date'] ?? '', style: const TextStyle(color: AppColors.textSecondary)),
                            onTap: () {
                              // Detay sayfasına git veya düzenle
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
} 