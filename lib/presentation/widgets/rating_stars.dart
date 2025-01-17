import 'package:flutter/material.dart';
import 'dart:math' as math;

class RatingStars extends StatefulWidget {
  final double rating;
  final double size;
  final bool isInteractive;
  final Function(double)? onRatingChanged;
  final Color? color;
  final Map<int, int>? distribution;
  final int? totalRatings;
  final bool showRatingText;
  final Function(bool)? onExpanded;
  final double? frameWidth;
  final double? maxWidth;
  final double? curveHeight;
  final double? sizeModifier;
  final double starSpacing;
  final double curvature;
  final int numberOfStars;

  const RatingStars({
    Key? key,
    required this.rating,
    this.size = 24.0,
    this.isInteractive = false,
    this.onRatingChanged,
    this.color,
    this.distribution,
    this.totalRatings,
    this.showRatingText = false,
    this.onExpanded,
    this.curveHeight,
    this.frameWidth,
    this.maxWidth,
    this.sizeModifier,
    this.starSpacing = 3.6,
    this.curvature = 0.3,
    this.numberOfStars = 5,
  }) : super(key: key);

  @override
  State<RatingStars> createState() => _RatingStarsState();
}

class _RatingStarsState extends State<RatingStars> {
  bool _expanded = false;
  double? _dragRating;
  Path? _starPath;

  @override
  void initState() {
    super.initState();
    _starPath = _createStarPath(Offset.zero, widget.size);
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isInteractive) return;
    _updateRatingFromPosition(details.localPosition);
    widget.onRatingChanged?.call(_dragRating ?? widget.rating);
    setState(() {
      _dragRating = null;
    });
  }

  void _updateRatingFromPosition(Offset localPosition) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final double dx = localPosition.dx.clamp(0, box.size.width);
    final rating = ((dx / box.size.width) * widget.numberOfStars)
        .clamp(0, widget.numberOfStars.toDouble());
    final halfRating = (rating * 2).round() / 2;
    
    if (_dragRating != halfRating) {
      setState(() {
        _dragRating = halfRating;
      });
    }
  }

  Widget _buildRatingStats() {
    if (!_expanded || widget.distribution == null || widget.totalRatings == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showRatingText)
            Text(
              '${widget.rating.toStringAsFixed(1)} (${widget.totalRatings} ${widget.totalRatings == 1 ? 'rating' : 'ratings'})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          const SizedBox(height: 16),
          Text(
            'Rating Distribution',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 8),
          for (var i = 5; i >= 1; i--)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$i star',
                    style: const TextStyle(color: Colors.amber),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 150,
                    child: LinearProgressIndicator(
                      value: widget.totalRatings! > 0
                          ? (widget.distribution![i] ?? 0) / widget.totalRatings!
                          : 0,
                      backgroundColor: Colors.grey[800],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${widget.distribution![i] ?? 0}',
                    style: const TextStyle(color: Colors.amber),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTapDown: _handleTapDown,
            onTap: widget.distribution != null && widget.onExpanded != null
                ? () {
                    setState(() {
                      _expanded = !_expanded;
                      widget.onExpanded?.call(_expanded);
                    });
                  }
                : null,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final effectiveWidth =
                    widget.frameWidth ?? widget.maxWidth ?? constraints.maxWidth;
                final effectiveCurveHeight =
                    widget.curveHeight ?? (widget.size * widget.curvature);
                final effectiveStarSizeIncrease =
                    widget.sizeModifier != null ? 1 + widget.sizeModifier! : 1.2;

                return SizedBox(
                  width: effectiveWidth,
                  height: widget.size * effectiveStarSizeIncrease * (1 + widget.curvature),
                  child: CustomPaint(
                    painter: StarsPainter(
                      rating: _dragRating ?? widget.rating,
                      starSize: widget.size,
                      color: widget.color ?? Colors.amber,
                      starSizeIncrease: effectiveStarSizeIncrease,
                      starSpacing: widget.starSpacing,
                      curvature: effectiveCurveHeight / widget.size,
                      numberOfStars: widget.numberOfStars,
                      starPath: _starPath!,
                    ),
                  ),
                );
              },
            ),
          ),
          _buildRatingStats(),
        ],
      ),
    );
  }

  Path _createStarPath(Offset center, double size) {
    final path = Path();
    final halfSize = size / 2;
    final outerRadius = halfSize;
    final innerRadius = halfSize * 0.4;

    for (int i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + i * math.pi * 2 / 5;
      final outerPoint = Offset(
        center.dx + math.cos(angle) * outerRadius,
        center.dy + math.sin(angle) * outerRadius,
      );
      final innerAngle = angle + math.pi / 5;
      final innerPoint = Offset(
        center.dx + math.cos(innerAngle) * innerRadius,
        center.dy + math.sin(innerAngle) * innerRadius,
      );

      if (i == 0) {
        path.moveTo(outerPoint.dx, outerPoint.dy);
      } else {
        path.lineTo(outerPoint.dx, outerPoint.dy);
      }
      path.lineTo(innerPoint.dx, innerPoint.dy);
    }
    path.close();
    return path;
  }
}

class StarsPainter extends CustomPainter {
  final double rating;
  final double starSize;
  final Color color;
  final double starSizeIncrease;
  final double starSpacing;
  final double curvature;
  final int numberOfStars;
  final Path starPath;

  StarsPainter({
    required this.rating,
    required this.starSize,
    required this.color,
    required this.starSizeIncrease,
    required this.starSpacing,
    required this.curvature,
    required this.numberOfStars,
    required this.starPath,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;

    final baseSpacing = size.width / (numberOfStars * starSpacing);
    final totalStarsWidth = starSize * numberOfStars * starSizeIncrease;
    final totalSpacingWidth = baseSpacing * (numberOfStars - 1);
    final startX = (size.width - (totalStarsWidth + totalSpacingWidth)) / 2;

    for (int i = 0; i < numberOfStars; i++) {
      final progress = i / (numberOfStars - 1);
      final x = startX + (starSize * starSizeIncrease + baseSpacing) * i;
      
      final normalizedX = progress * 2 - 1;
      final curveOffset = size.height * curvature * (1 - normalizedX * normalizedX);
      final y = (size.height - starSize) / 2 - curveOffset;

      final currentSize = starSize * (1 + (starSizeIncrease - 1) * (1 - normalizedX * normalizedX));
      
      canvas.save();
      canvas.translate(x + currentSize / 2, y + currentSize / 2);
      canvas.scale(currentSize / starSize);
      
      if (rating >= i + 1) {
        canvas.drawPath(starPath, paint..style = PaintingStyle.fill);
      } else if (rating > i) {
        // Draw outline
        canvas.drawPath(starPath, paint..style = PaintingStyle.stroke);
        
        // Create and draw half-filled star
        final halfPath = Path();
        final rect = Rect.fromCenter(
          center: Offset.zero,
          width: starSize,
          height: starSize,
        );
        halfPath.addRect(Rect.fromLTRB(
          rect.left,
          rect.top,
          0,
          rect.bottom,
        ));
        
        canvas.drawPath(
          Path.combine(PathOperation.intersect, starPath, halfPath),
          paint..style = PaintingStyle.fill,
        );
      } else {
        canvas.drawPath(starPath, paint..style = PaintingStyle.stroke);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(StarsPainter oldDelegate) {
    return oldDelegate.rating != rating ||
        oldDelegate.starSize != starSize ||
        oldDelegate.color != color ||
        oldDelegate.starSizeIncrease != starSizeIncrease ||
        oldDelegate.starSpacing != starSpacing ||
        oldDelegate.curvature != curvature ||
        oldDelegate.numberOfStars != numberOfStars;
  }
}
