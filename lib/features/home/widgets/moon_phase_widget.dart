import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:provider/provider.dart';

import '../../../providers/theme_provider.dart';

/// Displays the approximate moon phase based on the current Hijri day.
/// The Hijri month is lunar, so day 1 ≈ new moon, day 14–15 ≈ full moon.
class MoonPhaseWidget extends StatelessWidget {
  const MoonPhaseWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().current;
    final h = HijriCalendar.now();
    final phase = _phaseFor(h.hDay);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          phase.emoji,
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(width: 4),
        Text(
          phase.label,
          style: TextStyle(color: theme.textSecondary, fontSize: 11),
        ),
      ],
    );
  }

  _MoonPhase _phaseFor(int hijriDay) {
    if (hijriDay <= 1)  return const _MoonPhase('🌑', 'New Moon');
    if (hijriDay <= 7)  return const _MoonPhase('🌒', 'Waxing Crescent');
    if (hijriDay <= 8)  return const _MoonPhase('🌓', 'First Quarter');
    if (hijriDay <= 13) return const _MoonPhase('🌔', 'Waxing Gibbous');
    if (hijriDay <= 15) return const _MoonPhase('🌕', 'Full Moon');
    if (hijriDay <= 21) return const _MoonPhase('🌖', 'Waning Gibbous');
    if (hijriDay <= 22) return const _MoonPhase('🌗', 'Last Quarter');
    if (hijriDay <= 28) return const _MoonPhase('🌘', 'Waning Crescent');
    return const _MoonPhase('🌑', 'New Moon');
  }
}

class _MoonPhase {
  final String emoji;
  final String label;
  const _MoonPhase(this.emoji, this.label);
}
