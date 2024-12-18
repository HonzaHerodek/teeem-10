import 'dart:ui';
import 'package:flutter/material.dart';

/// Configuration for the dimming effect
class DimmingConfig {
  /// The color used for dimming the screen
  final Color dimmingColor;
  
  /// The opacity of the dimming effect (0.0 to 1.0)
  final double dimmingStrength;
  
  /// The color of the glow effect for excluded elements
  final Color glowColor;
  
  /// The spread radius of the glow effect
  final double glowSpread;
  
  /// The blur radius of the glow effect
  final double glowBlur;
  
  /// The strength of the glow effect (0.0 to 1.0)
  final double glowStrength;

  const DimmingConfig({
    this.dimmingColor = Colors.black,
    this.dimmingStrength = 0.5,
    this.glowColor = Colors.white,
    this.glowSpread = 4.0,
    this.glowBlur = 8.0,
    this.glowStrength = 0.3,
  });
}

/// A widget that applies a dimming effect to its child
class DimmingOverlay extends StatelessWidget {
  /// The child widget to be potentially dimmed
  final Widget child;
  
  /// Whether the dimming effect is currently active
  final bool isDimmed;
  
  /// Configuration for the dimming effect
  final DimmingConfig config;
  
  /// List of global keys for widgets that should be excluded from dimming
  final List<GlobalKey> excludedKeys;
  
  /// Optional offset from where the dimming effect should originate
  final Offset? source;

  static const Duration _animationDuration = Duration(milliseconds: 500);
  static const Curve _animationCurve = Curves.fastOutSlowIn;

  const DimmingOverlay({
    super.key,
    required this.child,
    required this.isDimmed,
    this.config = const DimmingConfig(),
    this.excludedKeys = const [],
    this.source,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
          IgnorePointer(
            ignoring: !isDimmed,
            child: AnimatedOpacity(
              opacity: isDimmed ? 1.0 : 0.0,
              duration: _animationDuration,
              curve: _animationCurve,
              child: _buildDimmingLayer(context),
            ),
          ),
      ],
    );
  }

  Widget _buildDimmingLayer(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          // Base dimming layer
          Container(
            color: config.dimmingColor.withOpacity(config.dimmingStrength),
          ),
          // Excluded elements with glow
          ...excludedKeys.map((key) => _buildExcludedElement(key, context)),
        ],
      ),
    );
  }

  Widget _buildExcludedElement(GlobalKey key, BuildContext context) {
    final RenderBox? renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return const SizedBox.shrink();

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final diameter = size.width;
    final extraPadding = config.glowSpread * 2;

    return Positioned(
      left: position.dx - extraPadding,
      top: position.dy - extraPadding,
      width: diameter + (extraPadding * 2),
      height: diameter + (extraPadding * 2),
      child: Center(
        child: AnimatedContainer(
          duration: _animationDuration,
          curve: _animationCurve,
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: config.glowColor.withOpacity(isDimmed ? config.glowStrength : 0.0),
                blurRadius: config.glowBlur * 2,
                spreadRadius: config.glowSpread,
              ),
            ],
          ),
          child: ClipOval(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: config.glowBlur * 0.25,
                sigmaY: config.glowBlur * 0.25,
              ),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Extension to easily add dimming effect to any widget
extension DimmingEffect on Widget {
  Widget withDimming({
    required bool isDimmed,
    DimmingConfig? config,
    List<GlobalKey> excludedKeys = const [],
    Offset? source,
  }) {
    return DimmingOverlay(
      isDimmed: isDimmed,
      config: config ?? const DimmingConfig(),
      excludedKeys: excludedKeys,
      source: source,
      child: this,
    );
  }
}

/// Mixin to help manage dimming state in widgets/screens
mixin DimmingController<T extends StatefulWidget> on State<T> {
  bool _isDimmed = false;
  final List<GlobalKey> _excludedKeys = [];
  DimmingConfig _config = const DimmingConfig();
  Offset? _source;

  bool get isDimmed => _isDimmed;
  List<GlobalKey> get excludedKeys => _excludedKeys;
  DimmingConfig get dimmingConfig => _config;
  Offset? get dimmingSource => _source;

  void setDimming({
    required bool isDimmed,
    DimmingConfig? config,
    List<GlobalKey> excludedKeys = const [],
    Offset? source,
  }) {
    setState(() {
      _isDimmed = isDimmed;
      _config = config ?? _config;
      _excludedKeys
        ..clear()
        ..addAll(excludedKeys);
      _source = source;
    });
  }

  void toggleDimming() {
    setState(() {
      _isDimmed = !_isDimmed;
    });
  }

  void clearDimming() {
    setState(() {
      _isDimmed = false;
      _excludedKeys.clear();
      _source = null;
    });
  }
}
