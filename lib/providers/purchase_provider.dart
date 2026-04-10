import 'package:flutter/material.dart';
import '../core/services/storage_service.dart';

class PurchaseProvider extends ChangeNotifier {
  bool get isPro => StorageService.isPro;

  void refresh() {
    notifyListeners();
  }
}
