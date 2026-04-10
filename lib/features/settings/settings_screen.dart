import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/purchase_service.dart';
import '../../core/services/storage_service.dart';
import '../../providers/purchase_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/theme_provider.dart';
import '../premium/paywall_screen.dart';
import '../qaza/qaza_tracker_screen.dart';
import '../ramadan/ramadan_screen.dart';
import '../tasbih/tasbih_screen.dart';
import 'notification_settings_screen.dart';
import 'theme_picker_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().current;
    final settings = context.watch<SettingsProvider>();
    final isPro = context.watch<PurchaseProvider>().isPro;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text(AppStrings.get('settings_more'),
            style: TextStyle(color: theme.textPrimary)),
        backgroundColor: theme.primary,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // ── Islamic Tools ─────────────────────────────────────────────────
          _SectionHeader(label: AppStrings.get('islamic_tools'), theme: theme),
          _NavTile(
            icon: Icons.autorenew_rounded,
            title: AppStrings.get('tasbih'),
            subtitle: 'SubhanAllah · Alhamdulillah · AllahuAkbar',
            theme: theme,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const TasbihScreen())),
          ),
          _NavTile(
            icon: Icons.nightlight_outlined,
            title: AppStrings.get('ramadan'),
            subtitle: 'Sehri & Iftar times, 30-day timetable',
            theme: theme,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const RamadanScreen())),
          ),
          _NavTile(
            icon: Icons.format_list_numbered_rounded,
            title: AppStrings.get('qaza'),
            subtitle: 'Track missed prayers to make up',
            theme: theme,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const QazaTrackerScreen())),
          ),

          // ── Settings ──────────────────────────────────────────────────────
          _SectionHeader(label: AppStrings.get('app_settings'), theme: theme),

          // Language
          _ValueTile(
            icon: Icons.language_outlined,
            title: AppStrings.get('language'),
            value: _languageLabel(settings.language),
            theme: theme,
            onTap: () => _showLanguagePicker(context, settings, theme),
          ),

          // Calculation method
          _ValueTile(
            icon: Icons.calculate_outlined,
            title: AppStrings.get('calc_method'),
            value: _methodLabel(settings.calculationMethod),
            theme: theme,
            onTap: () => _showMethodPicker(context, settings, theme),
          ),

          // Madhab
          _ValueTile(
            icon: Icons.mosque_outlined,
            title: AppStrings.get('madhab'),
            value: settings.madhab == 'Hanafi'
                ? AppStrings.get('madhab_hanafi')
                : AppStrings.get('madhab_shafi'),
            theme: theme,
            onTap: () => _showMadhabPicker(context, settings, theme),
          ),

          // Notifications
          _NavTile(
            icon: Icons.notifications_outlined,
            title: AppStrings.get('notifications'),
            subtitle: 'Prayer alerts, reminders & more',
            theme: theme,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const NotificationSettingsScreen()),
            ),
          ),

          // Azaan sound
          _ValueTile(
            icon: Icons.volume_up_outlined,
            title: AppStrings.get('azaan_sound'),
            value: _soundLabel(settings.azaanSound),
            theme: theme,
            onTap: () => _showSoundPicker(context, settings, theme),
          ),

          // Themes
          _NavTile(
            icon: Icons.palette_outlined,
            title: AppStrings.get('themes'),
            subtitle: 'Choose from 8 themes, including 6 Pro themes',
            theme: theme,
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ThemePickerScreen())),
          ),

          // ── Pro status ────────────────────────────────────────────────────
          _SectionHeader(label: 'Pro', theme: theme),
          if (isPro)
            _ProActiveTile(theme: theme)
          else
            _NavTile(
              icon: Icons.star_outline_rounded,
              title: AppStrings.get('upgrade_pro'),
              subtitle: 'Remove ads, unlock themes & Qibla compass',
              theme: theme,
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const PaywallScreen())),
            ),
          _TextButtonTile(
            label: AppStrings.get('restore_purchase'),
            theme: theme,
            onTap: () async {
              try {
                await PurchaseService.restorePurchases();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Purchases restored'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (_) {}
            },
          ),

          // ── About ─────────────────────────────────────────────────────────
          _SectionHeader(label: AppStrings.get('about_section'), theme: theme),
          _InfoTile(
            icon: Icons.info_outline,
            title: AppStrings.get('version'),
            value: '1.0.0',
            theme: theme,
          ),
          _NavTile(
            icon: Icons.privacy_tip_outlined,
            title: AppStrings.get('privacy_policy'),
            subtitle: AppConstants.privacyPolicyUrl,
            theme: theme,
            onTap: () => _showUrlDialog(
              context,
              AppStrings.get('privacy_policy'),
              AppConstants.privacyPolicyUrl,
              theme,
            ),
          ),
          _NavTile(
            icon: Icons.star_rate_outlined,
            title: AppStrings.get('rate_app'),
            subtitle: 'Leave a review on the Play Store',
            theme: theme,
            onTap: () => _showUrlDialog(
              context,
              AppStrings.get('rate_app'),
              AppConstants.playStoreUrl,
              theme,
            ),
          ),
          _NavTile(
            icon: Icons.email_outlined,
            title: AppStrings.get('contact_support'),
            subtitle: AppConstants.supportEmail,
            theme: theme,
            onTap: () {
              Clipboard.setData(
                  ClipboardData(text: AppConstants.supportEmail));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Email copied to clipboard'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Helper: label mappers ───────────────────────────────────────────────────

  String _languageLabel(String code) {
    switch (code) {
      case 'ur': return AppStrings.get('lang_ur');
      case 'ar': return AppStrings.get('lang_ar');
      default:   return AppStrings.get('lang_en');
    }
  }

  String _methodLabel(String method) {
    switch (method) {
      case 'ISNA':   return AppStrings.get('method_isna');
      case 'MWL':    return AppStrings.get('method_mwl');
      case 'Egypt':  return AppStrings.get('method_egypt');
      case 'Tehran': return AppStrings.get('method_tehran');
      case 'Gulf':   return AppStrings.get('method_gulf');
      default:       return AppStrings.get('method_karachi');
    }
  }

  String _soundLabel(String sound) {
    switch (sound) {
      case 'egypt':    return AppStrings.get('sound_egypt');
      case 'pakistan': return AppStrings.get('sound_pakistan');
      case 'turkey':   return AppStrings.get('sound_turkey');
      case 'short':    return AppStrings.get('sound_short');
      default:         return AppStrings.get('sound_mecca');
    }
  }

  // ── Pickers ─────────────────────────────────────────────────────────────────

  void _showLanguagePicker(
    BuildContext context, SettingsProvider settings, AppThemeData theme) {
    _showOptionSheet(
      context: context,
      theme: theme,
      title: AppStrings.get('language'),
      options: [
        ('en', AppStrings.get('lang_en')),
        ('ur', AppStrings.get('lang_ur')),
        ('ar', AppStrings.get('lang_ar')),
      ],
      selected: settings.language,
      onSelect: settings.setLanguage,
    );
  }

  void _showMethodPicker(
    BuildContext context, SettingsProvider settings, AppThemeData theme) {
    _showOptionSheet(
      context: context,
      theme: theme,
      title: AppStrings.get('calc_method'),
      options: [
        ('Karachi', AppStrings.get('method_karachi')),
        ('ISNA',    AppStrings.get('method_isna')),
        ('MWL',     AppStrings.get('method_mwl')),
        ('Egypt',   AppStrings.get('method_egypt')),
        ('Tehran',  AppStrings.get('method_tehran')),
        ('Gulf',    AppStrings.get('method_gulf')),
      ],
      selected: settings.calculationMethod,
      onSelect: settings.setCalculationMethod,
    );
  }

  void _showMadhabPicker(
    BuildContext context, SettingsProvider settings, AppThemeData theme) {
    _showOptionSheet(
      context: context,
      theme: theme,
      title: AppStrings.get('madhab'),
      options: [
        ('Hanafi', AppStrings.get('madhab_hanafi')),
        ('Shafi',  AppStrings.get('madhab_shafi')),
      ],
      selected: settings.madhab,
      onSelect: settings.setMadhab,
    );
  }

  void _showSoundPicker(
    BuildContext context, SettingsProvider settings, AppThemeData theme) {
    _showOptionSheet(
      context: context,
      theme: theme,
      title: AppStrings.get('azaan_sound'),
      options: [
        ('mecca',    AppStrings.get('sound_mecca')),
        ('egypt',    AppStrings.get('sound_egypt')),
        ('pakistan', AppStrings.get('sound_pakistan')),
        ('turkey',   AppStrings.get('sound_turkey')),
        ('short',    AppStrings.get('sound_short')),
      ],
      selected: settings.azaanSound,
      onSelect: settings.setAzaanSound,
    );
  }

  void _showOptionSheet({
    required BuildContext context,
    required AppThemeData theme,
    required String title,
    required List<(String, String)> options,
    required String selected,
    required Future<void> Function(String) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _OptionSheet(
        title: title,
        options: options,
        selected: selected,
        theme: theme,
        onSelect: (value) {
          Navigator.pop(context);
          onSelect(value);
        },
      ),
    );
  }

  void _showUrlDialog(
    BuildContext context, String title, String url, AppThemeData theme) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: theme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: TextStyle(color: theme.textPrimary)),
        content: Text(
          url,
          style: TextStyle(color: theme.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text(AppStrings.get('cancel'), style: TextStyle(color: theme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: url));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('URL copied to clipboard'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text('Copy', style: TextStyle(color: theme.accent)),
          ),
        ],
      ),
    );
  }
}

// ── Option bottom sheet ───────────────────────────────────────────────────────

class _OptionSheet extends StatelessWidget {
  final String title;
  final List<(String, String)> options;
  final String selected;
  final AppThemeData theme;
  final ValueChanged<String> onSelect;

  const _OptionSheet({
    required this.title,
    required this.options,
    required this.selected,
    required this.theme,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 10),
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: theme.textSecondary.withAlpha(80),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Text(
            title,
            style: TextStyle(
              color: theme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 4),
        ...options.map(((String, String) opt) {
          final (value, label) = opt;
          final isSelected = value == selected;
          return ListTile(
            title: Text(
              label,
              style: TextStyle(
                color: isSelected ? theme.accent : theme.textPrimary,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            trailing: isSelected
                ? Icon(Icons.check_rounded, color: theme.accent, size: 20)
                : null,
            onTap: () => onSelect(value),
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ── Shared tile widgets ───────────────────────────────────────────────────────

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

class _NavTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final dynamic theme;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _IconBox(icon: icon, theme: theme),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          color: theme.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          color: theme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: theme.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ValueTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final dynamic theme;
  final VoidCallback onTap;

  const _ValueTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: theme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _IconBox(icon: icon, theme: theme),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title,
                  style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500)),
            ),
            Text(value,
                style: TextStyle(color: theme.accent, fontSize: 13)),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, color: theme.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final dynamic theme;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _IconBox(icon: icon, theme: theme),
          const SizedBox(width: 14),
          Expanded(
            child: Text(title,
                style: TextStyle(
                    color: theme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500)),
          ),
          Text(value, style: TextStyle(color: theme.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }
}

class _ProActiveTile extends StatelessWidget {
  final dynamic theme;
  const _ProActiveTile({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.accent.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.accent.withAlpha(80)),
      ),
      child: Row(
        children: [
          Icon(Icons.verified_rounded, color: theme.accent, size: 24),
          const SizedBox(width: 14),
          Text(
            AppStrings.get('pro_active'),
            style: TextStyle(
              color: theme.accent,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TextButtonTile extends StatelessWidget {
  final String label;
  final dynamic theme;
  final VoidCallback onTap;

  const _TextButtonTile({
    required this.label,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: TextButton(
          onPressed: onTap,
          child: Text(label,
              style: TextStyle(color: theme.textSecondary, fontSize: 13)),
        ),
      ),
    );
  }
}

class _IconBox extends StatelessWidget {
  final IconData icon;
  final dynamic theme;

  const _IconBox({required this.icon, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: theme.accent.withAlpha(30),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: theme.accent, size: 20),
    );
  }
}
