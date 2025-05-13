import 'package:flutter/material.dart';
import 'package:tus/config/theme/app_colors.dart';
import 'package:tus/config/theme/app_text_styles.dart';
import 'package:tus/core/data/tus_data_loader.dart';

class PreferenceListPage extends StatefulWidget {
  final Function(int) onPageChanged;
  final bool isNewList;
  const PreferenceListPage({super.key, required this.onPageChanged, this.isNewList = false});

  @override
  State<PreferenceListPage> createState() => _PreferenceListPageState();
}

class _PreferenceListPageState extends State<PreferenceListPage> {
  List<Map<String, dynamic>>? tusData;
  bool isLoading = true;

  // Filtreler
  final List<String> _selectedBranches = [];
  final List<String> _selectedCities = [];
  String? _selectedInstitutionType;

  // Arama
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final FocusNode _searchFocusNode = FocusNode();

  // Drawer açık mı?
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Kullanıcının tercih listesi
  List<Map<String, dynamic>> preferences = [];

  // Sıralama
  String _sortType = 'alphabetical'; // 'alphabetical', 'lowScore', 'highScore'

  bool _isPreferenceListOpen = false;

  final GlobalKey _sortButtonKey = GlobalKey();

  OverlayEntry? _filterOverlayEntry;
  final GlobalKey _filterButtonKey = GlobalKey();

  bool _isBranchOpen = false;
  bool _isCityOpen = false;

  @override
  void initState() {
    super.initState();
    TusDataLoader.loadTusData().then((data) {
      setState(() {
        tusData = data;
        isLoading = false;
      });
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> getFilteredUniversityBranches() {
    if (tusData == null) return [];
    List<Map<String, dynamic>> allItems = [];
    for (var u in tusData!) {
      final String university = u['universiteAdi'];
      final String city = u['sehir'].toString();
      final String faculty = u['tipFakultesiAdi'] ?? '';
      for (final branch in [
        ...List<String>.from(tusData![0]["aktifTusUzmanlikDallariListesi"]["dahiliTipBilimleri"]),
        ...List<String>.from(tusData![0]["aktifTusUzmanlikDallariListesi"]["cerrahiTipBilimleri"]),
        ...List<String>.from(tusData![0]["aktifTusUzmanlikDallariListesi"]["temelTipBilimleri"]),
      ]) {
        allItems.add({
          'university': university,
          'city': city,
          'faculty': faculty,
          'branch': branch,
        });
      }
    }
    // Filtre uygula
    var filtered = allItems.where((item) {
      if (_selectedCities.isNotEmpty && !_selectedCities.contains(item['city'])) return false;
      if (_selectedBranches.isNotEmpty && !_selectedBranches.contains(item['branch'])) return false;
      // Arama filtresi
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final branch = (item['branch'] ?? '').toString().toLowerCase();
        final university = (item['university'] ?? '').toString().toLowerCase();
        final city = (item['city'] ?? '').toString().toLowerCase();
        if (!branch.contains(query) && !university.contains(query) && !city.contains(query)) {
          return false;
        }
      }
      return true;
    }).toList();
    // Sıralama işlemi
    if (_sortType == 'alphabetical') {
      filtered.sort((a, b) => (a['branch'] as String).compareTo(b['branch'] as String));
    } else if (_sortType == 'lowScore' || _sortType == 'highScore') {
      Map<String, num> branchMinScore = {};
      if (tusData != null && tusData!.isNotEmpty && tusData![0].containsKey('uzmanlikDallariVeEgitimSureleri')) {
        for (var e in tusData![0]['uzmanlikDallariVeEgitimSureleri']) {
          if (e['uzmanlikDali'] != null && e['enDusukPuan'] != null) {
            branchMinScore[e['uzmanlikDali']] = num.tryParse(e['enDusukPuan'].toString()) ?? 0;
          }
        }
      }
      filtered.sort((a, b) {
        num aScore = branchMinScore[a['branch']] ?? 0;
        num bScore = branchMinScore[b['branch']] ?? 0;
        return _sortType == 'lowScore' ? aScore.compareTo(bScore) : bScore.compareTo(aScore);
      });
    }
    return filtered;
  }

  List<String> getAllBranches() {
    if (tusData == null) return [];
    return [
      ...List<String>.from(tusData![0]["aktifTusUzmanlikDallariListesi"]["dahiliTipBilimleri"]),
      ...List<String>.from(tusData![0]["aktifTusUzmanlikDallariListesi"]["cerrahiTipBilimleri"]),
      ...List<String>.from(tusData![0]["aktifTusUzmanlikDallariListesi"]["temelTipBilimleri"]),
    ];
  }

  List<String> getAllCities() {
    if (tusData == null) return [];
    final Set<String> allCities = {
      ...tusData!.map((u) => u["sehir"].toString()),
    };
    return allCities.toList();
  }

  void addPreference(Map<String, dynamic> item) {
    setState(() {
      preferences.add(item);
    });
  }

  void removePreference(int index) {
    setState(() {
      preferences.removeAt(index);
    });
  }

  void reorderPreference(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = preferences.removeAt(oldIndex);
      preferences.insert(newIndex, item);
    });
  }

  void _showFilterPopup() {
    if (_filterOverlayEntry != null) return;
    final RenderBox button = _filterButtonKey.currentContext!.findRenderObject() as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero);
    final Size size = button.size;
    _filterOverlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: _removeFilterPopup,
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            Positioned(
              left: offset.dx + size.width - 260,
              top: offset.dy + size.height + 4,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 260,
                  height: 420,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      textTheme: Theme.of(context).textTheme.apply(
                        bodyColor: AppColors.textOnPrimary,
                        displayColor: AppColors.textOnPrimary,
                      ),
                      inputDecorationTheme: const InputDecorationTheme(
                        labelStyle: TextStyle(color: AppColors.textOnPrimary),
                        hintStyle: TextStyle(color: AppColors.textOnPrimary),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                      ),
                      dropdownMenuTheme: const DropdownMenuThemeData(
                        textStyle: TextStyle(color: AppColors.textOnPrimary),
                      ),
                    ),
                    child: StatefulBuilder(
                      builder: (context, setPopupState) => SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Branş çoklu seçim
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ExpansionTile(
                                tilePadding: EdgeInsets.zero,
                                initiallyExpanded: _isBranchOpen,
                                onExpansionChanged: (expanded) {
                                  setPopupState(() {
                                    _isBranchOpen = expanded;
                                    if (expanded) _isCityOpen = false;
                                  });
                                },
                                title: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Text('Branş', style: TextStyle(color: AppColors.textOnPrimary, fontWeight: FontWeight.bold)),
                                ),
                                children: _isBranchOpen ? [
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxHeight: 200),
                                    child: SingleChildScrollView(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 12.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Wrap(
                                              spacing: 4,
                                              runSpacing: 0,
                                              children: _selectedBranches.map((b) => Chip(
                                                label: Text(b, style: const TextStyle(color: AppColors.textOnPrimary)),
                                                backgroundColor: AppColors.primary.withOpacity(0.1),
                                                onDeleted: () {
                                                  setPopupState(() => _selectedBranches.remove(b));
                                                },
                                              )).toList(),
                                            ),
                                            _buildCompactCheckboxList(
                                              items: getAllBranches(),
                                              selected: _selectedBranches,
                                              onChanged: (b, val) {
                                                setPopupState(() {
                                                  if (val) {
                                                    _selectedBranches.add(b);
                                                  } else {
                                                    _selectedBranches.remove(b);
                                                  }
                                                });
                                              },
                                            ),
                                            const SizedBox(height: 8),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ] : [],
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Şehir çoklu seçim
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ExpansionTile(
                                tilePadding: EdgeInsets.zero,
                                initiallyExpanded: _isCityOpen,
                                onExpansionChanged: (expanded) {
                                  setPopupState(() {
                                    _isCityOpen = expanded;
                                    if (expanded) _isBranchOpen = false;
                                  });
                                },
                                title: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  child: Text('Şehir', style: TextStyle(color: AppColors.textOnPrimary, fontWeight: FontWeight.bold)),
                                ),
                                children: _isCityOpen ? [
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(maxHeight: 160),
                                    child: SingleChildScrollView(
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 12.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Wrap(
                                              spacing: 4,
                                              runSpacing: 0,
                                              children: _selectedCities.map((c) => Chip(
                                                label: Text(c, style: const TextStyle(color: AppColors.textOnPrimary)),
                                                backgroundColor: AppColors.primary.withOpacity(0.1),
                                                onDeleted: () {
                                                  setPopupState(() => _selectedCities.remove(c));
                                                },
                                              )).toList(),
                                            ),
                                            _buildCompactCheckboxList(
                                              items: getAllCities(),
                                              selected: _selectedCities,
                                              onChanged: (c, val) {
                                                setPopupState(() {
                                                  if (val) {
                                                    _selectedCities.add(c);
                                                  } else {
                                                    _selectedCities.remove(c);
                                                  }
                                                });
                                              },
                                            ),
                                            const SizedBox(height: 8),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ] : [],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    setPopupState(() {
                                      _selectedBranches.clear();
                                      _selectedCities.clear();
                                    });
                                    setState(() {
                                      _selectedBranches.clear();
                                      _selectedCities.clear();
                                    });
                                    _removeFilterPopup();
                                  },
                                  child: const Text('Temizle', style: TextStyle(color: AppColors.textOnPrimary)),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {}); // Filtre uygula
                                    _removeFilterPopup();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.textOnPrimary,
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    elevation: 0,
                                  ),
                                  child: const Text('Uygula', style: TextStyle(color: AppColors.textOnPrimary)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
    Overlay.of(context).insert(_filterOverlayEntry!);
  }

  void _removeFilterPopup() {
    _filterOverlayEntry?.remove();
    _filterOverlayEntry = null;
  }

  Widget _buildCompactCheckboxList({required List<String> items, required List<String> selected, required void Function(String, bool) onChanged}) {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: items.map((item) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(
              child: Text(item, style: const TextStyle(color: AppColors.textOnPrimary, fontSize: 14)),
            ),
            Checkbox(
              value: selected.contains(item),
              onChanged: (val) => onChanged(item, val ?? false),
              activeColor: AppColors.primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              side: const BorderSide(width: 1, color: AppColors.primary),
            ),
          ],
        ),
      )).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.background,
        drawer: null,
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('Tercih Listesi', style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                const Icon(Icons.star, color: AppColors.primary, size: 20),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                // Arama kutusu
                                Expanded(
                                  flex: 5,
                                  child: TextField(
                                    controller: _searchController,
                                    focusNode: _searchFocusNode,
                                    decoration: InputDecoration(
                                      hintText: 'Ara...',
                                      prefixIcon: const Icon(Icons.search),
                                      filled: true,
                                      fillColor: AppColors.surface,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none,
                                      ),
                                      suffixIcon: _searchQuery.isNotEmpty
                                          ? IconButton(
                                              icon: const Icon(Icons.clear),
                                              onPressed: () {
                                                _searchController.clear();
                                              },
                                            )
                                          : null,
                                    ),
                                    textInputAction: TextInputAction.search,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Sırala butonu (artık önce)
                                SizedBox(
                                  height: 40,
                                  key: _sortButtonKey,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      backgroundColor: AppColors.surface,
                                      foregroundColor: AppColors.textOnPrimary,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                    ),
                                    icon: const Icon(Icons.sort, size: 20, color: AppColors.primary),
                                    label: const Text('Sırala', style: TextStyle(color: AppColors.primary)),
                                    onPressed: () {
                                      final RenderBox button = _sortButtonKey.currentContext!.findRenderObject() as RenderBox;
                                      final Offset offset = button.localToGlobal(Offset.zero);
                                      final Size size = button.size;
                                      showMenu<String>(
                                        context: context,
                                        position: RelativeRect.fromLTRB(
                                          offset.dx,
                                          offset.dy + size.height,
                                          offset.dx + 1,
                                          0,
                                        ),
                                        items: [
                                          const PopupMenuItem(value: 'alphabetical', child: Text('Alfabetik')),
                                          const PopupMenuItem(value: 'lowScore', child: Text('Düşük Puan')),
                                          const PopupMenuItem(value: 'highScore', child: Text('Yüksek Puan')),
                                        ],
                                      ).then((value) {
                                        if (value != null) {
                                          setState(() {
                                            _sortType = value;
                                          });
                                        }
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Filtrele butonu (artık sonra)
                                SizedBox(
                                  height: 40,
                                  key: _filterButtonKey,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppColors.primary,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                                    ),
                                    icon: const Icon(Icons.filter_list, size: 20, color: AppColors.primary),
                                    label: const Text('Filtrele', style: TextStyle(color: AppColors.primary)),
                                    onPressed: _showFilterPopup,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: getFilteredUniversityBranches().isEmpty
                            ? const Center(
                                child: Text('Sonuç bulunamadı', style: AppTextStyles.bodyLarge),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: getFilteredUniversityBranches().length,
                                itemBuilder: (context, idx) {
                                  final item = getFilteredUniversityBranches()[idx];
                                  final isAdded = preferences.any((p) => p['university'] == item['university'] && p['branch'] == item['branch']);
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    color: AppColors.surface,
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(item['branch'] ?? '-', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.textOnPrimary)),
                                                const SizedBox(height: 4),
                                                Text(item['university'] ?? '-', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textOnPrimary)),
                                                Text(item['city'] ?? '-', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textOnPrimary)),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              isAdded ? Icons.check_circle : Icons.add_circle_outline,
                                              color: isAdded ? Colors.grey : AppColors.textOnPrimary,
                                            ),
                                            tooltip: isAdded ? 'Zaten eklendi' : 'Tercihe ekle',
                                            onPressed: isAdded ? null : () => addPreference(item),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                  // Tercih Listeniz Paneli
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: () => setState(() => _isPreferenceListOpen = !_isPreferenceListOpen),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: const Border(
                            top: BorderSide(color: AppColors.primary, width: 2),
                          ),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        height: _isPreferenceListOpen ? 290 : 60,
                        child: Column(
                          children: [
                            Container(
                              height: 56,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Tercih Listeniz (${preferences.length})', style: AppTextStyles.titleMedium.copyWith(color: AppColors.textOnPrimary)),
                                  Icon(_isPreferenceListOpen ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up, color: AppColors.textOnPrimary, size: 32),
                                ],
                              ),
                            ),
                            if (_isPreferenceListOpen)
                              SizedBox(
                                height: 204, // 260 - 56
                                child: preferences.isEmpty
                                    ? Center(
                                        child: Text('Henüz tercih eklemediniz.', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textOnPrimary)),
                                      )
                                    : ReorderableListView.builder(
                                        itemCount: preferences.length,
                                        onReorder: reorderPreference,
                                        itemBuilder: (context, index) {
                                          final p = preferences[index];
                                          return Card(
                                            key: ValueKey('tercih_$index'),
                                            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                            color: AppColors.surface,
                                            elevation: 1,
                                            child: ListTile(
                                              leading: ReorderableDragStartListener(
                                                index: index,
                                                child: const Icon(Icons.drag_handle, color: AppColors.textOnPrimary),
                                              ),
                                              title: Text(
                                                '${p['university'] ?? '-'}',
                                                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textOnPrimary, fontWeight: FontWeight.w500),
                                              ),
                                              subtitle: Text(
                                                '${p['city'] ?? ''} - ${p['branch'] ?? '-'}',
                                                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textOnPrimary),
                                              ),
                                              trailing: IconButton(
                                                icon: const Icon(Icons.remove_circle_outline, color: AppColors.textOnPrimary),
                                                tooltip: 'Tercihi Sil',
                                                onPressed: () => removePreference(index),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
} 