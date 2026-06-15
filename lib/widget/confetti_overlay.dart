import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:pabelo/core/design_constraint.dart';

class ConfettiOverlay extends StatelessWidget {
  final ConfettiController controller;

  const ConfettiOverlay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: controller,
        blastDirectionality: BlastDirectionality.explosive,
        emissionFrequency: 0.05,
        numberOfParticles: 20,
        gravity: 0.3,
        colors: const [
          AppColors.primaryPurple,
          AppColors.darkPurple,
          Colors.yellow,
          Colors.green,
          Colors.pink,
        ],
      ),
    );
  }
}