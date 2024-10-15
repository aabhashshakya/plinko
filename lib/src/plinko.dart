///Created by Aabhash Shakya on 9/11/24
import 'dart:async';
import 'dart:ffi';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plinko/src/components/boundary.dart';
import 'package:plinko/src/components/money_multiplier.dart';

import '../config.dart';
import 'components/components.dart';

enum PlayState { inactive, playing, lost, won, gameOver  } // Add this enumeration

class Plinko extends FlameGame
    with HasCollisionDetection, KeyboardEvents, TapDetector {
  //This tracks the hitboxes of components and triggers collision callbacks on every game tick. and keyboard events
  Plinko()
      : super(
          camera: CameraComponent.withFixedResolution(
            width: gameWidth,
            height: gameHeight,
          ),
        );

  //obstacle position
  late Vector2 topLeftObstaclePosition;
  late Vector2 topRightObstaclePosition;
  late Vector2 endLeftObstaclePosition;
  late Vector2 endRightObstaclePosition;

  //last row obstacles count
  final int _lastRowObstaclesCount =
      _maxRows + 3 - 1; // -1 as index starts from 0 and o < _maxRows

  final rand = math.Random();

  final ValueNotifier<double> score = ValueNotifier(0); // Add this line

  double get width => size.x;

  double get height => size.y;

  final ValueNotifier<PlayState> playState =
      ValueNotifier(PlayState.inactive); // Add from here...

  void setPlayState(PlayState state) {
    playState.value = state;
    switch (playState.value) {
      case PlayState.lost || PlayState.won:
        {
          overlays.add(playState.value.name);
        }
      case PlayState.playing || PlayState.inactive:
        {
          overlays.remove(PlayState.lost.name);
          overlays.remove(PlayState.won.name);
        }
      case PlayState.gameOver:{
        overlays.remove(PlayState.lost.name);
        overlays.remove(PlayState.won.name);
        overlays.add(playState.value.name);
      }

    }
  }

  late final AudioPool bounceEffect;

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    //By default, Flame follows Flutter’s canvas anchoring, which means that (0, 0) is anchored on the top left corner
    // of the canvas. So the game and all components use that same anchor by default. We can change this by changing
    // our component’s anchor attribute to Anchor.center, which will make our life way easier if you want to center the
    // component on the screen.
    camera.viewfinder.anchor = Anchor.topLeft;
    bounceEffect = await FlameAudio.createPool('bounce.mp3', maxPlayers: 2);

    setPlayState(PlayState.inactive);

    //Adds the PlayArea to the world. The world represents the game world. It projects all of its children through the
    // CameraComponents view transformation.
    world.add(PlayArea());
    loadGame();
  }

  void loadGame() {
    score.value = 0; // Add this line

    world.removeAll(world.children.query<Ball>());
    world.removeAll(world.children.query<Obstacle>());
    world.removeAll(world.children.query<TriangleBoundary>());
    world.removeAll(world.children.query<MoneyMultiplier>());
    world.removeAll(world.children.query<TextComponent>());

    world.addAll([
      // Add from here...
      for (var i = 0; i < _maxRows; i++)
        for (var j = 0;
            j < (3 + i);
            j++) //start with 3 obstacles in the 1st row
          Obstacle(
            row: i,
            column: j,
            position: _calculateObstaclePosition(i, j),
            color: moneyMultiplierColors[i],
          )
    ]);

    //money multipler at the bottom that catches the ball
    world.addAll([
      //eg: if 12 obstacles in last row, we need 11 money multipliers to fill all the gaps
      for (var i = 0; i < _lastRowObstaclesCount - 1; i++)
        MoneyMultiplier(
            column: i,
            cornerRadius: const Radius.circular(12),
            position: _calculateMoneyMultiplierPosition(i),
            color: moneyMultiplierColors[i],
            size: _calculateMoneyMultiplierSize())
    ]);

    world.add(TriangleBoundary([
      _calculateTrianglePosition(
          _TriangleLocation.left, _TriangleVertex.topRight),
      _calculateTrianglePosition(
          _TriangleLocation.left, _TriangleVertex.topLeft),
      _calculateTrianglePosition(
          _TriangleLocation.left, _TriangleVertex.bottom),
    ]));

    world.add(TriangleBoundary([
      _calculateTrianglePosition(
          _TriangleLocation.right, _TriangleVertex.topRight),
      _calculateTrianglePosition(
          _TriangleLocation.right, _TriangleVertex.topLeft),
      _calculateTrianglePosition(
          _TriangleLocation.right, _TriangleVertex.bottom),
    ]));

    world.add(TextComponent(text: 'x0.0', textRenderer: _regular)
      ..anchor = Anchor.topCenter
      ..x = width * 0.97
      ..y = _calculateObstaclePosition(_maxRows - 1, _lastRowObstaclesCount - 1)
              .y *
          0.88);
    world.add(TextComponent(text: 'x0.0', textRenderer: _regular)
      ..anchor = Anchor.topCenter
      ..x = 20
      ..y = _calculateObstaclePosition(_maxRows - 1, 0).y * 0.88);
  }

  void playGame() {
    if (playState.value == PlayState.playing) return;
    score.value = 0; // Add this line
    setPlayState(PlayState.playing);
    //This change adds the Ball component to the world. To set the ball's position to the center of the display area,
    // the code first halves the size of the game, as Vector2 has operator overloads (* and /) to scale a Vector2 by a
    // scalar value.
    // To set the ball's velocity involves more complexity. The intent is to move the ball down the screen in a random
    // direction at a reasonable speed. The call to the normalized method creates a Vector2 object set to the same
    // direction as the original Vector2, but scaled down to a distance of 1. This keeps the speed of the ball consistent
    // no matter which direction the ball goes. The ball's velocity is then scaled up to be a 1/4 of the height of the game.
    // Getting these various values right involves some iteration, also known as playtesting in the industry.
    var random = rand.nextDouble();
    world.add(Ball(
        radius: ballRadius,
        position: Vector2(width / 2, height / 4.5),
        //initial position of the ball, which s  center
        velocity:
            Vector2(random > 0.5 ? random * 150 : random * -320, height * 0.2)
                .normalized()
              ..scale(height / 4))); //scale is the speed, how fast it moves
  }

  @override
  Color backgroundColor() => Colors.transparent; //make game transparent

  Vector2 _calculateObstaclePosition(int row, int column) {
    return Vector2(
      gameWidth / 2.5 -
          (row * 34) +
          (obstacleRadius) +
          (column * obstacleGutter * 4),
      //change this constant when you change obstacle Gutter size
      (row + 22.3) * (obstacleRadius * 2.7) + (row * obstacleGutter * 2),
    );
  }

  Vector2 _calculateMoneyMultiplierPosition(int column) {
    var bottomPadding = 50;
    var bottomObstacle = _calculateObstaclePosition(
        _maxRows - 1, column); //-1 as index is 0 < maxRows

    return Vector2(
        bottomObstacle.x - 10 + 3 * column, bottomObstacle.y + bottomPadding);
  }

  Vector2 _calculateMoneyMultiplierSize() {
    var height = 100.0;
    var width = 65.0;
    return Vector2(width, height);
  }

  Vector2 _calculateTrianglePosition(
      _TriangleLocation location, _TriangleVertex vertex) {
    var topPadding = obstacleRadius * 2 + 100;
    var bottomPadding = obstacleRadius * 2 + 100;
    switch (location) {
      case _TriangleLocation.left:
        {
          switch (vertex) {
            case _TriangleVertex.topLeft:
              {
                var topLeftObstacle = _calculateObstaclePosition(0, 0);
                //-100 to make triangle convex, read more inside boundary.dart file
                return Vector2(0, topLeftObstacle.y - topPadding - 100);
              }
            case _TriangleVertex.topRight:
              {
                var topLeftObstacle = _calculateObstaclePosition(0, 0);
                return Vector2(
                    topLeftObstacle.x, topLeftObstacle.y - topPadding);
              }
            case _TriangleVertex.bottom:
              {
                var bottomLeftObstacle = _calculateObstaclePosition(
                    _maxRows - 1, 0); //-1 as index is 0 < maxRows
                return Vector2(0, bottomLeftObstacle.y);
              }
          }
        }
      case _TriangleLocation.right:
        {
          switch (vertex) {
            case _TriangleVertex.topLeft:
              {
                var topRightObstacle = _calculateObstaclePosition(0, 2);
                return Vector2(
                    topRightObstacle.x, topRightObstacle.y - topPadding);
              }
            case _TriangleVertex.topRight:
              {
                var topRightObstacle = _calculateObstaclePosition(0, 2);
                //-100 to make triangle convex, read more inside boundary.dart file
                return Vector2(
                    gameWidth, topRightObstacle.y - topPadding - 100);
              }
            case _TriangleVertex.bottom:
              {
                var bottomRightObstacle = _calculateObstaclePosition(
                    _maxRows - 1,
                    _lastRowObstaclesCount); //-1 as index is 0 < maxRows
                return Vector2(width, bottomRightObstacle.y);
              }
          }
        }
    }
  }
// To here
}

const _maxRows = 10;

//for positioning the triangle obstacle to prevent the ball out of screen
enum _TriangleVertex { topLeft, topRight, bottom }

enum _TriangleLocation { left, right }

final _regularTextStyle = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.bold,
  color: BasicPalette.red.color.withOpacity(0.8),
);
final _regular = TextPaint(
  style: _regularTextStyle,
);
