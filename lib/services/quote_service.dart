import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quote_master/models/quote.dart';
import 'package:quote_master/utils/storage_helper.dart';

class QuoteService extends ChangeNotifier {
  Quote? _currentQuote;
  List<Quote> _favoriteQuotes = [];
  bool _isLoading = false;

  Quote? get currentQuote => _currentQuote;
  List<Quote> get favoriteQuotes => _favoriteQuotes;
  bool get isLoading => _isLoading;

  QuoteService() {
    _loadFavoriteQuotes();
  }

  // Fetch a random quote from API
  Future<void> fetchRandomQuote() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Using Quotable API which provides consistently random quotes
      final response = await http.get(
        Uri.parse('https://api.quotable.io/random'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        _currentQuote = Quote(
          text: data['content'],
          author: data['author'],
          createdAt: DateTime.now(),
          id: data['_id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        );

        // Check if this quote is already a favorite
        _currentQuote = _currentQuote!.copyWith(
            isFavorite:
                _isFavorite(_currentQuote!.text, _currentQuote!.author));
      } else {
        // Try alternate API if first one fails
        await _tryAlternateAPI();
      }
    } catch (e) {
      // Try alternate API if first one fails with exception
      await _tryAlternateAPI();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Try an alternate API if the primary one fails
  Future<void> _tryAlternateAPI() async {
    try {
      // Using Type.fit API as backup
      final response = await http.get(
        Uri.parse('https://type.fit/api/quotes'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> quotes = jsonDecode(response.body);
        if (quotes.isNotEmpty) {
          // Get a random quote from the list
          final random = DateTime.now().millisecondsSinceEpoch % quotes.length;
          final quoteData = quotes[random];

          _currentQuote = Quote(
            text: quoteData['text'],
            author: quoteData['author'] ?? 'Unknown',
            createdAt: DateTime.now(),
            id: DateTime.now().millisecondsSinceEpoch.toString(),
          );

          // Check if this quote is already a favorite
          _currentQuote = _currentQuote!.copyWith(
              isFavorite:
                  _isFavorite(_currentQuote!.text, _currentQuote!.author));
          return;
        }
      }
      // If all APIs fail, use fallback
      _createFallbackQuote();
    } catch (e) {
      _createFallbackQuote();
    }
  }

  // Create a fallback quote when API fails
  void _createFallbackQuote() {
    // List of fallback quotes to use when API fails
    final fallbackQuotes = [
      {
        "text": "The best way to predict the future is to create it.",
        "author": "Abraham Lincoln"
      },
      {
        "text": "Life is what happens when you're busy making plans.",
        "author": "John Lennon"
      },
      {
        "text": "The only way to do great work is to love what you do.",
        "author": "Steve Jobs"
      },
      {
        "text": "Believe you can and you're halfway there.",
        "author": "Theodore Roosevelt"
      },
      {
        "text":
            "Your time is limited, don't waste it living someone else's life.",
        "author": "Steve Jobs"
      },
      {
        "text": "The purpose of our lives is to be happy.",
        "author": "Dalai Lama"
      },
      {
        "text": "In the middle of difficulty lies opportunity.",
        "author": "Albert Einstein"
      },
    ];

    // Pick a random quote from the fallback list
    final random =
        DateTime.now().millisecondsSinceEpoch % fallbackQuotes.length;
    final quote = fallbackQuotes[random];

    _currentQuote = Quote(
      text: quote["text"]!,
      author: quote["author"]!,
      createdAt: DateTime.now(),
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  // Check if a quote is already in favorites
  bool _isFavorite(String text, String author) {
    return _favoriteQuotes
        .any((quote) => quote.text == text && quote.author == author);
  }

  // Toggle favorite status for the current quote
  void toggleFavorite() {
    if (_currentQuote != null) {
      final quote = _currentQuote!;
      quote.isFavorite = !quote.isFavorite;

      if (quote.isFavorite) {
        // Add to favorites if not already there
        if (!_isFavorite(quote.text, quote.author)) {
          _favoriteQuotes.add(quote);
        }
      } else {
        // Remove from favorites
        _favoriteQuotes.removeWhere(
            (q) => q.text == quote.text && q.author == quote.author);
      }

      _saveFavoriteQuotes();
      notifyListeners();
    }
  }

  // Remove a quote from favorites
  void removeFavorite(String quoteId) {
    final removedQuote = _favoriteQuotes.firstWhere(
      (quote) => quote.id == quoteId,
      orElse: () => Quote(
        text: "",
        author: "",
        createdAt: DateTime.now(),
      ),
    );

    if (removedQuote.text.isNotEmpty) {
      _favoriteQuotes.removeWhere((quote) => quote.id == quoteId);

      // Update current quote's favorite status if it matches
      if (_currentQuote != null &&
          _currentQuote!.text == removedQuote.text &&
          _currentQuote!.author == removedQuote.author) {
        _currentQuote = _currentQuote!.copyWith(isFavorite: false);
      }

      _saveFavoriteQuotes();
      notifyListeners();
    }
  }

  // Load favorite quotes from local storage
  Future<void> _loadFavoriteQuotes() async {
    final quotes = await StorageHelper.getFavoriteQuotes();
    _favoriteQuotes = quotes;
    notifyListeners();
  }

  // Save favorite quotes to local storage
  Future<void> _saveFavoriteQuotes() async {
    await StorageHelper.saveFavoriteQuotes(_favoriteQuotes);
  }
}
