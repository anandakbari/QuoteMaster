import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quote_master/constants/colors.dart';
import 'package:quote_master/constants/text_styles.dart';
import 'package:quote_master/models/quote.dart';
import 'package:quote_master/services/quote_service.dart';
import 'package:quote_master/widgets/quote_card.dart';
import 'package:quote_master/services/share_service.dart';

class LikedQuotesScreen extends StatefulWidget {
  const LikedQuotesScreen({Key? key}) : super(key: key);

  @override
  State<LikedQuotesScreen> createState() => _LikedQuotesScreenState();
}

class _LikedQuotesScreenState extends State<LikedQuotesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Animated header
          _buildAnimatedHeader(),

          // Quote list
          Expanded(
            child: Consumer<QuoteService>(
              builder: (context, quoteService, child) {
                final quotes = quoteService.favoriteQuotes;

                if (quotes.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildQuotesList(quotes);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        top: 50,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary,
            AppColors.primary.withBlue((AppColors.primary.blue + 20).clamp(
                0, 255)),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back button with ripple effect
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              // Header title with animation
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.5),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Curves.easeOutBack,
                  ),
                ),
                child: Row(
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0.5, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: child,
                        );
                      },
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Liked Quotes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 40), // For balance
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return FadeTransition(
      opacity: _opacityAnimation,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty state icon with animation
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 1500),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Icon(
                Icons.favorite_border,
                size: 80,
                color: AppColors.primary.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 16),
            // Empty state text
            const Text(
              'No favorite quotes yet',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textMedium,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Heart quotes you love to see them here',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuotesList(List<Quote> quotes) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _opacityAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ListView.builder(
              padding: const EdgeInsets.only(
                  top: 16, bottom: 24, left: 16, right: 16),
              itemCount: quotes.length,
              itemBuilder: (context, index) {
                // Stagger the animations of list items
                final itemAnimation = CurvedAnimation(
                  parent: _animationController,
                  curve: Interval(
                    0.1 + (index * 0.1).clamp(0.0, 0.9), // Staggered intervals
                    1.0,
                    curve: Curves.easeOut,
                  ),
                );

                final quote = quotes[index];
                final colorIndex = index % AppColors.quoteCardColors.length;
                final color = AppColors.quoteCardColors[colorIndex];

                return FadeTransition(
                  opacity: itemAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.5, 0),
                      end: Offset.zero,
                    ).animate(itemAnimation),
                    child: _buildEnhancedQuoteCard(quote, color, context),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedQuoteCard(Quote quote, Color color,
      BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        child: InkWell(
          onTap: () => _showQuoteOptions(context, quote, color),
          splashColor: color.withOpacity(0.1),
          highlightColor: color.withOpacity(0.05),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
              border: Border.all(
                color: color.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quote icon
                Icon(
                  Icons.format_quote,
                  color: color,
                  size: 24,
                ),
                const SizedBox(height: 8),
                // Quote text
                Text(
                  quote.text,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.4,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                // Author and options row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "— ${quote.author}",
                      style: const TextStyle(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: AppColors.textMedium,
                      ),
                    ),
                    Row(
                      children: [
                        _buildActionButton(
                          icon: Icons.copy,
                          color: color,
                          onTap: () => _copyQuoteToClipboard(quote, context),
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          icon: Icons.share,
                          color: color,
                          onTap: () {
                            ShareService.shareQuote(quote, context: context);
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildActionButton(
                          icon: Icons.delete_outline,
                          color: color,
                          onTap: () => _deleteQuote(quote, context),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color: color,
          ),
        ),
      ),
    );
  }

  void _copyQuoteToClipboard(Quote quote, BuildContext context) {
    final textToCopy = '"${quote.text}" — ${quote.author}';
    Clipboard.setData(ClipboardData(text: textToCopy));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text('Quote copied to clipboard'),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _deleteQuote(Quote quote, BuildContext context) {
    if (quote.id != null) {
      // Show confirmation dialog with animation
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: 'Dismiss',
        barrierColor: Colors.black.withOpacity(0.5),
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, anim1, anim2) => Container(),
        transitionBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          );

          return ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
            child: FadeTransition(
              opacity: animation,
              child: AlertDialog(
                title: const Text('Remove from favorites?'),
                content: const Text(
                  'This quote will be removed from your favorites list.',
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Provider.of<QuoteService>(context, listen: false)
                          .removeFavorite(quote.id!);
                      Navigator.of(context).pop();

                      // Show success snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Quote removed from favorites'),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Remove'),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  void _showQuoteOptions(BuildContext context, Quote quote, Color color) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 100 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Quote display
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.format_quote,
                        color: color,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        quote.text,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "— ${quote.author}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Actions
                Column(
                  children: [
                    _buildActionItem(
                      icon: Icons.copy,
                      label: 'Copy to clipboard',
                      onTap: () {
                        _copyQuoteToClipboard(quote, context);
                        Navigator.pop(context);
                      },
                    ),
                    const Divider(),
                    _buildActionItem(
                      icon: Icons.share,
                      label: 'Share quote',
                      onTap: () {
                        Navigator.pop(context);
                        // Share functionality would be implemented here
                      },
                    ),
                    const Divider(),
                    _buildActionItem(
                      icon: Icons.delete_outline,
                      label: 'Remove from favorites',
                      onTap: () {
                        Navigator.pop(context);
                        _deleteQuote(quote, context);
                      },
                      textColor: Colors.redAccent,
                      iconColor: Colors.redAccent,
                    ),
                  ],
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: iconColor ?? AppColors.textMedium,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: textColor ?? AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}