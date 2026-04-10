import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../theme/colors.dart';

class ToastOverlay extends StatelessWidget {
  const ToastOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final n = provider.notification;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, anim) => SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -1.5),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutBack)),
            child: FadeTransition(opacity: anim, child: child),
          ),
          child: n == null
              ? const SizedBox.shrink(key: ValueKey('empty'))
              : _ToastBubble(key: ValueKey(n.message), notification: n),
        );
      },
    );
  }
}

class _ToastBubble extends StatelessWidget {
  final AppNotification notification;
  const _ToastBubble({super.key, required this.notification});

  Color get _color {
    switch (notification.type) {
      case 'points':
        return AppColors.yellow;
      case 'ai':
        return AppColors.blue;
      case 'error':
        return AppColors.red;
      default:
        return AppColors.emerald;
    }
  }

  IconData get _icon {
    switch (notification.type) {
      case 'points':
        return Icons.emoji_events_rounded;
      case 'ai':
        return Icons.auto_awesome_rounded;
      case 'error':
        return Icons.error_outline_rounded;
      default:
        return Icons.check_circle_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: _color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: _color.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: _color.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_icon, color: _color, size: 18),
              const SizedBox(width: 10),
              Text(
                notification.message,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
