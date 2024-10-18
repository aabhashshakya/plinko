import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../../../config.dart';
import '../../plinko.dart';

class Obstacle extends CircleComponent
    with CollisionCallbacks, HasGameReference<Plinko> {
  Obstacle({
    required this.row,
    required this.column,
    required super.position,
  }) : super(
          radius: obstacleRadius * 0.8,
          anchor: Anchor.center,
          paint: Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill,
          children: [CircleHitbox()],
        );

  final int row;
  final int column;

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    game.bounceEffect.start();
    final colorEffect = ColorEffect(
      const Color(0xffB59410),
      EffectController(duration: 0.4, reverseDuration: 1),
      opacityFrom: 0,
      opacityTo: 1,
    );
    final effect = GlowEffect(
        50, EffectController(duration: 0.5, reverseDuration: 0),
        style: BlurStyle.solid);
    // add(colorEffect);
    add(effect);
  }
}
