import 'package:flutter/material.dart';

class Quote {
  final String text;
  final String author;
  final DateTime createdAt;
  final String? id;
  bool isFavorite;
  Color? cardColor; // Add color property to remember card color

  Quote({
    required this.text,
    required this.author,
    required this.createdAt,
    this.id,
    this.isFavorite = false,
    this.cardColor,
  });

  // Convert Quote object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'author': author,
      'createdAt': createdAt.toIso8601String(),
      'id': id,
      'isFavorite': isFavorite,
      // We can't store Color in JSON directly
    };
  }

  // Create a Quote object from a JSON map
  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      text: json['text'],
      author: json['author'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  // Create a Quote object from Zen Quotes API
  factory Quote.fromZenQuotesApi(Map<String, dynamic> json) {
    return Quote(
      text: json['q'],
      author: json['a'],
      createdAt: DateTime.now(),
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      isFavorite: false,
    );
  }

  // Create a copy of the Quote with modified properties
  Quote copyWith({
    String? text,
    String? author,
    DateTime? createdAt,
    String? id,
    bool? isFavorite,
    Color? cardColor,
  }) {
    return Quote(
      text: text ?? this.text,
      author: author ?? this.author,
      createdAt: createdAt ?? this.createdAt,
      id: id ?? this.id,
      isFavorite: isFavorite ?? this.isFavorite,
      cardColor: cardColor ?? this.cardColor,
    );
  }
}