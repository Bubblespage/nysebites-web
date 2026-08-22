import 'package:flutter/material.dart';

class MarqueeAnnouncement extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final double velocity; // Pixels per second

  const MarqueeAnnouncement({
    super.key,
    required this.text,
    this.style,
    this.velocity = 35.0,
  });

  @override
  State<MarqueeAnnouncement> createState() => _MarqueeAnnouncementState();
}

class _MarqueeAnnouncementState extends State<MarqueeAnnouncement> {
  late final ScrollController _scrollController;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startLooping());
  }

  Future<void> _startLooping() async {
    if (_isDisposed || !mounted || !_scrollController.hasClients) return;

    await Future.delayed(const Duration(milliseconds: 600));

    while (mounted && !_isDisposed) {
      if (!_scrollController.hasClients) break;

      final double maxScroll = _scrollController.position.maxScrollExtent;
      if (maxScroll <= 0) {
        await Future.delayed(const Duration(seconds: 1));
        continue;
      }

      final double currentPos = _scrollController.position.pixels;
      final double distanceRemaining = maxScroll - currentPos;
      final int durationMs = ((distanceRemaining / widget.velocity) * 1000)
          .clamp(1500, 60000)
          .toInt();

      try {
        await _scrollController.animateTo(
          maxScroll,
          duration: Duration(milliseconds: durationMs),
          curve: Curves.linear,
        );

        if (_isDisposed || !mounted || !_scrollController.hasClients) break;

        _scrollController.jumpTo(0.0);
        await Future.delayed(const Duration(milliseconds: 200));
      } catch (_) {
        break;
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 6x duplicate ensures coverage on both mobile and wide screens
    final repeatedText =
        '${widget.text}      ✦      ${widget.text}      ✦      ${widget.text}      ✦      ${widget.text}      ✦      ${widget.text}      ✦      ${widget.text}';

    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      physics: const NeverScrollableScrollPhysics(),
      child: Text(
        repeatedText,
        style:
            widget.style ??
            const TextStyle(
              color: Color(0xFFF5EBE1),
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
      ),
    );
  }
}
