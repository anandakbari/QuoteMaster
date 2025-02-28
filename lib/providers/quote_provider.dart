import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/quote.dart';

class QuoteProvider with ChangeNotifier {
  final SharedPreferences prefs;
  Quote? _currentQuote;
  List<Quote> _favoriteQuotes = [];
  bool _isLoading = false;
  String? _error;

  QuoteProvider(this.prefs) {
    _loadFavoriteQuotes();
  }

  Quote? get currentQuote => _currentQuote;
  List<Quote> get favoriteQuotes => _favoriteQuotes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch a random quote from the API
  Future<void> fetchRandomQuote() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response =
          await http.get(Uri.parse('https://zenquotes.io/api/random'));

      if (response.statusCode == 200) {
        final List<dynamic> dataList = jsonDecode(response.body);

        if (dataList.isNotEmpty) {
          final data = dataList[0]; // Get the first quote from the array
          final newQuote = Quote.fromJson(data);

          // Check if the quote is already in favorites
          final isFavorite =
              _favoriteQuotes.any((quote) => quote.id == newQuote.id);
          _currentQuote = newQuote.copyWith(isFavorite: isFavorite);
        } else {
          _error = 'No quotes returned from API';
        }
      } else {
        _error = 'Failed to load quote. Please try again.';
      }
    } catch (e) {
      _error =
          'Error connecting to the service. Please check your internet connection.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle favorite status of current quote
  void toggleFavorite() {
    if (_currentQuote == null) return;

    final isFavorite = !(_currentQuote!.isFavorite);
    _currentQuote = _currentQuote!.copyWith(isFavorite: isFavorite);

    if (isFavorite) {
      // Add to favorites if not already present
      if (!_favoriteQuotes.any((quote) => quote.id == _currentQuote!.id)) {
        _favoriteQuotes.add(_currentQuote!);
      }
    } else {
      // Remove from favorites
      _favoriteQuotes.removeWhere((quote) => quote.id == _currentQuote!.id);
    }

    _saveFavoriteQuotes();
    notifyListeners();
  }

  // Delete a quote from favorites
  void deleteFavorite(String quoteId) {
    _favoriteQuotes.removeWhere((quote) => quote.id == quoteId);

    // If current quote's id matches the deleted quote, update its favorite status
    if (_currentQuote != null && _currentQuote!.id == quoteId) {
      _currentQuote = _currentQuote!.copyWith(isFavorite: false);
    }

    _saveFavoriteQuotes();
    notifyListeners();
  }

  // Load favorite quotes from SharedPreferences
  Future<void> _loadFavoriteQuotes() async {
    final quotesJson = prefs.getStringList('favoriteQuotes') ?? [];
    _favoriteQuotes = quotesJson
        .map((quoteJson) => Quote.fromJson(jsonDecode(quoteJson)))
        .toList();
    notifyListeners();
  }

  // Save favorite quotes to SharedPreferences
  Future<void> _saveFavoriteQuotes() async {
    final quotesJson =
        _favoriteQuotes.map((quote) => jsonEncode(quote.toJson())).toList();
    await prefs.setStringList('favoriteQuotes', quotesJson);
  }
}
