import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quote_master/constants/colors.dart';
import 'package:quote_master/constants/text_styles.dart';
import 'package:quote_master/models/quote.dart';
import 'package:quote_master/services/share_service.dart';

class QuoteCard extends StatefulWidget {
  final Quote quote;
  final Color color;
  final Function(BuildContext, Quote)? onMoreTap;
  final bool isAnimated;

  const QuoteCard({
    Key? key,
    required this.quote,
    required this.color,
    this.onMoreTap,
    this.isAnimated = false,
  }) : super(key: key);

  @override
  State<QuoteCard> createState() => _QuoteCardState();
}

class _QuoteCardState extends State<QuoteCard> with SingleTickerProviderStateMixin {
  final GlobalKey _moreButtonKey = GlobalKey();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    // Update the quote's color reference
    if (widget.quote.cardColor != widget.color) {
      widget.quote.cardColor = widget.color;
    }

    // Initialize animation controller
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Scale animation
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    // Opacity animation
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    if (widget.isAnimated) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: widget.isAnimated ? _opacityAnimation.value : 1.0,
          child: Transform.scale(
            scale: widget.isAnimated ? _scaleAnimation.value : 1.0,
            child: _buildCardContent(),
          ),
        );
      },
    );
  }

  Widget _buildCardContent() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(_isHovered ? 0.25 : 0.15),
              blurRadius: _isHovered ? 12 : 8,
              offset: _isHovered
                  ? const Offset(0, 5)
                  : const Offset(0, 3),
              spreadRadius: _isHovered ? 1 : 0,
            ),
          ],
          border: Border.all(
            color: widget.color.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quote icon with animation
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: Icon(
                  Icons.format_quote,
                  color: widget.color,
                  size: 28,
                ),
              ),
            ),

            // Quote text
            Text(
              widget.quote.text,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: AppColors.textDark,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
            ),

            const SizedBox(height: 16),

            // Author and actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "— ${widget.quote.author}",
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: AppColors.textMedium,
                  ),
                ),

                Row(
                  children: [
                    _buildActionButton(
                      icon: Icons.copy,
                      tooltip: 'Copy quote',
                      onTap: () => _copyQuoteToClipboard(context),
                    ),
                    const SizedBox(width: 8),
                    _buildActionButton(
                      icon: Icons.more_horiz,
                      tooltip: 'More options',
                      onTap: () => _showMoreOptions(context),
                      key: _moreButtonKey,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    Key? key,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: Container(
            key: key,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: widget.color,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }

  void _copyQuoteToClipboard(BuildContext context) {
    final textToCopy = '"${widget.quote.text}" — ${widget.quote.author}';
    Clipboard.setData(ClipboardData(text: textToCopy));

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text('Quote copied to clipboard'),
          ],
        ),
        backgroundColor: widget.color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    if (widget.onMoreTap == null) return;

    // Get position of the more button
    final RenderBox renderBox = _moreButtonKey.currentContext!.findRenderObject() as RenderBox;
    final Offset position = renderBox.localToGlobal(Offset.zero);

    // Calculate position for menu to appear
    final RelativeRect rect = RelativeRect.fromLTRB(
      position.dx - 120, // Position menu to the left
      position.dy + 20,  // Position menu below the button
      position.dx + 20,  // Right edge
      0,                 // Bottom edge
    );

    // Show animated popup menu
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) => Container(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );

        return Stack(
          children: [
            Positioned(
              top: rect.top,
              left: rect.left,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0).animate(curvedAnimation),
                alignment: Alignment.topRight,
                child: FadeTransition(
                  opacity: animation,
                  child: Material(
                    color: widget.color.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                    elevation: 8,
                    child: Container(
                      width: 180,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildMenuItem(
                            icon: Icons.share,
                            label: 'Share Quote',
                            onTap: () {
                              Navigator.pop(context);
                              ShareService.shareQuote(widget.quote, context: context);
                            },
                          ),
                          _buildMenuItem(
                            icon: Icons.delete_outline,
                            label: 'Remove',
                            onTap: () {
                              Navigator.pop(context);
                              widget.onMoreTap!(context, widget.quote);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}