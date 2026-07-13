class VerseModel {
  final int id;
  final int surahId;
  final int ayahNumber;
  final String textArabic;
  final String? textEnglish;
  final String? textUrdu;
  final int? juz;

  const VerseModel({
    required this.id,
    required this.surahId,
    required this.ayahNumber,
    required this.textArabic,
    this.textEnglish,
    this.textUrdu,
    this.juz,
  });

  factory VerseModel.fromMap(Map<String, dynamic> map) => VerseModel(
        id: map['id'] as int,
        surahId: map['surah_id'] as int,
        ayahNumber: map['ayah_number'] as int,
        textArabic: map['text_arabic'] as String,
        textEnglish: map['text_english'] as String?,
        textUrdu: map['text_urdu'] as String?,
        juz: map['juz'] as int?,
      );
}
