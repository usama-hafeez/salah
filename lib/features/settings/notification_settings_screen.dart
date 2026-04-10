import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/storage_service.dart';
import '../../providers/theme_provider.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  static const _prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

  // Per-prayer toggles
  late final Map<String, bool> _prayerToggles;

  // Extra toggles
  late bool _prePrayer;
  late bool _jumua;
  late bool _dailyVerse;
  late bool _islamicEvents;

  @override
  void initState() {
    super.initState();
    _prayerToggles = {
      for (final p in _prayers) p: StorageService.notificationEnabled(p),
    };
    _prePrayer = StorageService.prePrayerReminder;
    _jumua = StorageService.jumuaReminder;
    _dailyVerse = StorageService.dailyVerseNotification;
    _islamicEvents = StorageService.islamicEventNotification;
  }

  Future<void> _setPrayerToggle(String prayer, bool value) async {
    await StorageService.setNotificationEnabled(prayer, value);
    setState(() => _prayerToggles[prayer] = value);
    await NotificationService.scheduleAllNotifications();
  }

  Future<void> _setPrePrayer(bool value) async {
    await StorageService.setPrePrayerReminder(value);
    setState(() => _prePrayer = value);
    await NotificationService.scheduleAllNotifications();
  }

  Future<void> _setJumua(bool value) async {
    await StorageService.setJumuaReminder(value);
    setState(() => _jumua = value);
    await NotificationService.scheduleAllNotifications();
  }

  Future<void> _setDailyVerse(bool value) async {
    await StorageService.setDailyVerseNotification(value);
    setState(() => _dailyVerse = value);
    await NotificationService.scheduleAllNotifications();
  }

  Future<void> _setIslamicEvents(bool value) async {
    await StorageService.setIslamicEventNotification(value);
    setState(() => _islamicEvents = value);
    // Islamic event notifications are informational — no rescheduling needed
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().current;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.primary,
        foregroundColor: theme.textPrimary,
        elevation: 0,
        title: Text(
          AppStrings.get('notifications'),
          style: TextStyle(color: theme.textPrimary),
        ),
      ),
      body: ListView(
        children: [
          // ── Per-prayer azaan toggles ────────────────────────────────────────
          _SectionHeader(
            label: AppStrings.get('notif_per_prayer'),
            theme: theme,
          ),
          ..._prayers.map((prayer) => _ToggleTile(
                title: AppStrings.get(prayer.toLowerCase()),
                subtitle: null,
                value: _prayerToggles[prayer]!,
                theme: theme,
                onChanged: (v) => _setPrayerToggle(prayer, v),
              )),

          // ── Extra reminders ────────────────────────────────────────────────
          _SectionHeader(label: 'Reminders', theme: theme),
          _ToggleTile(
            title: AppStrings.get('notif_pre_reminder'),
            subtitle: AppStrings.get('notif_pre_sub'),
            value: _prePrayer,
            theme: theme,
            onChanged: _setPrePrayer,
          ),
          _ToggleTile(
            title: AppStrings.get('notif_jumua'),
            subtitle: AppStrings.get('notif_jumua_sub'),
            value: _jumua,
            theme: theme,
            onChanged: _setJumua,
          ),
          _ToggleTile(
            title: AppStrings.get('notif_verse'),
            subtitle: AppStrings.get('notif_verse_sub'),
            value: _dailyVerse,
            theme: theme,
            onChanged: _setDailyVerse,
          ),
          _ToggleTile(
            title: AppStrings.get('notif_events'),
            subtitle: AppStrings.get('notif_events_sub'),
            value: _islamicEvents,
            theme: theme,
            onChanged: _setIslamicEvents,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final dynamic theme;

  const _SectionHeader({required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: theme.accent,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ── Toggle tile ───────────────────────────────────────────────────────────────

class _ToggleTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final dynamic theme;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.theme,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        title: Text(
          title,
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: TextStyle(color: theme.textSecondary, fontSize: 12),
              )
            : null,
        value: value,
        activeColor: theme.accent,
        onChanged: onChanged,
      ),
    );
  }
}
