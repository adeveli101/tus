import 'package:flutter/material.dart';
import 'package:tus/config/theme/app_colors.dart'; // Varsayılan tema dosyalarınız
import 'package:tus/config/theme/app_text_styles.dart'; // Varsayılan tema dosyalarınız
import 'package:tus/core/data/tus_data_loader.dart'; // Veri yükleyici sınıfınız

// Tercih öğesini temsil eden sınıf
class PreferenceItem {
  final String id;
  final String? branch;
  final String? institutionType; // 'universite' or 'eah'
  final String? city;
  final String? universityName;
  final String? facultyName;
  final String? hospitalName;
  final String? affiliatedFaculty; // For EAH

  PreferenceItem({
    required this.id,
    this.branch,
    this.institutionType,
    this.city,
    this.universityName,
    this.facultyName,
    this.hospitalName,
    this.affiliatedFaculty,
  });

  String get institutionDisplayName => universityName ?? hospitalName ?? 'Bilinmeyen Kurum';
  String get typeDisplayName {
    if (institutionType == 'universite') return 'Üniversite';
    if (institutionType == 'eah') return 'EAH/Şehir H.';
    return 'Bilinmiyor';
  }
}

class PreferenceListPage extends StatefulWidget {
  final Function(int) onPageChanged;
  const PreferenceListPage({super.key, required this.onPageChanged});

  @override
  State<PreferenceListPage> createState() => _PreferenceListPageState();
}

class _PreferenceListPageState extends State<PreferenceListPage> {
  final List<PreferenceItem> _preferences = [];
  Map<String, dynamic>? _tusData;
  bool _isLoading = true;
  String? _loadError;

  // Filtreleme için seçili değerler
  String? _selectedBranch;
  String? _selectedInstitutionType; // 'universite', 'eah'
  String? _selectedCity;

  // Dinamik olarak filtrelenen listeler (build metodunda hesaplanacak)
  List<String> _allBranches = [];
  List<String> _filteredCities = [];
  List<Map<String, dynamic>> _filteredInstitutions = []; // Üniversite veya Hastane map'leri

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      final data = await TusDataLoader.loadTusData();
      if (mounted) {
        setState(() {
          _tusData = data;
          _isLoading = false;
          _prepareInitialFilterData();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadError = "Veriler yüklenirken bir hata oluştu: ${e.toString()}";
        });
      }
    }
  }

  void _prepareInitialFilterData() {
    if (_tusData == null) return;
    // Tüm branşları hazırla
    try {
      _allBranches = [
        ...List<String>.from(_tusData!["metaVeriler"]["uzmanlikDallariListesi"]["dahiliTipBilimleri"] ?? []),
        ...List<String>.from(_tusData!["metaVeriler"]["uzmanlikDallariListesi"]["cerrahiTipBilimleri"] ?? []),
        ...List<String>.from(_tusData!["metaVeriler"]["uzmanlikDallariListesi"]["temelTipBilimleri"] ?? []),
      ];
      _allBranches.sort();
    } catch (e) {
      // Branşlar yüklenirken hata olursa loglayabilir veya kullanıcıya bildirebilirsiniz.
      // print("Branşlar hazırlanırken hata: $e");
      _allBranches = [];
    }
  }


  void _addPreference(Map<String, dynamic> institutionData) {
    final newPreferenceId = UniqueKey().toString();
    String? facultyName;
    String? affiliatedFaculty;

    if (_selectedInstitutionType == 'universite') {
      facultyName = institutionData['tipFakultesiAdi'] as String?;
    } else if (_selectedInstitutionType == 'eah') {
      affiliatedFaculty = institutionData['afiliyeOlduguFakulte_SBU'] as String?;
    }

    final newPreference = PreferenceItem(
      id: newPreferenceId,
      branch: _selectedBranch,
      institutionType: _selectedInstitutionType,
      city: institutionData[_selectedInstitutionType == 'universite' ? 'sehir' : 'il'] as String?,
      universityName: _selectedInstitutionType == 'universite' ? institutionData['universiteAdi'] as String? : null,
      facultyName: facultyName,
      hospitalName: _selectedInstitutionType == 'eah' ? institutionData['hastaneAdi'] as String? : null,
      affiliatedFaculty: affiliatedFaculty,
    );

    setState(() {
      _preferences.add(newPreference);
    });
  }

  void _removePreference(String id) {
    setState(() {
      _preferences.removeWhere((p) => p.id == id);
    });
  }

  void _reorderPreference(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _preferences.removeAt(oldIndex);
      _preferences.insert(newIndex, item);
    });
  }

  // Filtreler değiştiğinde çağrılacak
  void _onFilterChanged() {
    // Bu fonksiyon setState çağırmaz, setState filtre dropdown'larından gelir.
    // Sadece bağımlı filtreleri sıfırlar.
  }

  void _updateFilteredCities() {
    if (_tusData == null || _selectedInstitutionType == null) {
      _filteredCities = [];
      return;
    }
    if (_selectedInstitutionType == 'universite') {
      _filteredCities = (_tusData!["kurumVerileri"]["universiteTipFakulteleri"] as List)
          .map<String>((u) => u["sehir"] as String)
          .toSet()
          .toList();
    } else if (_selectedInstitutionType == 'eah') {
      _filteredCities = (_tusData!["kurumVerileri"]["eahVeSehirHastaneleri"] as List)
          .map<String>((h) => h["il"] as String)
          .toSet()
          .toList();
    } else {
      _filteredCities = [];
    }
    _filteredCities.sort();
  }

  void _updateFilteredInstitutions() {
    if (_tusData == null || _selectedInstitutionType == null) {
      _filteredInstitutions = [];
      return;
    }

    List<Map<String, dynamic>> institutions = [];
    if (_selectedInstitutionType == 'universite') {
      institutions = List<Map<String, dynamic>>.from(_tusData!["kurumVerileri"]["universiteTipFakulteleri"]);
      if (_selectedCity != null) {
        institutions = institutions.where((u) => u["sehir"] == _selectedCity).toList();
      }
    } else if (_selectedInstitutionType == 'eah') {
      institutions = List<Map<String, dynamic>>.from(_tusData!["kurumVerileri"]["eahVeSehirHastaneleri"]);
      if (_selectedCity != null) {
        institutions = institutions.where((h) => h["il"] == _selectedCity).toList();
      }
    }
    _filteredInstitutions = institutions;
  }


  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loadError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(_loadError!, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error), textAlign: TextAlign.center),
        ),
      );
    }
    if (_tusData == null) {
      return const Center(child: Text('Veri bulunamadı.', style: AppTextStyles.bodyLarge));
    }

    // Her build'de filtreleri güncelle
    _updateFilteredCities();
    _updateFilteredInstitutions();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryLight,
        title: Text('Tercih Listem', style: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimary)),
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: _buildInstitutionList(),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text('Tercih Listeniz (${_preferences.length})', style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary)),
          ),
          Expanded(
            child: _buildPreferenceList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: EdgeInsets.zero,
        title: Text('Tercih Filtreleri (isteğe bağlı)', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                _buildDropdown(
                  label: 'Branş',
                  value: _selectedBranch,
                  items: _allBranches.map((b) => DropdownMenuItem<String>(value: b, child: Text(b, overflow: TextOverflow.ellipsis))).toList(),
                  onChanged: (value) => setState(() => _selectedBranch = value),
                  width: 180,
                ),
                _buildDropdown(
                  label: 'Kurum Türü',
                  value: _selectedInstitutionType,
                  items: const [
                    DropdownMenuItem(value: 'universite', child: Text('Üniversite H.')),
                    DropdownMenuItem(value: 'eah', child: Text('EAH/Şehir H.')),
                  ],
                  onChanged: (value) => setState(() {
                    _selectedInstitutionType = value;
                    _selectedCity = null; // Kurum türü değişince şehir sıfırlanır
                    _onFilterChanged();
                  }),
                  width: 150,
                ),
                if (_selectedInstitutionType != null)
                  _buildDropdown(
                    label: 'Şehir',
                    value: _selectedCity,
                    items: _filteredCities.map((city) => DropdownMenuItem<String>(value: city, child: Text(city, overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: (value) => setState(() {
                      _selectedCity = value;
                      _onFilterChanged();
                    }),
                    width: 150,
                    disabled: _filteredCities.isEmpty,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
    double width = 200,
    bool disabled = false,
  }) {
    return Container(
      width: width,
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
          color: AppColors.primaryLight.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.primary.withOpacity(0.3))
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: label,
            labelStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          value: value,
          items: items,
          onChanged: disabled ? null : onChanged,
          isExpanded: true, // Genişliği konteynere yayar
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
          dropdownColor: AppColors.background,
        ),
      ),
    );
  }

  Widget _buildInstitutionList() {
    if (_selectedInstitutionType == null) {
      return Center(child: Text('Lütfen önce bir kurum türü seçin.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)));
    }
    if (_filteredInstitutions.isEmpty && _selectedCity != null) {
      return Center(child: Text('Seçili filtreye uygun kurum bulunamadı.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)));
    }
    if (_filteredInstitutions.isEmpty && _selectedCity == null) {
      return Center(child: Text('Lütfen bir şehir seçin veya tüm şehirlerdeki kurumları görmek için şehir filtresini boş bırakın (kurum türü seçiliyken).', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center,));
    }


    final Set<String> addedInstitutionNames = _preferences
        .map((p) => _selectedInstitutionType == 'universite' ? p.universityName : p.hospitalName)
        .whereType<String>()
        .toSet();

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: _filteredInstitutions.length,
      itemBuilder: (context, index) {
        final institution = _filteredInstitutions[index];
        final String institutionName = _selectedInstitutionType == 'universite'
            ? institution['universiteAdi'] as String
            : institution['hastaneAdi'] as String;
        final String cityOrFaculty = _selectedInstitutionType == 'universite'
            ? "${institution['tipFakultesiAdi'] ?? ''} (${institution['sehir'] ?? ''})"
            : "${institution['il'] ?? ''} | Afiliye: ${institution['afiliyeOlduguFakulte_SBU'] ?? '-'}";

        final bool isAdded = addedInstitutionNames.contains(institutionName) &&
            _preferences.any((p) =>
            p.branch == _selectedBranch &&
                (_selectedInstitutionType == 'universite' ? p.universityName == institutionName : p.hospitalName == institutionName)
            );


        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          color: AppColors.primaryLight.withOpacity(0.15),
          elevation: 1,
          child: ListTile(
            title: Text(institutionName, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
            subtitle: Text(cityOrFaculty, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
            trailing: IconButton(
              icon: Icon(isAdded ? Icons.check_circle : Icons.add_circle_outline, color: isAdded ? Colors.grey : AppColors.primary),
              tooltip: isAdded ? 'Bu branş için zaten eklendi' : 'Tercihe ekle',
              onPressed: isAdded ? null : () => _addPreference(institution),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPreferenceList() {
    if (_preferences.isEmpty) {
      return Center(
        child: Text('Henüz tercih eklemediniz.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
      );
    }
    return ReorderableListView.builder(
      itemCount: _preferences.length,
      itemBuilder: (context, index) {
        final preference = _preferences[index];
        return Card(
          key: ValueKey(preference.id), // Benzersiz ID kullanımı
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          color: AppColors.primaryLight.withOpacity(0.25),
          elevation: 1,
          child: ListTile(
            leading: ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_handle, color: AppColors.textSecondary),
            ),
            title: Text(
              preference.branch ?? "Branş Seçilmedi",
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              '${preference.institutionDisplayName} (${preference.city ?? ""}) - ${preference.typeDisplayName}\nFakülte: ${preference.facultyName ?? preference.affiliatedFaculty ?? "-"}',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
              tooltip: 'Tercihi Sil',
              onPressed: () => _removePreference(preference.id),
            ),
          ),
        );
      },
      onReorder: _reorderPreference,
    );
  }
}