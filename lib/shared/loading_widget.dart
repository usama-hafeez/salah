import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().current;
    return Center(
      child: CircularProgressIndicator(
        color: theme.accent,
        strokeWidth: 2.5,
      ),
    );
  }
}
