import 'package:flutter/material.dart';

class FavoritesProvider with ChangeNotifier {
  final Set<String> _favoriteFileIds = {};

  Set<String> get favoriteFileIds => _favoriteFileIds;

  bool isFavorite(String fileId) => _favoriteFileIds.contains(fileId);

  void toggleFavorite(String fileId) {
    if (_favoriteFileIds.contains(fileId)) {
      _favoriteFileIds.remove(fileId);
    } else {
      _favoriteFileIds.add(fileId);
    }
    notifyListeners();
  }

  void clearFavorites() {
    _favoriteFileIds.clear();
    notifyListeners();
  }
}
