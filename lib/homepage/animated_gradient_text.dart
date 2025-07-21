import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class FadeTypewriterText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final Duration charDelay;

  const FadeTypewriterText({
    super.key,
    required this.text,
    this.style,
    this.charDelay = const Duration(milliseconds: 100),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(text.length, (i) {
        return Text(text[i], style: style)
            .animate()
            .fadeIn(duration: Duration(milliseconds: 300), delay: charDelay * i);
      }),
    );
  }
}
