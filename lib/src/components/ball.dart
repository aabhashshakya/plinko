///Created by Aabhash Shakya on 9/11/24
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:plinko/src/components/boundary.dart';

import '../plinko.dart';
import 'components.dart';
import 'dart:math';

//Earlier, you defined the PlayArea using the RectangleComponent, so it stands to reason that more shapes exist.
// CircleComponent, like RectangleComponent, derives from PositionedComponent, so you can position the ball on the screen.
// More importantly, its position can be updated.
class Ball extends CircleComponent
    with CollisionCallbacks, HasGameReference<Plinko> {
  Ball({
    required this.velocity,
    required super.position,
    required double radius,
  }) : super(
      radius: radius,
      anchor: Anchor.center,
      paint: Paint()
        ..color = const Color(0xff1e6091)
        ..style = PaintingStyle.fill,
      children: [CircleHitbox()]); // Add this parameter

  final Vector2 velocity;
  final _velocityTmp = Vector2.zero();

//  This component introduces the concept of velocity, or change in position over time. Velocity is a Vector2 object as
//  velocity is both speed and direction. To update position, override the update method, which the game engine calls for
//  every frame. The dt is the duration between the previous frame and this frame. This enables you to adapt to factors
//  like different frame rates (60hz or 120hz) or long frames due to excessive computation.
  @override
  void update(double dt) {
    super.update(dt);
    velocity.y += 20 * dt;
    _velocityTmp
      ..setFrom(velocity)
      ..scale(dt*1.2); //scale is speed

    // Update position based on the current velocity.
    position.add(_velocityTmp);
  }

  @override // Add from here...
  void onCollisionStart(Set<Vector2> intersectionPoints,
      PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);

    print("intersectionPoint ball: x:${position.x} y: ${position.y}");
    print("intersectionPoint obstacle: x:${other.position.x} y: ${other.position.y}");
    print("intersectionPoint midpoint: x:${other.center.x} y: ${other.center.y}");

    intersectionPoints.forEach((e) {
      print("intersectionPoint: x: ${e.x} y:${e.y} ");
    });

    if (other is PlayArea) {
      if (intersectionPoints.first.y <= 0) {
        //top wall collide, just reverse the velocity direction
        velocity.y = -velocity.y;
      } else if (intersectionPoints.first.x <= 0) {
        //left wall collide, just reverse the velocity direction
        velocity.x = -velocity.x;
      } else if (intersectionPoints.first.x >= game.width) {
        //right wall collide, just reverse the velocity direction
        velocity.x = -velocity.x;
     } else
        if (intersectionPoints.first.y >= game.height) {
        //When the ball collides with the bottom wall, it just disappears from the playing
        // surface while still very much in view. You handle this artifact in a future step, using the power
        // of Flame's Effects.
        add(RemoveEffect(
          // Modify from here...
            delay: 0.35,
            onComplete: () {
              // Modify from here
              game.playState = PlayState.gameOver;
            }));
      }
    }else if(other is TriangleBoundary) {
      if (position.y < intersectionPoints.first.y) {
        //top boundary collide, just reverse the velocity direction
        velocity.y = -velocity.y;
      }  if (position.y > intersectionPoints.first.y) {
        //When the ball collides with the bottom boundary, it just disappears from the playing
        velocity.y = -velocity.y;
      }  if (position.x < other.position.x) {
        //right boundary collide, just reverse the velocity direction
        velocity.x = -velocity.x;
      }  if (position.x > other.position.x) {
        //left boundary collide, just reverse the velocity direction
        velocity.x = -velocity.x;
      }
    }  else if (other is Obstacle) {
      // Modify from here...
      if (position.y < other.position.y - other.size.y / 2) {
        print("collision start: y: ${position.y} < oy: ${other.position.y}");
        velocity.y = -40 * Random().nextDouble() * 5;
        print("start velocity: x:${velocity.x} y: ${velocity.y}");
      }  if (position.y > other.position.y + other.size.y / 2) {
        print("collision start: y: ${position.y} > oy:${other.position.y}");
        velocity.y = 400 * Random().nextDouble() * 5;
        print("start velocity: x:${velocity.x} y: ${velocity.y}");
      }  if (position.x < other.position.x) {
        print("collision start: x:${position.x} < ox:${other.position.x}");
        velocity.x = -45 * Random().nextDouble() * 6;
        print("start velocity: x:${velocity.x} y: ${velocity.y}");
      }  if (position.x > other.position.x) {
        print("collision start: x:${position.x} > ox:${other.position.x}");
        velocity.x = 45 * Random().nextDouble() * 6;
        print("start velocity: x:${velocity.x} y: ${velocity.y}");
      }
    } else if (other is MoneyMultiplier){
      //the ball hit the money multiplier and user won something
      add(RemoveEffect(
        // Modify from here...
          delay: 0,
          onComplete: () {
            // Modify from here
            game.score.value = other.multiplier.toDouble();
            game.playState = PlayState.won;
          }));
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    // TODO: implement onCollisionEnd
    super.onCollisionEnd(other);
    if (other is Obstacle) {
      if (position.y < other.position.y - other.size.y / 2) {
       print("collision end: y:${position.y} < oy:${other.position.y}");
        Future.delayed(const Duration(milliseconds: 40), () {
          velocity.y = 300;
        });
        //velocity.x = velocity.x /0.3;
        print("end velocity: x:${velocity.x} y: ${velocity.y}");
      }  if (position.y > other.position.y + other.size.y / 2) {
        print("collision end: y:${position.y} > oy:${other.position.y}");
        Future.delayed(const Duration(milliseconds: 40), () {
          velocity.y = 300;
        });        print("end velocity: x:${velocity.x} y: ${velocity.y}");
      }  if (position.x < other.position.x) {
        print("collision end: x:${position.x} < ox:${other.position.x}");
       // velocity.x = velocity.x;
        print("end velocity: x:${velocity.x} y: ${velocity.y}");
      }  if (position.x > other.position.x ) {
        print("collision end: x:${position.x} > ox:${other.position.x}");
      //  velocity.x = -velocity.x;
        print("end velocity: x:${velocity.x} y: ${velocity.y}");
      }
    }
  }
}

