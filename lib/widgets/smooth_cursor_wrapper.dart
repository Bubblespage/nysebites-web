import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SmoothCursorWrapper extends StatefulWidget {
  final Widget child;

  const SmoothCursorWrapper({super.key, required this.child});

  @override
  State<SmoothCursorWrapper> createState() => _SmoothCursorWrapperState();
}

class _SmoothCursorWrapperState extends State<SmoothCursorWrapper> {
  Offset _pointerPosition = const Offset(-100, -100);
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    // Custom cursor usually only makes sense on Web/Desktop where a mouse is present.
    if (!kIsWeb && defaultTargetPlatform != TargetPlatform.macOS && defaultTargetPlatform != TargetPlatform.windows && defaultTargetPlatform != TargetPlatform.linux) {
      return widget.child;
    }

    return MouseRegion(
      onHover: (event) {
        setState(() {
          _pointerPosition = event.position;
          _isHovering = true;
        });
      },
      onExit: (event) {
        setState(() {
          _isHovering = false;
        });
      },
      // We set cursor to none to hide the system cursor and fully replace it with our smooth cursor
      cursor: SystemMouseCursors.none,
      child: Stack(
        children: [
          widget.child,
          
          // The trailing cursor ring
          AnimatedPositioned(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutExpo,
            left: _pointerPosition.dx - 16, // center the 32px ring
            top: _pointerPosition.dy - 16,
            child: IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 100),
                opacity: _isHovering ? 1.0 : 0.0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.brandRed.withOpacity(0.5),
                      width: 2,
                    ),
                    color: AppColors.accentGold.withOpacity(0.15),
                  ),
                ),
              ),
            ),
          ),
          
          // A smaller inner dot that follows more closely
          AnimatedPositioned(
            duration: const Duration(milliseconds: 50),
            curve: Curves.easeOutQuint,
            left: _pointerPosition.dx - 5, // center the 10px dot
            top: _pointerPosition.dy - 5,
            child: IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 100),
                opacity: _isHovering ? 1.0 : 0.0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.brandRed,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
