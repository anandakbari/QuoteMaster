import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quote_master/constants/colors.dart';
import 'package:quote_master/constants/text_styles.dart';
import 'package:quote_master/screens/liked_quotes_screen.dart';
import 'package:quote_master/services/quote_service.dart';
import 'package:quote_master/widgets/loading_animation.dart';
import 'package:quote_master/models/quote.dart';
import 'package:quote_master/services/share_service.dart';
import 'package:quote_master/services/quote_service.dart';

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({Key? key}) : super(key: key);

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> with SingleTickerProviderStateMixin {
  int _colorIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Set initial color to purple (primary color)
    _colorIndex = AppColors.quoteCardColors.indexOf(AppColors.primary);
    if (_colorIndex == -1) _colorIndex = 0;

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Create animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Fetch a random quote when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<QuoteService>(context, listen: false).fetchRandomQuote();
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _fetchNewQuote() {
    // Reset animation and change color
    _animationController.reset();
    setState(() {
      _colorIndex = (_colorIndex + 1) % AppColors.quoteCardColors.length;
    });

    // Fetch new quote and animate
    Provider.of<QuoteService>(context, listen: false).fetchRandomQuote();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(),
      body: SafeArea(
        child: Column(
          children: [
            // App bar with animated background
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _getBackgroundColor().withOpacity(0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'QuoteMaster',
                    style: AppTextStyles.appTitle,
                  ),
                  // Create a custom PopupMenuButton
                  Theme(
                    // Apply a custom theme to just this widget to ensure menu styles
                    data: Theme.of(context).copyWith(
                      popupMenuTheme: PopupMenuThemeData(
                        color: _getBackgroundColor().withOpacity(0.9),
                        elevation: 8,
                        textStyle: const TextStyle(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    child: PopupMenuButton<String>(
                      // Important: use the following to build a custom button
                      // rather than using the default icon
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            '⋮',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // This controls where the menu appears relative to the button
                      offset: const Offset(0, 10),
                      // Don't use any automatic icon
                      icon: null,
                      onSelected: (value) {
                        if (value == 'liked') {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) =>
                              const LikedQuotesScreen(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                var begin = const Offset(1.0, 0.0);
                                var end = Offset.zero;
                                var curve = Curves.easeInOut;
                                var tween = Tween(begin: begin, end: end)
                                    .chain(CurveTween(curve: curve));
                                return SlideTransition(
                                  position: animation.drive(tween),
                                  child: child,
                                );
                              },
                            ),
                          );
                        } else if (value == 'about') {
                          _showAppVersionDialog(context);
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem<String>(
                          value: 'liked',
                          child: Row(
                            children: const [
                              Icon(Icons.favorite, size: 18, color: Colors.white),
                              SizedBox(width: 8),
                              Text('Liked Quotes', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'about',
                          child: Row(
                            children: const [
                              Icon(Icons.info_outline, size: 18, color: Colors.white),
                              SizedBox(width: 8),
                              Text('App Version', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: Consumer<QuoteService>(
                builder: (context, quoteService, child) {
                  if (quoteService.isLoading) {
                    return const Center(
                      child: LoadingAnimation(),
                    );
                  }

                  final quote = quoteService.currentQuote;
                  if (quote == null) {
                    return const Center(
                      child: Text(
                        'No quote available',
                        style: TextStyle(color: AppColors.white),
                      ),
                    );
                  }

                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated quote card
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: ScaleTransition(
                                scale: _scaleAnimation,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        blurRadius: 15,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Quote icon
                                      Container(
                                        margin: const EdgeInsets.only(bottom: 16),
                                        child: Icon(
                                          Icons.format_quote,
                                          color: _getBackgroundColor(),
                                          size: 36,
                                        ),
                                      ),
                                      // Quote text
                                      Text(
                                        quote.text,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          height: 1.5,
                                          color: AppColors.textDark,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      // Author and copy button
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              "— ${quote.author}",
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontStyle: FontStyle.italic,
                                                color: AppColors.textMedium,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            TweenAnimationBuilder<double>(
                                              tween: Tween<double>(begin: 0.0, end: 1.0),
                                              duration: const Duration(milliseconds: 600),
                                              curve: Curves.elasticOut,
                                              builder: (context, value, child) {
                                                return Transform.scale(
                                                  scale: value,
                                                  child: child,
                                                );
                                              },
                                              child: GestureDetector(
                                                onTap: () => _copyQuoteToClipboard(quote),
                                                child: Container(
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: _getBackgroundColor().withOpacity(0.1),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Icon(
                                                    Icons.copy,
                                                    size: 16,
                                                    color: _getBackgroundColor(),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom buttons with animated background
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                color: _getBackgroundColor().withOpacity(0.85),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Share button with hover effect
                      Consumer<QuoteService>(
                        builder: (context, quoteService, _) {
                          return _AnimatedActionButton(
                            icon: Icons.share,
                            label: 'Share',
                            onTap: () {
                              final quote = quoteService.currentQuote;
                              if (quote != null) {
                                ShareService.shareQuote(quote, context: context);
                              }
                            },
                          );
                        },
                      ),
                      const SizedBox(width: 20),

                      // Favorite button with animation
                      Consumer<QuoteService>(
                        builder: (context, quoteService, _) {
                          final isFavorite = quoteService.currentQuote?.isFavorite ?? false;
                          return _AnimatedFavoriteButton(
                            isFavorite: isFavorite,
                            onTap: () {
                              quoteService.toggleFavorite();
                            },
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Fetch new quote button with animation
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.9, end: 1.0),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.elasticOut,
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _fetchNewQuote,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: _getBackgroundColor(),
                          elevation: 4,
                          shadowColor: Colors.black.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.refresh, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'New Quote',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _getBackgroundColor(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAppVersionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About QuoteMaster'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('Daily Wisdom at your fingertips'),
            SizedBox(height: 16),
            Text('© 2025 QuoteMaster', style: TextStyle(fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _copyQuoteToClipboard(Quote quote) {
    final textToCopy = '"${quote.text}" — ${quote.author}';

    // Copy to clipboard
    Clipboard.setData(ClipboardData(text: textToCopy));

    // Show confirmation with animated snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Quote copied to clipboard'),
          ],
        ),
        backgroundColor: _getBackgroundColor(),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        animation: CurvedAnimation(
          parent: const AlwaysStoppedAnimation(1),
          curve: Curves.elasticOut,
        ),
      ),
    );
  }

  // Get the current background color based on the color index
  Color _getBackgroundColor() {
    return AppColors.quoteCardColors[_colorIndex];
  }
}

// Custom animated action button
class _AnimatedActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AnimatedActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  _AnimatedActionButtonState createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<_AnimatedActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(_isHovered ? 0.3 : 0.2),
            borderRadius: BorderRadius.circular(22),
            boxShadow: _isHovered
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ]
                : null,
          ),
          child: Center(
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  color: AppColors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Custom animated favorite button
class _AnimatedFavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onTap;

  const _AnimatedFavoriteButton({
    required this.isFavorite,
    required this.onTap,
  });

  @override
  _AnimatedFavoriteButtonState createState() => _AnimatedFavoriteButtonState();
}

class _AnimatedFavoriteButtonState extends State<_AnimatedFavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void didUpdateWidget(_AnimatedFavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFavorite != oldWidget.isFavorite && widget.isFavorite) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () {
          widget.onTap();
          if (!widget.isFavorite) {
            _controller.forward(from: 0.0);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(_isHovered ? 0.3 : 0.2),
            shape: BoxShape.circle,
            boxShadow: _isHovered
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ]
                : null,
          ),
          child: Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: widget.isFavorite ? _scaleAnimation.value : 1.0,
                  child: Icon(
                    widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: widget.isFavorite ? Colors.red : AppColors.white,
                    size: 20,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}