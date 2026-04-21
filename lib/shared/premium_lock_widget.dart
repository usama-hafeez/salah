import 'package:flutter/material.dart';

class PremiumLockWidget extends StatelessWidget {
  final Widget child;
  final VoidCallback onUpgrade;
  final String? description;

  const PremiumLockWidget({
    super.key,
    required this.child,
    required this.onUpgrade,
    this.description,
  });

  @override
  Widget build(BuildContext context) => child;
}
