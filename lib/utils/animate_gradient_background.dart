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
  late Animation<double> _animation;
  final List<List<Color>> gradients = [
    [const Color(0xFF181A20), const Color(0xFF23242B), const Color(0xFF35363C)],
    [const Color(0xFF23242B), const Color(0xFF35363C), const Color(0xFF181A20)],
    [const Color(0xFF35363C), const Color(0xFF23242B), const Color(0xFF181A20)],
    [const Color(0xFF181A20), const Color(0xFF35363C), const Color(0xFF23242B)],
  ];
  int _currentGradient = 0;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..addListener(() {
            setState(() {});
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _currentGradient = (_currentGradient + 1) % gradients.length;
              _controller.forward(from: 0);
            }
          });
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nextGradient = gradients[(_currentGradient + 1) % gradients.length];
    final currentGradient = gradients[_currentGradient];
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: List.generate(currentGradient.length, (i) {
                return Color.lerp(
                    currentGradient[i], nextGradient[i], _animation.value)!;
              }),
            ),
          ),
        );
      },
    );
  }
}
