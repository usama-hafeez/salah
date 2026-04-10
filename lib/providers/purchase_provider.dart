import 'package:flutter/material.dart';
import '../core/services/purchase_service.dart';
import '../core/services/storage_service.dart';

class PurchaseProvider extends ChangeNotifier {
  PurchaseProvider() {
    // Wire purchase completions back to this provider so the UI rebuilds
    PurchaseService.onProStatusChanged = _onProStatusChanged;
  }

  bool get isPro => StorageService.isPro;

  void _onProStatusChanged() {
    notifyListeners();
  }

  void refresh() {
    notifyListeners();
  }

  @override
  void dispose() {
    // Clear callback to avoid calling into a disposed provider
    PurchaseService.onProStatusChanged = null;
    super.dispose();
  }
}
