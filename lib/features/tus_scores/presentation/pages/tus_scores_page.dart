// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:tus/core/data/tus_data_loader.dart';

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

    // Örnek: Son TUS toplam kontenjanlarını listele
    final List<dynamic> kontenjanlar = tusData!["sonTusToplamKontenjanlar"];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView.builder(
        itemCount: kontenjanlar.length,
        itemBuilder: (context, index) {
          final item = kontenjanlar[index];
          return ListTile(
            title: Text(item["tusDonemi"] ?? "-"),
            subtitle: Text("Açılan Kontenjan: ${item["acilanKontenjanSayisi"]}"),
          );
        },
      ),
    );
  }
} 