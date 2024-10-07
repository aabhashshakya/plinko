
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

import '../../config.dart';
import '../plinko.dart';
import 'ball.dart';

class Obstacle extends CircleComponent
    with CollisionCallbacks, HasGameReference<Plinko> {
  Obstacle({required this.row, required this.column, required super.position, required this.color})
      : super(
    radius: obstacleRadius * 0.8,
    anchor: Anchor.center,
    paint: Paint()
      ..color = color
      ..style = PaintingStyle.fill,
    children: [CircleHitbox()],
  );

  final int row;
  final int column;
  final Color color;

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    FlameAudio.play('bounce.mp3');

    final colorEffect = ColorEffect(
       const Color(0xffB59410),
      EffectController(duration: 0.4,reverseDuration: 1),
       opacityFrom: 0,
      opacityTo: 1,
    );
    final effect = GlowEffect(
      25,
      EffectController(duration: 0.7,reverseDuration: 0),
      style: BlurStyle.solid
    );
   // add(colorEffect);
   add(effect);
  }
}