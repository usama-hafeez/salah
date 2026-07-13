class SurahModel {
  final int id;
  final String nameArabic;
  final String nameEnglish;
  final String? nameUrdu;
  final String? revelation;
  final int ayahCount;

  const SurahModel({
    required this.id,
    required this.nameArabic,
    required this.nameEnglish,
    this.nameUrdu,
    this.revelation,
    required this.ayahCount,
  });

  factory SurahModel.fromMap(Map<String, dynamic> map) => SurahModel(
        id: map['id'] as int,
        nameArabic: map['name_arabic'] as String,
        nameEnglish: map['name_english'] as String,
        nameUrdu: map['name_urdu'] as String?,
        revelation: map['revelation'] as String?,
        ayahCount: map['ayah_count'] as int,
      );
}
