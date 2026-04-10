import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/ad_service.dart';
import '../../core/services/storage_service.dart';
import '../../providers/theme_provider.dart';
import '../../shared/premium_lock_widget.dart';
import '../premium/paywall_screen.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  double _qiblaAngle = 0;

  @override
  void initState() {
    super.initState();
    _computeQiblaAngle();
    // Show interstitial for free users when Qibla screen opens (Business Rule §12.3)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdService.showInterstitial();
    });
  }

  void _computeQiblaAngle() {
    final lat = StorageService.lastLat;
    final lng = StorageService.lastLng;
    setState(() => _qiblaAngle = _calculateQiblaAngle(lat, lng));
  }

  double _calculateQiblaAngle(double userLat, double userLng) {
    const kLat = AppConstants.kaabaLat;
    const kLng = AppConstants.kaabaLng;
    final dLng = (kLng - userLng) * (pi / 180);
    final lat1 = userLat * (pi / 180);
    final lat2 = kLat * (pi / 180);
    final x = sin(dLng) * cos(lat2);
    final y = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng);
    return (atan2(x, y) * (180 / pi) + 360) % 360;
  }

  bool _isFacingQibla(double compassHeading) {
    final diff = (_qiblaAngle - compassHeading + 360) % 360;
    return diff < 5 || diff > 355;
  }

  void _openPaywall() => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PaywallScreen()),
      );

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().current;

    return PremiumLockWidget(
      onUpgrade: _openPaywall,
      description:
          'Unlock the Qibla compass to find the direction of Mecca from your location.',
      child: Scaffold(
        backgroundColor: theme.background,
        appBar: AppBar(
          title: Text('Qibla Compass',
              style: TextStyle(color: theme.textPrimary)),
          backgroundColor: theme.primary,
          elevation: 0,
        ),
        body: StreamBuilder<CompassEvent>(
          stream: FlutterCompass.events,
          builder: (context, snapshot) {
            final heading = snapshot.data?.heading ?? 0.0;
            final facingQibla = _isFacingQibla(heading);
            final needleRadians = (_qiblaAngle - heading) * (pi / 180);

            return SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  _StatusBadge(facingQibla: facingQibla, theme: theme),
                  const SizedBox(height: 48),
                  _CompassDial(
                    needleRadians: needleRadians,
                    facingQibla: facingQibla,
                    theme: theme,
                  ),
                  const SizedBox(height: 36),
                  _AngleRow(
                    qiblaAngle: _qiblaAngle,
                    compassHeading: heading,
                    theme: theme,
                  ),
                  const Spacer(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool facingQibla;
  final AppThemeData theme;

  const _StatusBadge({required this.facingQibla, required this.theme});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: facingQibla
          ? _BadgeContent(
              key: const ValueKey('facing'),
              icon: Icons.check_circle_rounded,
              color: const Color(0xFF4CAF50),
              label: 'Facing Qibla',
            )
          : _BadgeContent(
              key: const ValueKey('seeking'),
              icon: Icons.explore_outlined,
              color: theme.accent,
              label: 'Find the Qibla',
            ),
    );
  }
}

class _BadgeContent extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _BadgeContent({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 44),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _CompassDial extends StatelessWidget {
  final double needleRadians;
  final bool facingQibla;
  final AppThemeData theme;

  const _CompassDial({
    required this.needleRadians,
    required this.facingQibla,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
        facingQibla ? const Color(0xFF4CAF50) : theme.accent;

    return Container(
      width: 260,
      height: 260,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.surface,
        border: Border.all(color: borderColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: borderColor.withAlpha(60),
            blurRadius: 28,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: Transform.rotate(
          angle: needleRadians,
          child: SvgPicture.asset(
            AppAssets.compassNeedle,
            width: 200,
            height: 200,
            colorFilter: ColorFilter.mode(borderColor, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}

class _AngleRow extends StatelessWidget {
  final double qiblaAngle;
  final double compassHeading;
  final AppThemeData theme;

  const _AngleRow({
    required this.qiblaAngle,
    required this.compassHeading,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _AngleLabel(
          label: 'Qibla',
          value: '${qiblaAngle.toStringAsFixed(1)}°',
          theme: theme,
        ),
        Container(
          height: 28,
          width: 1,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          color: theme.textSecondary.withAlpha(60),
        ),
        _AngleLabel(
          label: 'Compass',
          value: '${compassHeading.toStringAsFixed(1)}°',
          theme: theme,
        ),
      ],
    );
  }
}

class _AngleLabel extends StatelessWidget {
  final String label;
  final String value;
  final AppThemeData theme;

  const _AngleLabel({
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(color: theme.textSecondary, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                color: theme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}
