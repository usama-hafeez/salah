class UserSettings {
  final String calculationMethod;
  final String madhab;
  final String language;
  final String theme;
  final bool isPro;
  final String azaanSound;
  final Map<String, bool> notificationToggles;

  const UserSettings({
    required this.calculationMethod,
    required this.madhab,
    required this.language,
    required this.theme,
    required this.isPro,
    required this.azaanSound,
    required this.notificationToggles,
  });
}
