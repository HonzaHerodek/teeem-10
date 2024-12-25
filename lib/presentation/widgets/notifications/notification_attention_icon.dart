import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'models/notification_attention_state.dart';
import 'models/notification_attention_config.dart';

class NotificationAttentionIcon extends StatefulWidget {
  final int? notificationCount;
  final VoidCallback onTap;
  final bool isActive;
  final Duration? longestIgnoredDuration;
  final NotificationAttentionConfig config;
  final bool testMode;
  final bool showTestModeControls;
  final ValueChanged<bool>? onTestModeChanged;

  const NotificationAttentionIcon({
    super.key,
    this.notificationCount,
    required this.onTap,
    this.isActive = false,
    this.longestIgnoredDuration,
    this.config = const NotificationAttentionConfig(),
    this.testMode = false,
    this.showTestModeControls = false,
    this.onTestModeChanged,
  });

  @override
  State<NotificationAttentionIcon> createState() => _NotificationAttentionIconState();
}

class _NotificationAttentionIconState extends State<NotificationAttentionIcon> with SingleTickerProviderStateMixin {
  late AnimationController _blinkController;
  Timer? _testModeTimer;
  NotificationAttentionState _testModeState = NotificationAttentionState.normal;
  bool _isBlinkVisible = true;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    if (widget.testMode) {
      _startTestMode();
    }
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _testModeTimer?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(NotificationAttentionIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.testMode != oldWidget.testMode) {
      if (widget.testMode) {
        _startTestMode();
      } else {
        _testModeTimer?.cancel();
      }
    }
  }

  void _startTestMode() {
    _testModeTimer?.cancel();
    _testModeTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        _testModeState = NotificationAttentionState
            .values[(_testModeState.index + 1) % NotificationAttentionState.values.length];
      });
    });
  }

  void _handleBlinking() {
    if (_getCurrentState() == NotificationAttentionState.blinking) {
      Future.delayed(Duration(milliseconds: (2000 + (Random().nextDouble() * 2000)).toInt()), () {
        if (mounted) {
          setState(() => _isBlinkVisible = !_isBlinkVisible);
          _handleBlinking();
        }
      });
    } else {
      setState(() => _isBlinkVisible = true);
    }
  }

  NotificationAttentionState _getCurrentState() {
    if (widget.testMode) return _testModeState;
    if (widget.longestIgnoredDuration == null) return NotificationAttentionState.normal;
    return widget.config.getStateForDuration(widget.longestIgnoredDuration!);
  }

  @override
  Widget build(BuildContext context) {
    final currentState = _getCurrentState();
    
    if (currentState == NotificationAttentionState.blinking && _isBlinkVisible != true) {
      _handleBlinking();
    }

    if (!_isBlinkVisible) {
      return const SizedBox(width: 56, height: 56);
    }

    Widget iconWidget = Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isActive || currentState == NotificationAttentionState.withCircle
                ? Colors.pink
                : Colors.transparent,
          ),
          child: AnimatedScale(
            scale: currentState.iconScale,
            duration: const Duration(milliseconds: 300),
            child: IconButton(
              icon: Icon(
                currentState == NotificationAttentionState.normal
                    ? Icons.notifications_outlined
                    : Icons.notifications,
                color: Colors.white,
              ),
              onPressed: widget.onTap,
            ),
          ),
        ),
        if (widget.notificationCount != null && widget.notificationCount! > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.pink,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                widget.notificationCount! > 99 ? '99+' : widget.notificationCount!.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        if (currentState == NotificationAttentionState.withDot)
          Positioned(
            right: 12,
            top: 12,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.pink,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );

    if (!widget.showTestModeControls) {
      return iconWidget;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        iconWidget,
        const SizedBox(height: 4),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(12),
            ),
            child: GestureDetector(
              onTap: () {
                if (mounted) {
                  if (widget.testMode) {
                    _testModeTimer?.cancel();
                    setState(() {
                      _testModeState = NotificationAttentionState.normal;
                      _isBlinkVisible = true;
                    });
                    widget.onTestModeChanged?.call(false);
                  } else {
                    widget.onTestModeChanged?.call(true);
                  }
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.testMode)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.pause,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Stop Test',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Test States',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
