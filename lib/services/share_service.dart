import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quote_master/models/quote.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  /// Share a quote using the device's share functionality
  static Future<void> shareQuote(Quote quote, {BuildContext? context}) async {
    final text = '"${quote.text}" — ${quote.author}';

    try {
      // Use Share without position origin to avoid RenderBox errors
      await Share.share(
        text,
        subject: 'Check out this quote from QuoteMaster!',
      );
    } catch (e) {
      debugPrint('Error sharing quote: $e');

      // Fallback to clipboard if Share fails
      await Clipboard.setData(ClipboardData(text: text));

      if (context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quote copied to clipboard. You can now paste it anywhere to share.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }
}