// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:tus/core/data/tus_data_loader.dart';


import '../../../../config/theme/app_colors.dart';
import '../../../../config/theme/app_text_styles.dart';

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
  Map<String, dynamic>? tusData;

  @override
  void initState() {
    super.initState();
    TusDataLoader.loadTusData().then((data) {
      setState(() {
        tusData = data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (tusData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final List<dynamic> kontenjanlar = tusData!["sonTusToplamKontenjanlar"];
    final List<dynamic> bransKontenjanDegisimleri = tusData!["secilmisUzmanlikDallariKontenjanDegisimleri"];
    final List<String> branslar = bransKontenjanDegisimleri.map<String>((e) => e["brans"] as String).toList();

    // Dönemleri çıkar (ör: 2025 Mart, 2024 Ağustos ...)
    final List<String> donemler = kontenjanlar.map<String>((e) => e["tusDonemi"] as String).toList();
    String selectedDonem = donemler.isNotEmpty ? donemler.first : "";

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StatefulBuilder(
        builder: (context, setStateSB) {
          return Column(
            children: [
              // Dönem kartları (tıklanabilir)
              SizedBox(
                height: 70,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  itemCount: kontenjanlar.length,
                  itemBuilder: (context, index) {
                    final item = kontenjanlar[index];
                    final isSelected = item["tusDonemi"] == selectedDonem;
                    return GestureDetector(
                      onTap: () {
                        setStateSB(() {
                          selectedDonem = item["tusDonemi"];
                        });
                      },
                      child: Card(
                        color: isSelected ? AppColors.primary : AppColors.surface,
                        elevation: isSelected ? 3 : 1,
                        margin: const EdgeInsets.only(right: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: isSelected ? AppColors.primaryDark : AppColors.border, width: isSelected ? 2 : 1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item["tusDonemi"] ?? "-",
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Seçili döneme ait branş/kontenjan tablosu
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: _buildDonemBransTablo(bransKontenjanDegisimleri, selectedDonem),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDonemBransTablo(List<dynamic> bransKontenjanDegisimleri, String selectedDonem) {
    // Dönem stringini kontenjan anahtarına çevir (ör: 2025 Mart -> kontenjan2025Mart)
    String donemKey = selectedDonem
        .replaceAll(" ", "")
        .replaceAll("ı", "i")
        .replaceAll("ğ", "g")
        .replaceAll("ü", "u")
        .replaceAll("ş", "s")
        .replaceAll("ö", "o")
        .replaceAll("ç", "c")
        .replaceAll("İ", "I")
        .replaceAll("Ğ", "G")
        .replaceAll("Ü", "U")
        .replaceAll("Ş", "S")
        .replaceAll("Ö", "O")
        .replaceAll("Ç", "C");
    donemKey = "kontenjan$donemKey";

    // Tüm branşları aktifTusUzmanlikDallariListesi'nden çek
    final tusData = this.tusData;
    final Map<String, dynamic> aktifBranslar = tusData?["aktifTusUzmanlikDallariListesi"] ?? {};
    final List<String> allBranslar = [
      ...((aktifBranslar["dahiliTipBilimleri"] ?? []) as List),
      ...((aktifBranslar["cerrahiTipBilimleri"] ?? []) as List),
    ];

    // Her branş için o dönemin kontenjanını bul (veya -)
    final List<Map<String, dynamic>> rows = allBranslar.map<Map<String, dynamic>>((brans) {
      final found = bransKontenjanDegisimleri.firstWhere(
        (e) => (e["brans"] ?? "").toString().toLowerCase() == brans.toString().toLowerCase(),
        orElse: () => null,
      );
      return {
        "brans": brans,
        "kontenjan": found != null ? found[donemKey] : '-',
      };
    }).toList();

    // Toplam kontenjanı bul
    int toplamKontenjan = 0;
    for (final row in rows) {
      final val = int.tryParse(row["kontenjan"].toString());
      if (val != null) toplamKontenjan += val;
    }

    // Puan verilerini hazırla (taban/tavan)
    final puanAnalizi = tusData?["gecmisTusPuanAnalizi"];
    Map<String, Map<String, dynamic>> bransPuanMap = {};
    if (puanAnalizi != null) {
      if (puanAnalizi["yokKontenjanPuanAraliklari2022BirinciDonem"] != null) {
        for (final p in List<Map<String, dynamic>>.from(puanAnalizi["yokKontenjanPuanAraliklari2022BirinciDonem"])) {
          bransPuanMap[p["brans"]?.toString().toLowerCase() ?? ""] = {
            "taban": p["tabanPuan"],
            "tavan": p["tavanPuan"],
          };
        }
      }
      if (puanAnalizi["tahminiPuanAraliklari2024Eylul"] != null) {
        for (final p in List<Map<String, dynamic>>.from(puanAnalizi["tahminiPuanAraliklari2024Eylul"])) {
          bransPuanMap[p["brans"]?.toString().toLowerCase() ?? ""] = {
            "taban": p["tahminiTabanPuan"],
            "tavan": p["tahminiTavanPuan"],
          };
        }
      }
    }

    if (rows.isEmpty) {
      return Center(
        child: Text('Bu döneme ait branş kontenjanı verisi yok.', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error)),
      );
    }

    return Card(
      color: AppColors.primaryLight,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.primary, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    '$selectedDonem\nUzmanlık Kontenjanları',
                    style: AppTextStyles.titleMedium.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Toplam: $toplamKontenjan',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(3),
                      1: FlexColumnWidth(2),
                      2: FlexColumnWidth(1),
                      3: FlexColumnWidth(1),
                      4: FlexColumnWidth(1),
                    },
                    border: TableBorder.symmetric(inside: BorderSide(color: AppColors.border.withOpacity(0.3))),
                    children: [
                      TableRow(
                        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15)),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text('Branş', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text('Kontenjan', textAlign: TextAlign.center, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text('Min Puan', textAlign: TextAlign.center, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text('Max Puan', textAlign: TextAlign.center, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                          ),
                          const SizedBox(),
                        ],
                      ),
                      ...rows.map((row) {
                        final puan = bransPuanMap[row["brans"]?.toString().toLowerCase() ?? ""];
                        final kontenjan = row["kontenjan"] ?? '-';
                        return TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Text(row["brans"], style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Text(kontenjan.toString(), textAlign: TextAlign.center, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Text(puan != null ? (puan["taban"]?.toString() ?? '-') : '-', textAlign: TextAlign.center, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Text(puan != null ? (puan["tavan"]?.toString() ?? '-') : '-', textAlign: TextAlign.center, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: IconButton(
                                icon: const Icon(Icons.info_outline, color: AppColors.primaryDark, size: 20),
                                tooltip: 'Hastanelere göre kontenjan',
                                onPressed: () {
                                  _showHospitalQuotaModal(row["brans"], selectedDonem);
                                },
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHospitalQuotaModal(String brans, String donem) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      builder: (context) {
        final tusData = this.tusData;
        final bransObj = tusData!["secilmisUzmanlikDallariKontenjanDegisimleri"]
            .firstWhere((e) => e["brans"] == brans, orElse: () => null);
        final puanAnalizi = tusData["gecmisTusPuanAnalizi"];
        final egitimSuresiObj = tusData["uzmanlikDallariVeEgitimSureleri"]
            .firstWhere((e) => e["uzmanlikDali"].toString().contains(brans), orElse: () => null);
        final List<dynamic> allHospitalsRaw = tusData["eahVeSehirHastaneleriOrnekler"] ?? [];
        final List<dynamic> allUniversitiesRaw = tusData["tusEgitimiVerenUniversiteTipFakulteleriOrnekler"] ?? [];
        // Hastaneler
        final List<Map<String, String>> allHospitals = allHospitalsRaw.map<Map<String, String>>((h) => {
          "kurum": h["hastaneAdi"] ?? h["il"] ?? "-",
          "fakulte": h["afiliyeOlduguFakulte_SBU"] ?? "-",
        }).toList();
        // Üniversite/Fakülteler
        final List<Map<String, String>> allUniversities = allUniversitiesRaw.map<Map<String, String>>((u) => {
          "kurum": (u["universiteAdi"] != null && u["tipFakultesiAdi"] != null)
              ? "${u["universiteAdi"]} - ${u["tipFakultesiAdi"]}"
              : (u["universiteAdi"] ?? u["tipFakultesiAdi"] ?? u["sehir"] ?? "-"),
          "kurulus": u["kurumTuru"] ?? u["kurulusTipi"] ?? "YÖK",
        }).toList();
        // Tek bir listeye birleştir, tekrarları önle
        final Set<String> kurumSet = {};
        final List<Map<String, String>> allKurumlar = [];
        for (final h in [...allHospitals, ...allUniversities]) {
          if (!kurumSet.contains(h["kurum"])) {
            kurumSet.add(h["kurum"] ?? "");
            allKurumlar.add(h);
          }
        }
        return DefaultTabController(
          length: 2,
          child: Padding(
            padding: EdgeInsets.only(
              left: 20, right: 20, top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_hospital, color: AppColors.primaryDark),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('$brans - $donem', style: AppTextStyles.titleLarge.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                if (egitimSuresiObj != null) ...[
                  const SizedBox(height: 6),
                  Text('Kategori: ${egitimSuresiObj["kategori"]}', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint)),
                  Text('Eğitim Süresi: ${egitimSuresiObj["egitimSuresiYil"]} yıl', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint)),
                ],
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    labelColor: AppColors.primaryDark,
                    unselectedLabelColor: AppColors.textSecondary,
                    indicator: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tabs: const [
                      Tab(text: 'Kontenjan Değişimi'),
                      Tab(text: 'Hastaneler'),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 320,
                  child: TabBarView(
                    children: [
                      SingleChildScrollView(
                        child: _buildBransKontenjanDegisimTablo(bransObj),
                      ),
                      SingleChildScrollView(
                        child: _buildHospitalTableWithPuan(allKurumlar, brans, puanAnalizi),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBransKontenjanDegisimTablo(Map<String, dynamic>? bransObj) {
    if (bransObj == null) {
      return Text('Veri yok', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error));
    }
    final yearEntries = bransObj.entries.where((e) => e.key.startsWith('kontenjan')).toList();
    yearEntries.sort((a, b) => b.key.compareTo(a.key));
    return Table(
      columnWidths: const {0: FlexColumnWidth(2), 1: FlexColumnWidth(1)},
      border: TableBorder.symmetric(inside: BorderSide(color: AppColors.border.withOpacity(0.3))),
      children: [
        TableRow(
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15)),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('Dönem', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('Kontenjan', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ),
          ],
        ),
        ...yearEntries.map((e) => TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(e.key.replaceFirst('kontenjan', ''), style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(e.value.toString(), style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
            ),
          ],
        )),
      ],
    );
  }

  Widget _buildHospitalTableWithPuan(List<Map<String, String>> hospitals, String brans, Map<String, dynamic> puanAnalizi) {
    // Hastane/branş bazlı puanları hazırla
    final List<Map<String, dynamic>> hastanePuanlar = [];
    puanAnalizi.forEach((key, value) {
      if (value is Map && value.containsKey("tabanPuan") && value.containsKey("tavanPuan")) {
        if (key.toLowerCase().contains(brans.toLowerCase().replaceAll(' ', ''))) {
          hastanePuanlar.add({
            "hastane": key,
            "tabanPuan": value["tabanPuan"],
            "tavanPuan": value["tavanPuan"],
          });
        }
      }
    });
    // Tüm kuruluşları tusData'dan çek (hastane, üniversite, fakülte)
    final tusData = this.tusData;
    final List<dynamic> allHospitalsRaw = tusData?["eahVeSehirHastaneleriOrnekler"] ?? [];
    final List<dynamic> allUniversitiesRaw = tusData?["tusEgitimiVerenUniversiteTipFakulteleriOrnekler"] ?? [];
    // Hastaneler
    final List<Map<String, String>> allHospitals = allHospitalsRaw.map<Map<String, String>>((h) => {
      "kurum": h["hastaneAdi"] ?? h["il"] ?? "-",
      "fakulte": h["afiliyeOlduguFakulte_SBU"] ?? "-",
    }).toList();
    // Üniversite/Fakülteler
    final List<Map<String, String>> allUniversities = allUniversitiesRaw.map<Map<String, String>>((u) => {
      "kurum": (u["universiteAdi"] != null && u["tipFakultesiAdi"] != null)
          ? "${u["universiteAdi"]} - ${u["tipFakultesiAdi"]}"
          : (u["universiteAdi"] ?? u["tipFakultesiAdi"] ?? u["sehir"] ?? "-"),
      "kurulus": u["universiteAdi"] ?? u["kurulusTipi"] ?? "YÖK",
    }).toList();
    // Tek bir listeye birleştir, tekrarları önle
    final Set<String> kurumSet = {};
    final List<Map<String, String>> allKurumlar = [];
    for (final h in [...allHospitals, ...allUniversities]) {
      if (!kurumSet.contains(h["kurum"])) {
        kurumSet.add(h["kurum"] ?? "");
        allKurumlar.add(h);
      }
    }
    return Table(
      columnWidths: const {0: FlexColumnWidth(3), 1: FlexColumnWidth(2), 2: FlexColumnWidth(1), 3: FlexColumnWidth(1)},
      border: TableBorder.symmetric(inside: BorderSide(color: AppColors.border.withOpacity(0.3))),
      children: [
        TableRow(
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15)),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('Kurum', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('Bağlı Kuruluş', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('Min Puan', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text('Max Puan', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ),
          ],
        ),
        ...allKurumlar.map((h) {
          final puan = hastanePuanlar.firstWhere(
            (p) => (p["hastane"]?.toString().toLowerCase() ?? "").contains((h["kurum"] ?? "").toLowerCase()),
            orElse: () => {},
          );
          return TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(h["kurum"] ?? '-', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(h["kurulus"] ?? h["fakulte"] ?? '-', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(puan.isNotEmpty ? (puan["tabanPuan"]?.toString() ?? '-') : '-', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(puan.isNotEmpty ? (puan["tavanPuan"]?.toString() ?? '-') : '-', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary)),
              ),
            ],
          );
        }),
      ],
    );
  }
} 