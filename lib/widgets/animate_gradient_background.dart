import 'package:flutter/material.dart';

class AnimatedGradientBackground extends StatefulWidget {
  const AnimatedGradientBackground({Key? key}) : super(key: key);

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _currentGradient = 0;

  static const List<List<Color>> _gradients = [
    [Color(0xFF181A20), Color(0xFF23242B), Color(0xFF35363C)],
    [Color(0xFF23242B), Color(0xFF35363C), Color(0xFF181A20)],
    [Color(0xFF35363C), Color(0xFF23242B), Color(0xFF181A20)],
    [Color(0xFF181A20), Color(0xFF35363C), Color(0xFF23242B)],
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _controller.addStatusListener(_handleAnimationStatus);
    _controller.forward();
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (!mounted) return;
    if (status == AnimationStatus.completed) {
      setState(() {
        _currentGradient = (_currentGradient + 1) % _gradients.length;
      });
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.removeStatusListener(_handleAnimationStatus);
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _AnimatedGradientContainer(
      controller: _controller,
      currentGradient: _currentGradient,
    );
  }
}

/// Separated widget that listens to the animation without parent setState
class _AnimatedGradientContainer extends AnimatedWidget {
  final int currentGradient;

  static const List<List<Color>> _gradients = [
    [Color(0xFF181A20), Color(0xFF23242B), Color(0xFF35363C)],
    [Color(0xFF23242B), Color(0xFF35363C), Color(0xFF181A20)],
    [Color(0xFF35363C), Color(0xFF23242B), Color(0xFF181A20)],
    [Color(0xFF181A20), Color(0xFF35363C), Color(0xFF23242B)],
  ];

  const _AnimatedGradientContainer({
    required AnimationController controller,
    required this.currentGradient,
  }) : super(listenable: controller);

  Animation<double> get _animation => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    final nextGradient = _gradients[(currentGradient + 1) % _gradients.length];
    final current = _gradients[currentGradient];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: List.generate(current.length, (i) {
            return Color.lerp(current[i], nextGradient[i], _animation.value)!;
          }),
        ),
      ),
    );
  }
}
