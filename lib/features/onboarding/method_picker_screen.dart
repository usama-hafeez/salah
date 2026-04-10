import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_strings.dart';
import '../../providers/settings_provider.dart';
import '../../providers/theme_provider.dart';

/// Standalone screen for picking the prayer calculation method.
/// Shown during onboarding before the main app loads.
/// Also accessible from Settings via the calculation method tile.
class MethodPickerScreen extends StatelessWidget {
  /// When true, shows a "Continue" button that navigates to the next route
  /// instead of popping. Used during onboarding.
  final bool isOnboarding;
  final String? nextRoute;

  const MethodPickerScreen({
    super.key,
    this.isOnboarding = false,
    this.nextRoute,
  });

  static const _methods = [
    ('Karachi',  'method_karachi', 'Hanafi — Pakistan, India, Bangladesh'),
    ('ISNA',     'method_isna',    'North America'),
    ('MWL',      'method_mwl',     'Europe, Far East, parts of USA'),
    ('Egypt',    'method_egypt',   'Africa, Syria, Lebanon, Malaysia'),
    ('Tehran',   'method_tehran',  'Iran, some Shia communities'),
    ('Gulf',     'method_gulf',    'Gulf region, Kuwait'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().current;
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: theme.background,
      appBar: isOnboarding
          ? null
          : AppBar(
              backgroundColor: theme.primary,
              foregroundColor: theme.textPrimary,
              elevation: 0,
              title: Text(
                AppStrings.get('calc_method'),
                style: TextStyle(color: theme.textPrimary),
              ),
            ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (isOnboarding) ...[
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  AppStrings.get('calc_method'),
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Choose the calculation method used for your region.',
                  style:
                      TextStyle(color: theme.textSecondary, fontSize: 14),
                ),
              ),
              const SizedBox(height: 24),
            ],
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: _methods.map(((String, String, String) m) {
                  final (value, labelKey, subtitle) = m;
                  final selected = settings.calculationMethod == value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: selected
                          ? theme.accent.withAlpha(20)
                          : theme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? theme.accent.withAlpha(120)
                            : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: ListTile(
                      title: Text(
                        AppStrings.get(labelKey),
                        style: TextStyle(
                          color: selected
                              ? theme.accent
                              : theme.textPrimary,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        subtitle,
                        style: TextStyle(
                            color: theme.textSecondary, fontSize: 12),
                      ),
                      trailing: selected
                          ? Icon(Icons.check_circle_rounded,
                              color: theme.accent)
                          : null,
                      onTap: () => settings.setCalculationMethod(value),
                    ),
                  );
                }).toList(),
              ),
            ),
            if (isOnboarding)
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.accent,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (nextRoute != null) {
                      Navigator.pushReplacementNamed(context, nextRoute!);
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
