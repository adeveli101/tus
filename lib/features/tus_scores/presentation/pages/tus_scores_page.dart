// ignore_for_file: unused_import, unnecessary_type_check

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';
import '../../data/datasources/tus_scores_supabase_data_source.dart';
import '../../domain/entities/brans.dart';
import '../../domain/entities/donem.dart';
import '../../domain/entities/tus_veri_ana.dart';

class TusScoresPage extends StatefulWidget {
  final Function(int) onPageChanged;
  
  const TusScoresPage({
    super.key,
    required this.onPageChanged,
  });

  @override
  State<TusScoresPage> createState() => _TusScoresPageState();
}

class _TusScoresPageState extends State<TusScoresPage> {
  final TusScoresSupabaseDataSource supabaseDataSource = TusScoresSupabaseDataSource();

  List<Donem> donemler = [];
  List<Brans> branslar = [];
  List<Map<String, dynamic>> kurumlar = [];
  List<TusVeriAna> tusVerileri = [];

  Donem? selectedDonem;
  Brans? selectedBrans;
  Map<String, dynamic>? selectedKurum;

  String? error;
  bool kurumlarLoading = false;
  // ignore: prefer_final_fields
  bool _summaryExpanded = true;

  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      final donemlerResponse = await supabaseDataSource.getDonemler();
      final branslarResponse = await supabaseDataSource.getBranslar();
      Donem? latestDonem;
      if (donemlerResponse.isNotEmpty) {
        latestDonem = donemlerResponse.reduce((a, b) {
          if (a.sinavyili > b.sinavyili) return a;
          if (a.sinavyili < b.sinavyili) return b;
          return a.sinavdonemiadi.compareTo(b.sinavdonemiadi) > 0 ? a : b;
        });
      }
      setState(() {
        donemler = donemlerResponse;
        branslar = branslarResponse;
        selectedDonem = latestDonem;
        selectedBrans = null;
        selectedKurum = null;
        kurumlar = [];
        tusVerileri = [];
      });
      if (latestDonem != null) {
        await _loadKurumlar(latestDonem);
        await _loadTusVerileri();
      }
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }

  Future<void> _loadKurumlar(Donem donem) async {
    setState(() {
      kurumlarLoading = true;
    });
    try {
      final kurumlarResponse = await supabaseDataSource.getKurumlarByDonem(donem);
      setState(() {
        kurumlar = kurumlarResponse;
        selectedKurum = null;
        kurumlarLoading = false;
      });
    } catch (e) {
      setState(() {
        kurumlar = [];
        selectedKurum = null;
        kurumlarLoading = false;
      });
    }
  }

  Future<void> _loadTusVerileri() async {
    if (selectedDonem == null) {
      setState(() {
        tusVerileri = [];
      });
      return;
    }
    setState(() {
      error = null;
    });
    try {
      final tusVeriResponse = await supabaseDataSource.getTusVerileriAnaFiltered(
        donemId: selectedDonem?.donemid,
        bransId: selectedBrans?.bransid,
        kurumId: selectedKurum != null ? selectedKurum!["id"] as int : null,
      );
      setState(() {
        tusVerileri = tusVeriResponse;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
            backgroundColor: Colors.transparent,
          );
        }
        if (error != null) {
          return const Scaffold(
            body: Center(child: Text('Hata oluştu')),
            backgroundColor: Colors.transparent,
          );
        }
        if (donemler.isEmpty || branslar.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Veri yok.')),
            backgroundColor: Colors.transparent,
          );
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: donemler.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final donem = donemler[index];
                      final isSelected = selectedDonem?.donemid == donem.donemid;
                      return ChoiceChip(
                        label: Text('${donem.sinavyili} - ${donem.sinavdonemiadi}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surface,
                        onSelected: (selected) async {
                          if (isSelected) {
                            setState(() {
                              selectedDonem = null;
                              kurumlar = [];
                              selectedKurum = null;
                            });
                            await _loadTusVerileri();
                          } else {
                            setState(() {
                              selectedDonem = donem;
                              kurumlar = [];
                              selectedKurum = null;
                            });
                            await _loadKurumlar(donem);
                            await _loadTusVerileri();
                          }
                        },
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: isSelected ? 2 : 0,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Flexible(
                      flex: 3,
                      child: _buildDropdown<Brans>(
                        label: 'Branş',
                        value: selectedBrans,
                        items: <Brans?>[null, ...[...branslar]..sort((a, b) => a!.bransadi.compareTo(b!.bransadi))],
                        getLabel: (b) => b == null ? 'Branş seçiniz' : b.bransadi,
                        onChanged: (b) async {
                          setState(() { selectedBrans = b; });
                          await _loadTusVerileri();
                        },
                        isExpanded: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      flex: 4,
                      child: kurumlarLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildDropdown<Map<String, dynamic>>(
                            label: 'Kurum',
                            value: selectedKurum,
                            items: <Map<String, dynamic>?>[null, ...kurumlar],
                            getLabel: (k) => k == null ? 'Kurum seçiniz' : (k["kurum_adi"] ?? '-'),
                            onChanged: (k) async {
                              setState(() { selectedKurum = k; });
                              await _loadTusVerileri();
                            },
                            isExpanded: true,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSummary(),
                const SizedBox(height: 16),
                Expanded(child: _buildTable()),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T? value,
    required List<T?> items,
    required String Function(T?) getLabel,
    required ValueChanged<T?> onChanged,
    bool isExpanded = false,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.primary.withOpacity(0.25), width: 1.2)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppColors.primary.withOpacity(0.25), width: 1.2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      hint: Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
      dropdownColor: AppColors.surface,
      isExpanded: isExpanded,
      items: items.map((item) => DropdownMenuItem<T>(
        value: item,
        child: Text(
          getLabel(item),
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
        ),
      )).toList(),
      onChanged: onChanged,
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
      iconEnabledColor: AppColors.textPrimary,
      selectedItemBuilder: (context) => items.map((item) {
        return Align(
          alignment: Alignment.centerLeft,
          child: Text(
            getLabel(item),
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSummary() {
    if (tusVerileri.isEmpty) {
      return const Text('Seçilen filtrelere ait veri bulunamadı.', style: TextStyle(color: Colors.redAccent));
    }
    int toplamKontenjan = tusVerileri.fold(0, (sum, v) => sum + (v.kontenjanSayisi ?? 0));
    int toplamYerlesen = tusVerileri.fold(0, (sum, v) => sum + (v.yerlesenSayisi ?? 0));
    int toplamBos = tusVerileri.fold(0, (sum, v) => sum + (v.bosKalanSayisi ?? 0));
    double? minTaban = tusVerileri.map((v) => v.tabanPuan).whereType<double>().fold<double?>(null, (min, p) => min == null ? p : (p < min ? p : min));
    double? maxTavan = tusVerileri.map((v) => v.tavanPuan).whereType<double>().fold<double?>(null, (max, p) => max == null ? p : (p > max ? p : max));
    return Card(
      color: AppColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: AppColors.primary.withOpacity(0.25), width: 1.2),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSummaryItem('Kontenjan', toplamKontenjan.toString(), icon: Icons.people_alt_outlined),
            _buildSummaryItem('Yerleşen', toplamYerlesen.toString(), icon: Icons.check_circle_outline),
            _buildSummaryItem('Boş', toplamBos.toString(), icon: Icons.remove_circle_outline),
            _buildSummaryItem('Min Taban', minTaban?.toStringAsFixed(2) ?? '-', icon: Icons.arrow_downward),
            _buildSummaryItem('Max Tavan', maxTavan?.toStringAsFixed(2) ?? '-', icon: Icons.arrow_upward),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, {IconData? icon}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontSize: 13)),
      ],
    );
  }

  Widget _buildTable() {
    if (tusVerileri.isEmpty) {
      return const Center(child: Text('Tablo verisi yok.', style: TextStyle(color: AppColors.textPrimary)));
    }
    final sortedTusVerileri = [...tusVerileri];
    // ignore: unnecessary_null_comparison
    final kurumlarForTable = kurumlar.where((k) => k != null).cast<Map<String, dynamic>>().toList();
    final Map<int, String> kurumIdToAdi = {
      for (var k in kurumlarForTable)
        if (k['id'] is int && k['kurum_adi'] is String) k['id'] as int : k['kurum_adi'] as String
    };
    final Map<int, String> bransIdToAdi = {
      for (var b in branslar)
        if (b.bransadi is String) b.bransid : b.bransadi
    };
    sortedTusVerileri.sort((a, b) {
      final kurumA = kurumIdToAdi[a.kurumId is int ? a.kurumId : int.tryParse(a.kurumId.toString())] ?? '';
      final kurumB = kurumIdToAdi[b.kurumId is int ? b.kurumId : int.tryParse(b.kurumId.toString())] ?? '';
      return kurumA.compareTo(kurumB);
    });

    const double kurumWidth = 110;
    const double bransWidth = 110;
    const double smallWidth = 70;
    const double ozelWidth = 130;
    const double cellHeight = 38;
    const headerStyle = TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.bold);
    const cellStyle = TextStyle(color: AppColors.textPrimary, fontSize: 11, height: 1.2);
    const cellPadding = EdgeInsets.symmetric(horizontal: 6, vertical: 4);
    const borderColor = AppColors.primaryLight;

    Widget buildCell(String text, double width, {int? maxLines, bool bold = false, bool center = false, bool isHeader = false, bool isOzel = false}) {
      return Container(
        width: width,
        height: null,
        alignment: center ? Alignment.center : Alignment.centerLeft,
        padding: isHeader
            ? cellPadding
            : const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        color: isHeader ? AppColors.primaryLight.withOpacity(0.7) : null,
        child: Text(
          text,
          maxLines: isOzel ? 2 : 1,
          overflow: isOzel ? TextOverflow.ellipsis : TextOverflow.ellipsis,
          softWrap: isOzel,
          style: (isHeader ? headerStyle : cellStyle).copyWith(fontWeight: bold ? FontWeight.bold : FontWeight.normal),
        ),
      );
    }

    Widget buildRow(List<Widget> cells, {bool isHeader = false}) {
      final List<Widget> rowChildren = [];
      for (int i = 0; i < cells.length; i++) {
        rowChildren.add(cells[i]);
        if (i != cells.length - 1) {
          rowChildren.add(Container(
            width: isHeader ? 8.0 : 1.0,
            height: null,
            color: borderColor.withOpacity(isHeader ? 0.7 : 0.4),
          ));
        }
      }
      return IntrinsicHeight(child: Row(children: rowChildren));
    }

    const int minRows = 3;
    final int rowCount = sortedTusVerileri.length < minRows ? minRows : sortedTusVerileri.length;
    final double tableHeight = cellHeight * (rowCount + 1) + 2;

    return Card(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: AppColors.primary.withOpacity(0.18), width: 1),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: kurumWidth + bransWidth + smallWidth * 7 + ozelWidth + 16 + 56,
              height: tableHeight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildRow([
                    buildCell('Kurum', kurumWidth, bold: true, isHeader: true),
                    buildCell('Branş', bransWidth, bold: true, isHeader: true),
                    buildCell('Kont.', smallWidth, bold: true, center: true, isHeader: true),
                    buildCell('Kont. Türü', smallWidth, bold: true, center: true, isHeader: true),
                    buildCell('Puan Türü', smallWidth, bold: true, center: true, isHeader: true),
                    buildCell('Taban', smallWidth, bold: true, center: true, isHeader: true),
                    buildCell('Yerleşen', smallWidth, bold: true, center: true, isHeader: true),
                    buildCell('Boş', smallWidth, bold: true, center: true, isHeader: true),
                    buildCell('Tavan', smallWidth, bold: true, center: true, isHeader: true),
                    buildCell('Özel', ozelWidth, bold: true, isHeader: true),
                  ], isHeader: true),
                  const Divider(height: 1, thickness: 1.2, color: borderColor),
                  Flexible(
                    child: ListView.builder(
                      itemCount: rowCount,
                      itemBuilder: (context, index) {
                        if (index >= sortedTusVerileri.length) {
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            color: index % 2 == 0 ? AppColors.surface : AppColors.primary.withOpacity(0.13),
                            child: buildRow(List.generate(10, (i) => buildCell('', [kurumWidth, bransWidth, smallWidth, smallWidth, smallWidth, smallWidth, smallWidth, smallWidth, smallWidth, ozelWidth][i]))),
                          );
                        }
                        final v = sortedTusVerileri[index];
                        final tusKurumId = v.kurumId is int ? v.kurumId : int.tryParse(v.kurumId.toString());
                        final kurumAdi = kurumIdToAdi[tusKurumId] ?? '-';
                        final bransAdi = bransIdToAdi[v.bransId] ?? '-';
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: index % 2 == 0
                              ? AppColors.surface
                              : AppColors.primary.withOpacity(0.13),
                          child: buildRow([
                            buildCell(kurumAdi, kurumWidth),
                            buildCell(bransAdi, bransWidth),
                            buildCell(v.kontenjanSayisi?.toString() ?? '-', smallWidth, center: true),
                            buildCell(v.kontenjanTuru, smallWidth, center: true),
                            buildCell(v.puanTuru, smallWidth, center: true),
                            buildCell(v.tabanPuan?.toStringAsFixed(2) ?? '-', smallWidth, center: true),
                            buildCell(v.yerlesenSayisi?.toString() ?? '-', smallWidth, center: true),
                            buildCell(v.bosKalanSayisi?.toString() ?? '-', smallWidth, center: true),
                            buildCell(v.tavanPuan?.toStringAsFixed(2) ?? '-', smallWidth, center: true),
                            buildCell(v.ozelKosul ?? '-', ozelWidth, isOzel: true),
                          ]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 