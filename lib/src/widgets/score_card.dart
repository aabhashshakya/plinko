import 'package:flutter/material.dart';

class ScoreCard extends StatelessWidget {
  const ScoreCard({
    super.key,
    required this.score,
    required this.bet
  });

  final ValueNotifier<double> score;
  final int bet;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<double>(
      valueListenable: score,
      builder: (context, score, child) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 18),
          child: Text(
            'WINNINGS: \$${(score*bet).toInt()}'.toUpperCase(),
            style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.white),
          ),
        );
      },
    );
  }
}