class TusVeriAna {
  final int veriId;
  final int donemId;
  final int kurumId;
  final int bransId;
  final String kontenjanTuru;
  final String puanTuru;
  final int? kontenjanSayisi;
  final int? yerlesenSayisi;
  final int? bosKalanSayisi;
  final double? tabanPuan;
  final double? tavanPuan;
  final String? ozelKosul;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TusVeriAna({
    required this.veriId,
    required this.donemId,
    required this.kurumId,
    required this.bransId,
    required this.kontenjanTuru,
    required this.puanTuru,
    this.kontenjanSayisi,
    this.yerlesenSayisi,
    this.bosKalanSayisi,
    this.tabanPuan,
    this.tavanPuan,
    this.ozelKosul,
    this.createdAt,
    this.updatedAt,
  });

  factory TusVeriAna.fromJson(Map<String, dynamic> json) => TusVeriAna(
    veriId: json['veri_id'] as int,
    donemId: json['donem_id'] as int,
    kurumId: json['kurum_id'] as int,
    bransId: json['brans_id'] as int,
    kontenjanTuru: json['kontenjan_turu'] as String,
    puanTuru: json['puan_turu'] as String,
    kontenjanSayisi: json['kontenjan_sayisi'] as int?,
    yerlesenSayisi: json['yerlesen_sayisi'] as int?,
    bosKalanSayisi: json['bos_kalan_sayisi'] as int?,
    tabanPuan: (json['taban_puan'] as num?)?.toDouble(),
    tavanPuan: (json['tavan_puan'] as num?)?.toDouble(),
    ozelKosul: json['ozel_kosul'] as String?,
    createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
  );
} 