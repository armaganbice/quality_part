class TemplateDetail {
  final int id;
  final String kalipKodu;
  final String stokKodu;
  final String tezgahKodu;
  final String levhaKodu;
  final DateTime kayitTarihi;
  final bool isAlarmOff;

  TemplateDetail({
    required this.id,
    required this.kalipKodu,
    required this.stokKodu,
    required this.tezgahKodu,
    required this.levhaKodu,
    required this.kayitTarihi,
    required this.isAlarmOff,
  });

  factory TemplateDetail.fromJson(Map<String, dynamic> json) {
    return TemplateDetail(
      id: json['Id'] ?? 0,
      kalipKodu: json['KalipKodu'] ?? '',
      stokKodu: json['StokKodu'] ?? '',
      tezgahKodu: json['TezgahKodu'] ?? '',
      levhaKodu: json['LevhaKodu'] ?? '',
      kayitTarihi: DateTime.parse(json['KayitTarihi'] ?? DateTime.now().toString()),
      isAlarmOff: json['IsAlarmOff'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'KalipKodu': kalipKodu,
      'StokKodu': stokKodu,
      'TezgahKodu': tezgahKodu,
      'LevhaKodu': levhaKodu,
      'KayitTarihi': kayitTarihi.toIso8601String(),
      'IsAlarmOff': isAlarmOff ? 1 : 0,
    };
  }

  TemplateDetail copyWith({
    int? id,
    String? kalipKodu,
    String? stokKodu,
    String? tezgahKodu,
    String? levhaKodu,
    DateTime? kayitTarihi,
    bool? isAlarmOff,
  }) {
    return TemplateDetail(
      id: id ?? this.id,
      kalipKodu: kalipKodu ?? this.kalipKodu,
      stokKodu: stokKodu ?? this.stokKodu,
      tezgahKodu: tezgahKodu ?? this.tezgahKodu,
      levhaKodu: levhaKodu ?? this.levhaKodu,
      kayitTarihi: kayitTarihi ?? this.kayitTarihi,
      isAlarmOff: isAlarmOff ?? this.isAlarmOff,
    );
  }

  @override
  String toString() {
    return 'TemplateDetail(id: $id, kalipKodu: $kalipKodu, stokKodu: $stokKodu, tezgahKodu: $tezgahKodu, levhaKodu: $levhaKodu, kayitTarihi: $kayitTarihi, isAlarmOff: $isAlarmOff)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is TemplateDetail &&
        other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}