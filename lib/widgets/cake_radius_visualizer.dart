import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CakeRadiusVisualizer extends StatefulWidget {
  final String selectedSize;
  final ValueChanged<String>? onSelectSize;
  final List<String> availableSizes;

  const CakeRadiusVisualizer({
    super.key,
    required this.selectedSize,
    this.onSelectSize,
    this.availableSizes = const [],
  });

  @override
  State<CakeRadiusVisualizer> createState() => _CakeRadiusVisualizerState();
}

class _CakeRadiusVisualizerState extends State<CakeRadiusVisualizer> {
  int? _hoveredDiameter;

  bool get _isSelected8Inch => widget.selectedSize.contains('8"');

  int get _activeDiameter =>
      _hoveredDiameter ?? (_isSelected8Inch ? 8 : 6);

  bool get _displayIs8Inch => _activeDiameter == 8;

  bool get _has6InchOption =>
      widget.availableSizes.isEmpty || widget.availableSizes.any((s) => s.contains('6"'));
  bool get _has8InchOption =>
      widget.availableSizes.isEmpty || widget.availableSizes.any((s) => s.contains('8"'));

  String get _servingGuide => _displayIs8Inch
      ? '10–14 party slices (~20 cm)'
      : '4–6 standard slices (~15 cm)';

  String get _sliceRecommendation => _displayIs8Inch
      ? 'Perfect for birthdays, gatherings & celebrations'
      : 'Ideal for intimate parties, gifts & small families';

  void _switchToDiameter(int targetDiameter) {
    if (widget.onSelectSize == null || widget.availableSizes.isEmpty) return;
    final targetStr = '$targetDiameter"';

    final match = widget.availableSizes.cast<String?>().firstWhere(
      (s) => s != null && s.contains(targetStr),
      orElse: () => null,
    );

    if (match != null) {
      widget.onSelectSize!(match);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgPastelPink,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.bgPastelPink, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(60, 34, 22, 0.04),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Full Width Top-Down Interactive Cake Visualizer Box
          _buildTopDownDiagram(),

          const SizedBox(height: 14),

          // Serving & Scale Comparison Summary Card (Updates on Hover)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _hoveredDiameter != null
                    ? AppColors.brandRed.withValues(alpha: 0.5)
                    : AppColors.brandRed,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.groups_outlined,
                      size: 18,
                      color: AppColors.brandRed,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.brandRed,
                          ),
                          children: [
                            TextSpan(
                              text: _hoveredDiameter != null
                                  ? 'Preview Servings ($_activeDiameter"): '
                                  : 'Estimated Servings ($_activeDiameter"): ',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: _servingGuide,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.brandRed,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb_outline_rounded,
                      size: 16,
                      color: AppColors.brandRed,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _sliceRecommendation,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.brandRed,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Full-width top down cake visualizer with generous gap above pills
  Widget _buildTopDownDiagram() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.bgPastelPink),
      ),
      child: Column(
        children: [
          // 1. Top-Down Cake Canvas (Non-hoverable static display)
          SizedBox(
            height: 155,
            width: double.infinity,
            child: CustomPaint(
              size: Size.infinite,
              painter: _CleanCakePainter(
                is8InchSelected: _displayIs8Inch,
                has6InchOption: _has6InchOption,
                has8InchOption: _has8InchOption,
              ),
            ),
          ),

          // 2. Clear visual gap between cake diagram and size pills
          const SizedBox(height: 18),

          // 3. Size Hover & Selection Pills
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_has6InchOption)
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) =>
                      setState(() => _hoveredDiameter = 6),
                  onExit: (_) =>
                      setState(() => _hoveredDiameter = null),
                  child: InkWell(
                    onTap: () {
                      _switchToDiameter(6);
                      setState(() => _hoveredDiameter = null);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: _buildSizeLegendPill(
                      label: '6" Cake (~15 cm)',
                      isActive: _activeDiameter == 6,
                      isSelected: !_isSelected8Inch,
                      color: AppColors.brandRed,
                    ),
                  ),  
                ),
              if (_has6InchOption && _has8InchOption)
                const SizedBox(width: 14),
              if (_has8InchOption)
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onEnter: (_) =>
                      setState(() => _hoveredDiameter = 8),
                  onExit: (_) =>
                      setState(() => _hoveredDiameter = null),
                  child: InkWell(
                    onTap: () {
                      _switchToDiameter(8);
                      setState(() => _hoveredDiameter = null);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: _buildSizeLegendPill(
                      label: '8" Cake (~20 cm)',
                      isActive: _activeDiameter == 8,
                      isSelected: _isSelected8Inch,
                      color: AppColors.brandRed,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSizeLegendPill({
    required String label,
    required bool isActive,
    required bool isSelected,
    required Color color,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: isActive
            ? color.withValues(alpha: 0.15)
            : (isSelected ? color.withValues(alpha: 0.08) : Colors.white),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? color : (isSelected ? color : AppColors.brandRed),
          width: isActive ? 1.8 : 1.0,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive
                  ? color
                  : (isSelected ? color : AppColors.brandRed),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isActive || isSelected
                  ? FontWeight.bold
                  : FontWeight.w600,
              color: isActive || isSelected ? color : AppColors.textDarkBerry,
            ),
          ),
        ],
      ),
    );
  }
}

/// Clean cake top-down canvas painter without math equations
class _CleanCakePainter extends CustomPainter {
  final bool is8InchSelected;
  final bool has6InchOption;
  final bool has8InchOption;

  _CleanCakePainter({
    required this.is8InchSelected,
    this.has6InchOption = true,
    this.has8InchOption = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final maxRadius = math.min(size.width / 2 - 16, size.height / 2 - 8);
    final r8 = maxRadius;
    final r6 = maxRadius * 0.75;

    // 1. Outer plate
    final platePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, r8 + 7, platePaint);

    final plateBorderPaint = Paint()
      ..color = AppColors.bgPastelPink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, r8 + 7, plateBorderPaint);

    // 2. Draw 8" Cake Layer
    if (has8InchOption) {
      final r8FillPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = is8InchSelected
            ? AppColors.brandRed
            : AppColors.bgPastelPink;
      canvas.drawCircle(center, r8, r8FillPaint);

      if (is8InchSelected) {
        // Highlighted 8" border
        final r8Stroke = Paint()
          ..color = AppColors.brandRed
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4;
        canvas.drawCircle(center, r8, r8Stroke);

        // Clean slice lines for 8" (8 slices)
        final slicePaint = Paint()
          ..color = AppColors.brandRed.withValues(alpha: 0.20)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;
        for (int i = 0; i < 8; i++) {
          final angle = i * (math.pi / 4);
          final p2 = Offset(
            center.dx + r8 * math.cos(angle),
            center.dy + r8 * math.sin(angle),
          );
          canvas.drawLine(center, p2, slicePaint);
        }
      } else {
        // Dashed unselected 8" border
        _drawDashedCircle(
          canvas,
          center,
          r8,
          Paint()
            ..color = AppColors.brandRed
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2,
        );
      }
    }

    // 3. Draw 6" Cake Layer
    if (has6InchOption) {
      final r6FillPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = !is8InchSelected
            ? AppColors.brandRed
            : (is8InchSelected
                ? AppColors.brandRed.withValues(alpha: 0.6)
                : AppColors.bgPastelPink);
      canvas.drawCircle(center, r6, r6FillPaint);

      if (!is8InchSelected) {
        // Highlighted 6" border
        final r6Stroke = Paint()
          ..color = AppColors.brandRed
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4;
        canvas.drawCircle(center, r6, r6Stroke);

        // Clean slice lines for 6" (6 slices)
        final slicePaint = Paint()
          ..color = AppColors.brandRed.withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2;
        for (int i = 0; i < 6; i++) {
          final angle = i * (math.pi / 3);
          final p2 = Offset(
            center.dx + r6 * math.cos(angle),
            center.dy + r6 * math.sin(angle),
          );
          canvas.drawLine(center, p2, slicePaint);
        }
      } else {
        // Dashed reference boundary for 6"
        _drawDashedCircle(
          canvas,
          center,
          r6,
          Paint()
            ..color = AppColors.brandRed.withValues(alpha: 0.35)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.2,
        );
      }
    }

    // 4. Center decorative cake rosette / topper
    final centerPaint = Paint()
      ..color = AppColors.brandRed
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 3.5, centerPaint);

    final centerWhiteDot = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 1.5, centerWhiteDot);
  }

  void _drawDashedCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
  ) {
    const double dashAngle = 0.08;
    const double spaceAngle = 0.06;
    double currentAngle = 0.0;

    while (currentAngle < 2 * math.pi) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle,
        dashAngle,
        false,
        paint,
      );
      currentAngle += dashAngle + spaceAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _CleanCakePainter oldDelegate) {
    return oldDelegate.is8InchSelected != is8InchSelected;
  }
}
