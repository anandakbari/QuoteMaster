import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quote_master/models/quote.dart';

class StorageHelper {
  static const String _favoritesKey = 'favorite_quotes';

  // Save favorite quotes to SharedPreferences
  static Future<void> saveFavoriteQuotes(List<Quote> quotes) async {
    final prefs = await SharedPreferences.getInstance();
    final quotesJson =
        quotes.map((quote) => jsonEncode(quote.toJson())).toList();
    await prefs.setStringList(_favoritesKey, quotesJson);
  }

  // Get favorite quotes from SharedPreferences
  static Future<List<Quote>> getFavoriteQuotes() async {
    final prefs = await SharedPreferences.getInstance();
    final quotesJson = prefs.getStringList(_favoritesKey) ?? [];

    return quotesJson
        .map((quoteString) => Quote.fromJson(jsonDecode(quoteString)))
        .toList();
  }
}
