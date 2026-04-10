import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class HijriCalendarScreen extends StatelessWidget {
  const HijriCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().current;
    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text(
          'Calendar',
          style: TextStyle(color: theme.textPrimary),
        ),
        backgroundColor: theme.primary,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'Hijri Calendar\n(Phase 6)',
          textAlign: TextAlign.center,
          style: TextStyle(color: theme.textSecondary, fontSize: 16),
        ),
      ),
    );
  }
}
