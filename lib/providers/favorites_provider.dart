import 'package:flutter/material.dart';

class FavoritesProvider with ChangeNotifier {
  final Set<String> _favoriteFileIds = {};

  // تحقق إذا الملف موجود بالمفضلة
  bool isFavorite(String fileId) => _favoriteFileIds.contains(fileId);

  // تبديل حالة المفضلة
  void toggleFavorite(String fileId) {
    if (_favoriteFileIds.contains(fileId)) {
      _favoriteFileIds.remove(fileId);
    } else {
      _favoriteFileIds.add(fileId);
    }
    notifyListeners();
  }
}
