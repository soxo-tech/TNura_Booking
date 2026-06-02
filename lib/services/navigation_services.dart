// ignore_for_file: prefer_const_constructors

import 'package:booking/core/colors.dart';
import 'package:flutter/material.dart';
import 'dart:ui';


/// --- GLOBAL KEYS ---
/// These keys allow you to navigate or show SnackBars from ANYWHERE
/// (like ApiService) without needing a BuildContext.

// 1. Manages SnackBars and MaterialBanner
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

// 2. Manages Navigation (Make sure this is uncommented)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Pushes a new page onto the navigator stack.
void push(BuildContext context, Widget page) {
  Navigator.push(
    context,
    _createFadeRoute(page),
  );
}

/// Replaces the current page with a new one.
void pushAndReplace(BuildContext context, Widget page) {
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => page,
    ),
  );
}

/// Pops the top page off the navigator stack.
void pop(BuildContext context) {
  Navigator.pop(context);
}

/// Pushes a new page onto the navigator stack and removes all previous pages.
void pushAndRemoveUntil(BuildContext context, Widget page) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (_) => page,
    ),
    (_) => false,
  );
}


void showSnackBar(
  BuildContext? context,
  String message, {
  Color? color,
  Duration? duration,
  double margin = 10,
}) {
  OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: _GlassToastWidget(
          title: message,
          tintColor: color ?? Color(0xffDAF3FB),
          onDismiss: () {},
        ),
      ),
    ),
  );
  if (context != null && Navigator.canPop(context)) {
    final overlayState = Overlay.of(context);
    if (overlayState.mounted) {
      overlayState.insert(overlayEntry);
    }
  } else {
    navigatorKey.currentState?.overlay?.insert(overlayEntry);
  }

  // Auto-remove after 3 seconds
  Future.delayed(
      duration ?? const Duration(seconds: 2), () => overlayEntry.remove());
}

class _GlassToastWidget extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Color tintColor;
  final VoidCallback onDismiss;

  const _GlassToastWidget(
      {required this.title,
      required this.tintColor,
      required this.onDismiss}) : subtitle = null;

  @override
  State<_GlassToastWidget> createState() => _GlassToastWidgetState();
}

class _GlassToastWidgetState extends State<_GlassToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Slide from -1.5 (off screen top) to 0.0 (target position)
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _controller.forward();

    // Auto-dismiss logic
    Future.delayed(const Duration(seconds: 3), () async {
      if (mounted) {
        await _controller.reverse(); // Slide back up
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
        position: _offsetAnimation,
        child: Material(
          color: AppColors.white,
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.backgroundBlueLight, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.backgroundBlueLight.withValues(alpha: 0.1),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.sessionTextColor,
                          letterSpacing: -0.4,
                        ),
                      ),
                      if (widget.subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}

Route _createFadeRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, 0.08); // Slight lift effect
      const end = Offset.zero;
      const curve = Curves.easeInOutQuart;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);
      var fadeAnimation = animation.drive(CurveTween(curve: curve));

      return FadeTransition(
        opacity: fadeAnimation,
        child: SlideTransition(position: offsetAnimation, child: child),
      );
    },
    transitionDuration: const Duration(milliseconds: 800),
  );
}
