class Donem {
  final int donemid;
  final int sinavyili;
  final String sinavdonemiadi;

  Donem({required this.donemid, required this.sinavyili, required this.sinavdonemiadi});

  factory Donem.fromJson(Map<String, dynamic> json) => Donem(
    donemid: json['donemid'] as int,
    sinavyili: json['sinavyili'] as int,
    sinavdonemiadi: json['sinavdonemiadi'] as String,
  );
} 