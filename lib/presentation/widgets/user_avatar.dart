import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/utils/app_utils.dart';
import 'common/oval_clipper.dart';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool showBorder;
  final Color borderColor;
  final double borderWidth;
  final bool useTransparentEdges;
  final Widget? badge;
  final AlignmentGeometry badgeAlignment;
  final bool isLoading;

  const UserAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 40,
    this.onTap,
    this.backgroundColor,
    this.foregroundColor,
    this.showBorder = false,
    this.borderColor = Colors.white,
    this.borderWidth = 2,
    this.badge,
    this.badgeAlignment = Alignment.bottomRight,
    this.isLoading = false,
    this.useTransparentEdges = true,
  }) : assert(
          imageUrl != null || name != null,
          'Either imageUrl or name must be provided',
        );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultBackgroundColor = theme.colorScheme.primary;
    final defaultForegroundColor = theme.colorScheme.onPrimary;

    final double ovalHeight = size * 1.5;

    Widget avatar;
    if (isLoading) {
      avatar = Container(
        width: size * 0.75,
        height: ovalHeight,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    } else if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatar = CachedNetworkImage(
        imageUrl: imageUrl!,
        imageBuilder: (context, imageProvider) => Container(
          width: size * 0.75,
          height: ovalHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
            color: backgroundColor ?? defaultBackgroundColor,
          ),
        ),
        placeholder: (context, url) => Container(
          width: size * 0.75,
          height: ovalHeight,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => _buildInitialsAvatar(
          context,
          defaultBackgroundColor,
          defaultForegroundColor,
          ovalHeight,
        ),
      );
    } else {
      avatar = _buildInitialsAvatar(
        context,
        defaultBackgroundColor,
        defaultForegroundColor,
        ovalHeight,
      );
    }

    // Apply rounded corners
    avatar = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: size * 0.75,
        height: ovalHeight,
        child: avatar,
      ),
    );

    if (showBorder) {
      avatar = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: borderColor,
            width: borderWidth,
          ),
        ),
        child: avatar,
      );
    }

    if (badge != null) {
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned.fill(
            child: Align(
              alignment: badgeAlignment,
              child: badge!,
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      avatar = InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: avatar,
      );
    }

    return SizedBox(
      width: size * 0.75,
      height: size,
      child: avatar,
    );
  }

  Widget _buildInitialsAvatar(
    BuildContext context,
    Color defaultBackgroundColor,
    Color defaultForegroundColor,
    double height,
  ) {
    return Container(
      width: size * 0.75,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? defaultBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          name?.initials ?? '?',
          style: TextStyle(
            color: foregroundColor ?? defaultForegroundColor,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class UserAvatarBadge extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final double? size;
  final EdgeInsets padding;

  const UserAvatarBadge({
    super.key,
    required this.child,
    this.backgroundColor,
    this.borderColor = Colors.white,
    this.borderWidth = 2,
    this.size,
    this.padding = const EdgeInsets.all(2),
  });

  factory UserAvatarBadge.status({
    required bool isOnline,
    double size = 12,
    Color? backgroundColor,
    Color? borderColor,
    double borderWidth = 2,
  }) {
    return UserAvatarBadge(
      size: size,
      backgroundColor:
          backgroundColor ?? (isOnline ? Colors.green : Colors.grey),
      borderColor: borderColor,
      borderWidth: borderWidth,
      child: const SizedBox(),
    );
  }

  factory UserAvatarBadge.icon({
    required IconData icon,
    double size = 16,
    Color? backgroundColor,
    Color? iconColor,
    Color? borderColor,
    double borderWidth = 2,
  }) {
    return UserAvatarBadge(
      size: size,
      backgroundColor: backgroundColor ?? Colors.blue,
      borderColor: borderColor,
      borderWidth: borderWidth,
      child: Icon(
        icon,
        size: size * 0.6,
        color: iconColor ?? Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: size,
      height: size,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.primary,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor ?? theme.colorScheme.surface,
          width: borderWidth,
        ),
      ),
      child: Center(child: child),
    );
  }
}
