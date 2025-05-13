class Brans {
  final int bransid;
  final String bransadi;

  Brans({required this.bransid, required this.bransadi});

  factory Brans.fromJson(Map<String, dynamic> json) => Brans(
    bransid: json['bransid'] as int,
    bransadi: json['bransadi'] as String,
  );
} 