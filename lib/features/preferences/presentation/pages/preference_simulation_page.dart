// ignore_for_file: unnecessary_cast

import 'package:flutter/material.dart';
import 'package:tus/config/router/app_routes.dart';
import 'package:tus/config/theme/app_colors.dart';
import 'package:tus/config/theme/app_text_styles.dart';
import 'preference_simulation_results_page.dart';
import 'package:tus/core/data/tus_data_loader.dart';

class PreferenceSimulationPage extends StatefulWidget {
  const PreferenceSimulationPage({super.key});

  @override
  State<PreferenceSimulationPage> createState() => _PreferenceSimulationPageState();
}

class _PreferenceSimulationPageState extends State<PreferenceSimulationPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedBranch;
  String? _selectedCity;
  String? _selectedInstitutionType;
  String? _selectedQuotaType;
  String? _selectedUniversity;
  String? _selectedFaculty;
  String? _selectedHospital;
  String? _selectedAffiliatedFaculty;
  final TextEditingController _scoreController = TextEditingController();
  final TextEditingController _rankController = TextEditingController();
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

    // Branş listesi
    final List<String> allBranches = [
      ...List<String>.from(tusData!["aktifTusUzmanlikDallariListesi"]["dahiliTipBilimleri"]),
      ...List<String>.from(tusData!["aktifTusUzmanlikDallariListesi"]["cerrahiTipBilimleri"]),
      ...List<String>.from(tusData!["aktifTusUzmanlikDallariListesi"]["temelTipBilimleri"]),
    ];

    // Şehir listesi (üniversite ve hastane şehirlerinin birleşimi, tekrarları kaldır)
    final Set<String> allCities = {
      ...tusData!["tusEgitimiVerenUniversiteTipFakulteleriOrnekler"].map<String>((u) => u["sehir"] as String),
      ...tusData!["eahVeSehirHastaneleriOrnekler"].map<String>((h) => h["il"] as String),
    };

    // Seçili kurum türüne göre şehirler
    List<String> filteredCities = [];
    if (_selectedInstitutionType == 'universite') {
      filteredCities = tusData!["tusEgitimiVerenUniversiteTipFakulteleriOrnekler"]
        .map<String>((u) => u["sehir"] as String).toSet().toList();
    } else if (_selectedInstitutionType == 'eah') {
      filteredCities = tusData!["eahVeSehirHastaneleriOrnekler"]
        .map<String>((h) => h["il"] as String).toSet().toList();
    }

    // Seçili şehir ve kurum türüne göre üniversiteler
    List<Map<String, dynamic>> filteredUniversities = [];
    if (_selectedInstitutionType == 'universite' && _selectedCity != null) {
      filteredUniversities = tusData!["tusEgitimiVerenUniversiteTipFakulteleriOrnekler"]
        .where((u) => u["sehir"] == _selectedCity).toList().cast<Map<String, dynamic>>();
    }

    // Seçili şehir ve kurum türüne göre hastaneler
    List<Map<String, dynamic>> filteredHospitals = [];
    if (_selectedInstitutionType == 'eah' && _selectedCity != null) {
      filteredHospitals = tusData!["eahVeSehirHastaneleriOrnekler"]
        .where((h) => h["il"] == _selectedCity).toList().cast<Map<String, dynamic>>();
    }

    // Seçili üniversiteye göre fakülte
    String? selectedFaculty;
    if (_selectedUniversity != null) {
      final uni = filteredUniversities.firstWhere(
        (u) => u["universiteAdi"] == _selectedUniversity,
        orElse: () => {},
      );
      selectedFaculty = uni["tipFakultesiAdi"] as String?;
    }

    // Seçili hastaneye göre afiliye fakülte
    String? selectedAffiliatedFaculty;
    if (_selectedHospital != null) {
      final hos = filteredHospitals.firstWhere(
        (h) => h["hastaneAdi"] == _selectedHospital,
        orElse: () => {},
      );
      selectedAffiliatedFaculty = hos["afiliyeOlduguFakulte_SBU"] as String?;
    }

    // Seçili branşa göre eğitim süresi
    String? selectedBranchEducation;
    if (_selectedBranch != null) {
      final egitim = (tusData!["uzmanlikDallariVeEgitimSureleri"] as List)
          .firstWhere((e) => e["uzmanlikDali"] == _selectedBranch, orElse: () => null);
      selectedBranchEducation = egitim?['egitimSuresiYil'];
    }

    // Seçili branşa göre dönemsel kontenjanlar
    Map<String, int> selectedBranchQuotas = {};
    if (_selectedBranch != null) {
      final bransObj = (tusData!["secilmisUzmanlikDallariKontenjanDegisimleri"] as List)
          .firstWhere((e) => e["brans"] == _selectedBranch, orElse: () => null);
      if (bransObj != null) {
        bransObj.forEach((key, value) {
          if (key.startsWith('kontenjan') && value != null) {
            selectedBranchQuotas[key.replaceFirst('kontenjan', '')] = value;
          }
        });
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryLight,
        title: Text(
          'Tercih Simülasyonu',
          style: AppTextStyles.titleLarge.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: AppColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Giriş Parametreleri
              Card(
                color: AppColors.surface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Giriş Parametreleri', style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _scoreController,
                        decoration: InputDecoration(
                          labelText: 'TUS Puanı',
                          labelStyle: const TextStyle(color: AppColors.textOnPrimary),
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                        style: const TextStyle(color: AppColors.textPrimary),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _rankController,
                        decoration: InputDecoration(
                          labelText: 'Sıralama',
                          labelStyle: const TextStyle(color: AppColors.textSecondary),
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                        style: const TextStyle(color: AppColors.textPrimary),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Filtreleme Seçenekleri
              Card(
                color: AppColors.surface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Filtreleme Seçenekleri', style: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedBranch,
                        decoration: InputDecoration(
                          labelText: 'Branş',
                          labelStyle: const TextStyle(color: AppColors.textSecondary),
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                        dropdownColor: AppColors.surface,
                        style: const TextStyle(color: AppColors.textPrimary),
                        items: allBranches.map((b) => DropdownMenuItem<String>(value: b, child: Text(b))).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedBranch = value;
                          });
                        },
                      ),
                      if (_selectedBranch != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('Eğitim Süresi: ${selectedBranchEducation ?? '-'} yıl', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      if (_selectedBranch != null && selectedBranchQuotas.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Dönemsel Kadro Sayıları:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Table(
                                columnWidths: const {0: IntrinsicColumnWidth(), 1: IntrinsicColumnWidth()},
                                children: selectedBranchQuotas.entries.map((entry) => TableRow(children: [
                                  Padding(padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4), child: Text(entry.key, style: const TextStyle(fontSize: 13))),
                                  Padding(padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 4), child: Text('${entry.value} kadro', style: const TextStyle(fontSize: 13))),
                                ])).toList(),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedInstitutionType,
                        decoration: InputDecoration(
                          labelText: 'Kurum Türü',
                          labelStyle: const TextStyle(color: AppColors.textSecondary),
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                        dropdownColor: AppColors.surface,
                        style: const TextStyle(color: AppColors.textPrimary),
                        items: const [
                          DropdownMenuItem(value: 'universite', child: Text('Üniversite Hastanesi')),
                          DropdownMenuItem(value: 'eah', child: Text('Eğitim ve Araştırma/Şehir Hastanesi')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedInstitutionType = value;
                            _selectedCity = null;
                            _selectedUniversity = null;
                            _selectedFaculty = null;
                            _selectedHospital = null;
                            _selectedAffiliatedFaculty = null;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedCity,
                        decoration: InputDecoration(
                          labelText: 'Şehir',
                          labelStyle: const TextStyle(color: AppColors.textSecondary),
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                        dropdownColor: AppColors.surface,
                        style: const TextStyle(color: AppColors.textPrimary),
                        items: filteredCities.map((city) => DropdownMenuItem<String>(value: city, child: Text(city))).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCity = value;
                            _selectedUniversity = null;
                            _selectedFaculty = null;
                            _selectedHospital = null;
                            _selectedAffiliatedFaculty = null;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      if (_selectedInstitutionType == 'universite' && _selectedCity != null)
                        DropdownButtonFormField<String>(
                          value: _selectedUniversity,
                          decoration: InputDecoration(
                            labelText: 'Üniversite',
                            labelStyle: const TextStyle(color: AppColors.textSecondary),
                            filled: true,
                            fillColor: AppColors.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.primary),
                            ),
                          ),
                          dropdownColor: AppColors.surface,
                          style: const TextStyle(color: AppColors.textPrimary),
                          items: filteredUniversities.map((u) => DropdownMenuItem<String>(value: u['universiteAdi'] as String, child: Text('${u['universiteAdi']} (${u['sehir']})'))).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedUniversity = value;
                              _selectedFaculty = selectedFaculty;
                            });
                          },
                        ),
                      if (_selectedInstitutionType == 'universite' && _selectedUniversity != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('Fakülte: ${selectedFaculty ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      if (_selectedInstitutionType == 'eah' && _selectedCity != null)
                        DropdownButtonFormField<String>(
                          value: _selectedHospital,
                          decoration: InputDecoration(
                            labelText: 'Hastane',
                            labelStyle: const TextStyle(color: AppColors.textSecondary),
                            filled: true,
                            fillColor: AppColors.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: AppColors.primary),
                            ),
                          ),
                          dropdownColor: AppColors.surface,
                          style: const TextStyle(color: AppColors.textPrimary),
                          items: filteredHospitals.map((h) => DropdownMenuItem<String>(value: h['hastaneAdi'] as String, child: Text('${h['hastaneAdi']} (${h['il']})'))).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedHospital = value;
                              _selectedAffiliatedFaculty = selectedAffiliatedFaculty;
                            });
                          },
                        ),
                      if (_selectedInstitutionType == 'eah' && _selectedHospital != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text('Afiliye Fakülte: ${selectedAffiliatedFaculty ?? ''}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedQuotaType,
                        decoration: InputDecoration(
                          labelText: 'Kontenjan Türü',
                          labelStyle: const TextStyle(color: AppColors.textSecondary),
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                        dropdownColor: AppColors.surface,
                        style: const TextStyle(color: AppColors.textPrimary),
                        items: const [
                          DropdownMenuItem(value: 'genel', child: Text('Genel')),
                          DropdownMenuItem(value: 'aile', child: Text('Aile Hekimi')),
                          DropdownMenuItem(value: 'yabanci', child: Text('Yabancı Uyruklu')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedQuotaType = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Simülasyonu Başlat Butonu
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Burada filtrelenmiş verilerle bir sonraki sayfaya geçilebilir
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PreferenceSimulationResultsPage(),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Simülasyonu Başlat',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.textOnPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _rankController.dispose();
    super.dispose();
  }
} 