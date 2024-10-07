import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:plinko/src/components/ball.dart';
import 'package:plinko/src/plinko.dart';

class MoneyMultiplier extends RectangleComponent
    with CollisionCallbacks, HasGameReference<Plinko> {
  MoneyMultiplier({
    required this.column,
    required this.color,
    required this.cornerRadius,
    required super.position,
    required super.size,
  }) : super(
          anchor: Anchor.topLeft,
          //determines that the object is drawn from topleft of the position
          //center means the position is the midpoint
          children: [
            RectangleHitbox(),
          ],
          paint: Paint()
            ..color = color
            ..style = PaintingStyle.fill,
        );

  final int column;
  final Radius cornerRadius;
  final Color color;
  late num multiplier;

  @override
  FutureOr<void> onLoad() {
    multiplier = moneyMultiplier[column];
    add(TextComponent(text: 'x$multiplier', textRenderer: _regular)
      ..anchor = Anchor.topCenter
      ..x = size.x/2
      ..y = size.y*0.4);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    // TODO: implement onCollisionStart
    super.onCollisionStart(intersectionPoints, other);
    if (other is Ball) {
      if (intersectionPoints.first.x < (position.x + size.x) &&
          intersectionPoints.first.y < position.y + size.y) {
        _winCondition();

      }
    }
  }

  void _winCondition(){
    final glowEffect = GlowEffect(
        20, EffectController(duration: 0.5, reverseDuration: 1),
        style: BlurStyle.solid);
    // add(colorEffect);

    final scaleEffect = ScaleEffect.by(
      Vector2.all(1.1),
      EffectController(duration: 0.5, reverseDuration: 0.5),
    );

    add(scaleEffect);
    add(glowEffect);

    //win condition
    //The most important new concept this code introduces is how the player achieves the win condition. The win condition
    // check queries the world for bricks, and confirms that only one remains. This might be a bit confusing, because the
    // preceding line removes this brick from its parent.
    // The key point to understand is that component removal is a queued command. It removes the brick after this code runs,
    // but before the next tick of the game world.
    game.score.value = multiplier.toDouble();
    game.playState = PlayState.won;
  }
}

final _regularTextStyle = TextStyle(
  fontSize: 18,
  color: BasicPalette.white.color,
);
final _regular = TextPaint(
  style: _regularTextStyle,
);

final moneyMultiplier = [2.0,1.5,1.2,1.0,0.8,0.5,0.8,1.0,1.2,1.5,2.0];
