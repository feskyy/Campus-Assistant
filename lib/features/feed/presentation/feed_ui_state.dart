import 'package:flutter/foundation.dart';

class FeedUiState extends ChangeNotifier {
  FeedUiState({required bool initialEvents}) : eventsTab = initialEvents;
  String query = '', category = 'Все';
  bool eventsTab, favoritesOnly = false, oldestFirst = false;
  String eventTag = 'Все';
  void setEventTag(String value) {
    eventTag = value;
    notifyListeners();
  }

  void toggleSort() {
    oldestFirst = !oldestFirst;
    notifyListeners();
  }

  void setEvents(bool value) {
    eventsTab = value;
    notifyListeners();
  }

  void setQuery(String value) {
    query = value.trim().toLowerCase();
    notifyListeners();
  }

  void setCategory(String value) {
    category = value;
    notifyListeners();
  }

  void setFavoritesOnly(bool value) {
    favoritesOnly = value;
    notifyListeners();
  }
}
