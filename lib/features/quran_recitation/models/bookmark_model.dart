import 'dart:convert';

class RecitationBookmark {
  final int surahNumber;
  final int verseNumber;
  final int pageNumber;
  final DateTime timestamp;
  final String? note;

  const RecitationBookmark({
    required this.surahNumber,
    required this.verseNumber,
    required this.pageNumber,
    required this.timestamp,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'surahNumber': surahNumber,
        'verseNumber': verseNumber,
        'pageNumber': pageNumber,
        'timestamp': timestamp.toIso8601String(),
        if (note != null) 'note': note,
      };

  factory RecitationBookmark.fromJson(Map<String, dynamic> json) =>
      RecitationBookmark(
        surahNumber: json['surahNumber'] as int,
        verseNumber: json['verseNumber'] as int,
        pageNumber: json['pageNumber'] as int,
        timestamp: DateTime.parse(json['timestamp'] as String),
        note: json['note'] as String?,
      );

  String toJsonString() => jsonEncode(toJson());

  static RecitationBookmark fromJsonString(String raw) =>
      RecitationBookmark.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}
