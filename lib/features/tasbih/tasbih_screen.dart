import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/storage_service.dart';
import '../../providers/theme_provider.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen>
    with SingleTickerProviderStateMixin {
  static const _dhikrNames = ['SubhanAllah', 'Alhamdulillah', 'AllahuAkbar'];
  static const _dhikrArabic = [
    'سُبْحَانَ ٱللَّٰهِ',
    'ٱلْحَمْدُ لِلَّٰهِ',
    'ٱللَّٰهُ أَكْبَرُ',
  ];
  static const _dhikrMax = [33, 33, 34];

  final _counts = [0, 0, 0];
  int _currentDhikr = 0;
  bool _allComplete = false;

  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      lowerBound: 0.94,
      upperBound: 1.0,
      value: 1.0,
    );
    _loadCounts();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _loadCounts() {
    final prefs = StorageService.prefs;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final savedDate = prefs.getString('tasbih_date') ?? '';

    if (savedDate != today) {
      for (int i = 0; i < 3; i++) {
        prefs.setInt('tasbih_count_$i', 0);
      }
      prefs.setString('tasbih_date', today);
      // Reset local state
      for (int i = 0; i < 3; i++) _counts[i] = 0;
      _currentDhikr = 0;
      _allComplete = false;
    } else {
      for (int i = 0; i < 3; i++) {
        _counts[i] = prefs.getInt('tasbih_count_$i') ?? 0;
      }
      _allComplete = _counts[0] >= _dhikrMax[0] &&
          _counts[1] >= _dhikrMax[1] &&
          _counts[2] >= _dhikrMax[2];
      if (!_allComplete) {
        _currentDhikr = 0;
        for (int i = 0; i < 3; i++) {
          if (_counts[i] < _dhikrMax[i]) {
            _currentDhikr = i;
            break;
          }
        }
      } else {
        _currentDhikr = 2;
      }
    }
    setState(() {});
  }

  Future<void> _saveCount(int index) async {
    await StorageService.prefs.setInt('tasbih_count_$index', _counts[index]);
  }

  Future<void> _onTap() async {
    if (_allComplete) return;
    if (_counts[_currentDhikr] >= _dhikrMax[_currentDhikr]) return;

    // Scale animation
    _scaleController.reverse().then((_) => _scaleController.forward());

    // Haptic
    try {
      final hasVibrator = await Vibration.hasVibrator() ?? false;
      if (hasVibrator) Vibration.vibrate(duration: 30);
    } catch (_) {}

    setState(() => _counts[_currentDhikr]++);
    await _saveCount(_currentDhikr);

    if (_counts[_currentDhikr] >= _dhikrMax[_currentDhikr]) {
      if (_currentDhikr < 2) {
        try {
          final hasVibrator = await Vibration.hasVibrator() ?? false;
          if (hasVibrator) Vibration.vibrate(duration: 120);
        } catch (_) {}
        await Future.delayed(const Duration(milliseconds: 250));
        if (mounted) setState(() => _currentDhikr++);
      } else {
        try {
          final hasVibrator = await Vibration.hasVibrator() ?? false;
          if (hasVibrator) {
            Vibration.vibrate(pattern: [0, 100, 80, 100, 80, 200]);
          }
        } catch (_) {}
        if (mounted) setState(() => _allComplete = true);
      }
    }
  }

  Future<void> _showResetDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final theme = context.read<ThemeProvider>().current;
        return AlertDialog(
          backgroundColor: theme.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Reset Tasbih',
              style: TextStyle(color: theme.textPrimary)),
          content: Text(
            'Reset all counts to zero?',
            style: TextStyle(color: theme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancel',
                  style: TextStyle(color: theme.textSecondary)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Reset',
                  style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      for (int i = 0; i < 3; i++) {
        _counts[i] = 0;
        await _saveCount(i);
      }
      setState(() {
        _currentDhikr = 0;
        _allComplete = false;
      });
    }
  }

  int get _totalCount => _counts.fold(0, (a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().current;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text('Tasbih', style: TextStyle(color: theme.textPrimary)),
        backgroundColor: theme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: theme.textPrimary),
            onPressed: _showResetDialog,
            tooltip: 'Reset',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            _DhikrTabs(
              currentIndex: _currentDhikr,
              counts: _counts,
              theme: theme,
              onSelect: _allComplete
                  ? null
                  : (i) => setState(() => _currentDhikr = i),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _onTap,
                child: _allComplete
                    ? _AllCompleteView(theme: theme)
                    : _CounterView(
                        scaleController: _scaleController,
                        currentCount: _counts[_currentDhikr],
                        currentMax: _dhikrMax[_currentDhikr],
                        dhikrName: _dhikrNames[_currentDhikr],
                        arabicName: _dhikrArabic[_currentDhikr],
                        totalCount: _totalCount,
                        theme: theme,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dhikr tab selector ─────────────────────────────────────────────────────

class _DhikrTabs extends StatelessWidget {
  final int currentIndex;
  final List<int> counts;
  final AppThemeData theme;
  final ValueChanged<int>? onSelect;

  static const _names = ['SubhanAllah', 'Alhamdulillah', 'AllahuAkbar'];
  static const _max = [33, 33, 34];

  const _DhikrTabs({
    required this.currentIndex,
    required this.counts,
    required this.theme,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(3, (i) {
          final done = counts[i] >= _max[i];
          final active = currentIndex == i;
          return Expanded(
            child: GestureDetector(
              onTap: onSelect == null ? null : () => onSelect!(i),
              child: Container(
                margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: active ? theme.accent : theme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: done && !active
                        ? const Color(0xFF4CAF50)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    if (done && !active)
                      const Icon(Icons.check_circle_rounded,
                          color: Color(0xFF4CAF50), size: 16)
                    else
                      Text(
                        '${counts[i]}/${_max[i]}',
                        style: TextStyle(
                          color: active
                              ? Colors.black87
                              : theme.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    const SizedBox(height: 3),
                    Text(
                      _names[i],
                      style: TextStyle(
                        color: active ? Colors.black87 : theme.textPrimary,
                        fontSize: 11,
                        fontWeight:
                            active ? FontWeight.bold : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Counter ring + dhikr name ───────────────────────────────────────────────

class _CounterView extends StatelessWidget {
  final AnimationController scaleController;
  final int currentCount;
  final int currentMax;
  final String dhikrName;
  final String arabicName;
  final int totalCount;
  final AppThemeData theme;

  const _CounterView({
    required this.scaleController,
    required this.currentCount,
    required this.currentMax,
    required this.dhikrName,
    required this.arabicName,
    required this.totalCount,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ScaleTransition(
          scale: scaleController,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 220,
                height: 220,
                child: CustomPaint(
                  painter: _RingPainter(
                    progress: currentCount / currentMax,
                    color: theme.accent,
                    trackColor: theme.surface,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$currentCount',
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontSize: 64,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    'of $currentMax',
                    style: TextStyle(
                      color: theme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text(
          arabicName,
          style: TextStyle(
            fontFamily: 'Hafs',
            fontSize: 30,
            color: theme.textPrimary,
            height: 1.6,
          ),
          textDirection: TextDirection.rtl,
        ),
        const SizedBox(height: 6),
        Text(
          dhikrName,
          style: TextStyle(
            color: theme.accent,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Tap anywhere to count  •  Total: $totalCount / 100',
          style: TextStyle(color: theme.textSecondary, fontSize: 13),
        ),
      ],
    );
  }
}

// ── All complete view ───────────────────────────────────────────────────────

class _AllCompleteView extends StatelessWidget {
  final AppThemeData theme;

  const _AllCompleteView({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded,
              color: Color(0xFF4CAF50), size: 64),
        ),
        const SizedBox(height: 24),
        Text(
          'Tasbih Complete',
          style: TextStyle(
            color: theme.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'SubhanAllah × 33\nAlhamdulillah × 33\nAllahuAkbar × 34',
          style: TextStyle(
            color: theme.textSecondary,
            fontSize: 14,
            height: 1.8,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Text(
          'بارك الله فيك',
          style: TextStyle(
            fontFamily: 'Hafs',
            fontSize: 22,
            color: theme.accent,
          ),
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }
}

// ── Ring painter ────────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color trackColor;

  const _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - 20) / 2;
    const stroke = 14.0;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );

    // Progress arc
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress.clamp(0.0, 1.0),
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.trackColor != trackColor;
}
