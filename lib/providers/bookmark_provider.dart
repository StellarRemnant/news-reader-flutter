/// Handles loading, saving, and managing bookmarked news articles with state notification.

library;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/news_model.dart';


class BookmarkProvider with ChangeNotifier {
  static const _key = 'bookmarked_articles';

  List<News> _bookmarkedArticles = [];

  List<News> get bookmarkedArticles => _bookmarkedArticles;

  // Constructor: loads saved bookmarks when the provider is initialized
  BookmarkProvider() {
    _loadBookmarks();
  }

  // Loads bookmarks from local storage
  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];
    _bookmarkedArticles = jsonList
        .map((jsonStr) => News.fromJson(jsonDecode(jsonStr)))
        .toList();
    notifyListeners();
  }

  // Saves the current list of bookmarks to local storage
  Future<void> _saveBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _bookmarkedArticles
        .map((article) => jsonEncode(article.toJson()))
        .toList();
    await prefs.setStringList(_key, jsonList);
  }

  bool isBookmarked(String title) {
    return _bookmarkedArticles.any((a) => a.title == title);
  }

  Future<void> toggleBookmark(News article) async {
    final existingIndex =
        _bookmarkedArticles.indexWhere((a) => a.title == article.title);
    if (existingIndex >= 0) {
      _bookmarkedArticles.removeAt(existingIndex);
    } else {
      _bookmarkedArticles.add(article);
    }
    await _saveBookmarks();
    notifyListeners();
  }
}
