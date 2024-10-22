///Created by Aabhash Shakya on 9/11/24
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../plinko.dart';
import 'components.dart';
import 'dart:math';

//Earlier, you defined the PlayArea using the RectangleComponent, so it stands to reason that more shapes exist.
// CircleComponent, like RectangleComponent, derives from PositionedComponent, so you can position the ball on the screen.
// More importantly, its position can be updated.
class Ball extends CircleComponent
    with CollisionCallbacks, HasGameReference<Plinko> {
  Ball({
    required this.index,
    required this.velocity,
    required super.position,
    required double radius,
  }) : super(
            radius: radius * 1.02,
            anchor: Anchor.center,
            paint: Paint()
              ..color = Colors.orange
              ..style = PaintingStyle.fill,
            children: [CircleHitbox()]);

  final int index;
  final Vector2 velocity;
  final _velocityTmp = Vector2.zero();

//  This component introduces the concept of velocity, or change in position over time. Velocity is a Vector2 object as
//  velocity is both speed and direction. To update position, override the update method, which the game engine calls for
//  every frame. The dt is the duration between the previous frame and this frame. This enables you to adapt to factors
//  like different frame rates (60hz or 120hz) or long frames due to excessive computation.

  /// This method is called periodically by the game engine to request that your
  /// component updates itself.
  ///
  /// The time [dt] in seconds (with microseconds precision provided by Flutter)
  /// since the last update cycle.
  /// This time can vary according to hardware capacity, so make sure to update
  /// your state considering this.
  /// All components in the tree are always updated by the same amount. The time
  /// each one takes to update adds up to the next update cycle.
  @override
  void update(double dt) {
    super.update(dt);
    velocity.y += 20 * dt;
    _velocityTmp
      ..setFrom(velocity)..clamp(Vector2(-200, -10), Vector2(200, 350))
      ..scale(dt * 1.3); //scale is speed

    // Update position based on the current velocity.
    position.add(_velocityTmp);
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    print("----------- COLLISION START-------------");

    if (other is PlayArea) {
      //game is over if ball goes out of play area
      game.activeBalls--;
      if (game.roundInfo.isSimulation) {
        //add result to CSV file
        var result = [
          index.toString(), //S.N
          "-1" //result
        ];
        game.simulationResult.add(result);
      }
      if (game.activeBalls <= 0) {
        //round over if it was the last ball
        game.setPlayState(PlayState.roundOver);
      }
      add(RemoveEffect(
          // Modify from here...
          delay: 0.35,
          onComplete: () {
            // Modify from here
          }));
    }

    else if (other is Obstacle) {
      // Modify from here...
      if (position.y < other.position.y - other.size.y / 2) {
        print("collision start: y: ${position.y} < oy: ${other.position.y}");
        velocity.y = -25 * Random().nextDouble() * 5;
        print("start velocity: x:${velocity.x} y: ${velocity.y}");
      }
      if (position.y > other.position.y + other.size.y / 2) {
        print("collision start: y: ${position.y} > oy:${other.position.y}");
        velocity.y = 200 * Random().nextDouble() * 5;
        print("start velocity: x:${velocity.x} y: ${velocity.y}");
      }
      if (position.x < other.position.x) {
        print("collision start: x:${position.x} < ox:${other.position.x}");
        velocity.x += velocity.x > 0 ? -velocity.x - 95 *(Random().nextDouble() * 6) : (velocity.x * -1) - 35 * (Random().nextDouble() * 6);
        print("start velocity: x:${velocity.x} y: ${velocity.y}");
      }
      if (position.x > other.position.x) {
        print("collision start: x:${position.x} > ox:${other.position.x}");
        velocity.x += velocity.x > 0 ? velocity.x + 95 * (Random().nextDouble() * 6) : (velocity.x * -1) + 35 * (Random().nextDouble() * 6);
        print("start velocity: x:${velocity.x} y: ${velocity.y}");
      }
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    // TODO: implement onCollisionEnd
    super.onCollisionEnd(other);
    if (other is Obstacle || other is Ball) {
      if (position.y < other.position.y - other.size.y / 2) {
        print("collision end: y:${position.y} < oy:${other.position.y}");
        Future.delayed(const Duration(milliseconds: 20), () {
          velocity.y += 180;
        });
        //velocity.x = velocity.x /0.3;
        print("end velocity: x:${velocity.x} y: ${velocity.y}");
      }
      if (position.y > other.position.y + other.size.y / 2) {
        print("collision end: y:${position.y} > oy:${other.position.y}");
        Future.delayed(const Duration(milliseconds:55), () {
          velocity.y = 280;
        });
        print("end velocity: x:${velocity.x} y: ${velocity.y}");
      }
      if (position.x < other.position.x) {
        print("collision end: x:${position.x} < ox:${other.position.x}");
        velocity.y += 120;
        // velocity.x = velocity.x;
        print("end velocity: x:${velocity.x} y: ${velocity.y}");
      }
      if (position.x > other.position.x) {
        print("collision end: x:${position.x} > ox:${other.position.x}");
        velocity.y += 120;
        //  velocity.x = -velocity.x;
        print("end velocity: x:${velocity.x} y: ${velocity.y}");
      }
    }
  }
}
