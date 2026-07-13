import 'package:flutter/material.dart';

class RecitationSettings {
  final double warmth; // 0.0 = warm parchment, 1.0 = bright white
  final bool largeFont;
  final bool nightMode;

  const RecitationSettings({
    this.warmth = 1.0,
    this.largeFont = false,
    this.nightMode = false,
  });

  RecitationSettings copyWith({
    double? warmth,
    bool? largeFont,
    bool? nightMode,
  }) =>
      RecitationSettings(
        warmth: warmth ?? this.warmth,
        largeFont: largeFont ?? this.largeFont,
        nightMode: nightMode ?? this.nightMode,
      );
}

class RecitationSettingsSheet extends StatefulWidget {
  final RecitationSettings initial;
  final ValueChanged<RecitationSettings> onChanged;
  final dynamic theme;

  const RecitationSettingsSheet({
    super.key,
    required this.initial,
    required this.onChanged,
    required this.theme,
  });

  @override
  State<RecitationSettingsSheet> createState() =>
      _RecitationSettingsSheetState();
}

class _RecitationSettingsSheetState extends State<RecitationSettingsSheet> {
  late RecitationSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = widget.initial;
  }

  void _update(RecitationSettings s) {
    setState(() => _settings = s);
    widget.onChanged(s);
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Handle(theme: theme),
          const SizedBox(height: 4),
          Text(
            'Reading Settings',
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),

          // ── Brightness ──────────────────────────────────────────────────────
          _SectionLabel(label: 'Page Warmth', theme: theme),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.wb_sunny_outlined, color: theme.accent, size: 18),
              Expanded(
                child: Slider(
                  value: _settings.warmth,
                  onChanged: (v) => _update(_settings.copyWith(warmth: v)),
                  activeColor: theme.accent,
                  inactiveColor: theme.accent.withAlpha(60),
                ),
              ),
              Icon(Icons.brightness_high, color: theme.accent, size: 18),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Warm', style: TextStyle(color: theme.textSecondary, fontSize: 11)),
              Text('Bright', style: TextStyle(color: theme.textSecondary, fontSize: 11)),
            ],
          ),

          const SizedBox(height: 20),
          Divider(color: theme.background, height: 1),
          const SizedBox(height: 16),

          // ── Font scale ──────────────────────────────────────────────────────
          _SectionLabel(label: 'Font Size', theme: theme),
          const SizedBox(height: 10),
          Row(
            children: [
              _ScaleChip(
                label: 'Normal',
                selected: !_settings.largeFont,
                theme: theme,
                onTap: () => _update(_settings.copyWith(largeFont: false)),
              ),
              const SizedBox(width: 10),
              _ScaleChip(
                label: 'Large',
                selected: _settings.largeFont,
                theme: theme,
                onTap: () => _update(_settings.copyWith(largeFont: true)),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Divider(color: theme.background, height: 1),
          const SizedBox(height: 4),

          // ── Night mode ──────────────────────────────────────────────────────
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Night Mode',
              style: TextStyle(
                color: theme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              'Inverts page colors for dark reading',
              style: TextStyle(color: theme.textSecondary, fontSize: 12),
            ),
            value: _settings.nightMode,
            activeColor: theme.accent,
            onChanged: (v) => _update(_settings.copyWith(nightMode: v)),
          ),
        ],
      ),
    );
  }
}

class _Handle extends StatelessWidget {
  final dynamic theme;
  const _Handle({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: theme.textSecondary.withAlpha(80),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final dynamic theme;
  const _SectionLabel({required this.label, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: TextStyle(
          color: theme.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _ScaleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final dynamic theme;
  final VoidCallback onTap;

  const _ScaleChip({
    required this.label,
    required this.selected,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? theme.accent.withAlpha(30) : theme.background,
          border: Border.all(
            color: selected ? theme.accent : theme.textSecondary.withAlpha(60),
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? theme.accent : theme.textSecondary,
            fontSize: 14,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
