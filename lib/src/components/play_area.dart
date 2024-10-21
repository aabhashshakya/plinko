///Created by Aabhash Shakya on 9/11/24
import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../plinko.dart';

//In the game of Breakout, the ball bounces off the walls of the play area. To accommodate collisions,
//you need a PlayArea component first.
//Where Flutter has Widgets, Flame has Components. Where Flutter apps consist of creating trees of widgets,
// Flame games consist of maintaining trees of components.
class PlayArea extends RectangleComponent with HasGameReference<Plinko> {
  PlayArea()
      : super(
    paint: Paint()..color = Colors.transparent,
    children: [RectangleHitbox()],   // To start populating the game's hitboxes, modify the PlayArea component as shown below.
//Adding a RectangleHitbox component as a child of the RectangleComponent will construct a hit box for collision detection
// that matches the size of the parent component. There is a factory constructor for RectangleHitbox called relative for
// times when you want a hitbox that is smaller, or larger, than the parent component.


  );

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    size = Vector2(game.width, game.height);
  }
}
