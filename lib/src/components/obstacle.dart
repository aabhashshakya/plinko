import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../../config.dart';
import '../plinko.dart';
import 'ball.dart';

class Obstacle extends CircleComponent
    with CollisionCallbacks, HasGameReference<Plinko> {
  Obstacle({required this.row, required this.column, required super.position, required Color color})
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

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    //win condition
    //The most important new concept this code introduces is how the player achieves the win condition. The win condition
    // check queries the world for bricks, and confirms that only one remains. This might be a bit confusing, because the
    // preceding line removes this brick from its parent.
    // The key point to understand is that component removal is a queued command. It removes the brick after this code runs,
    // but before the next tick of the game world.
    game.score.value++;                                         // Add this line

    if (game.world.children.query<Obstacle>().length == 1) {
      game.playState = PlayState.won;                          // Add this line

      game.world.removeAll(game.world.children.query<Ball>());
    }
  }
}