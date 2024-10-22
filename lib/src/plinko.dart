///Created by Aabhash Shakya on 9/11/24
import 'dart:async';
import 'dart:math' as math;
import 'dart:math';
import 'dart:ui';
import 'package:collection/collection.dart';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plinko/src/components/money_multiplier.dart';
import 'package:plinko/src/components/obstacle/obstacle_helper.dart';
import 'package:plinko/src/model/round_info.dart';
import 'package:plinko/src/utils/extensions.dart';
import 'package:to_csv/to_csv.dart';

import '../config.dart';
import 'components/components.dart';

enum PlayState { ready, playing, roundOver, gameOver } // Add this enumeration

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

  var roundInfo = RoundInfo.getDefault();
  var activeBalls = minBalls;

  late ObstacleHelper obstacleHelper;

  //obstacle position
  late Vector2 topLeftObstaclePosition;
  late Vector2 topRightObstaclePosition;
  late Vector2 endLeftObstaclePosition;
  late Vector2 endRightObstaclePosition;

  //last row obstacles count
  final int _lastRowObstaclesCount = obstacleRows +
      topRowObstaclesCount -
      1; // -1 as index starts from 0 and o < _maxRows

  final rand = math.Random();

  final ValueNotifier<double> score = ValueNotifier(0);
  final ValueNotifier<List<MoneyMultiplier>> gameResults = ValueNotifier([]);

  double get width => size.x;

  double get height => size.y;

  final ValueNotifier<PlayState> playState =
      ValueNotifier(PlayState.ready); // Add from here...

  PlayState getPlayState() {
    return playState.value;
  }

  List<List<String>> simulationResult =
      []; //for simulation, store results of simulation
  void setPlayState(PlayState state) {
    playState.value = state;
    switch (playState.value) {
      case PlayState.roundOver:
        {
          overlays.removeAll(PlayState.values.map((e) => e.name));
          overlays.add(playState.value.name);

          if (roundInfo.isSimulation) {
            //write simulation output in a CSV
            List<String> header = ["Ball ID", "result", "prize_column"];
            myCSV(header, simulationResult, fileName: "plinko_results")
                .then((_) {
              //write probability output in csv
              var moneyMultipliers = moneyMultiplier.mapIndexed((index,e) => "${e}x,$index").toList();
              Map<String, int> occurenceMap = { for (var e in moneyMultipliers) e : 0 };

              //add a total header
              occurenceMap["totalBalls"] = roundInfo.balls;

              for (var e in simulationResult) {
                var multiplier ="${e[1]},${e.last}";
                if (!occurenceMap.containsKey(multiplier)) {
                  occurenceMap[multiplier] = 1;
                } else {
                  occurenceMap[multiplier] = occurenceMap[multiplier]! + 1;
                }
              }
              List<String> header2 = occurenceMap.keys.toList();
              List<String> repetition =
              occurenceMap.values.map((e) => e.toString()).toList();
              List<String> odds =
              repetition.map((e) => "${(int.parse(e)/roundInfo.balls)*100}%").toList();
              myCSV(header2, [repetition,odds], fileName: "plinko_distribution");
            });
          }
        }
      case PlayState.playing || PlayState.ready:
        {
          overlays.removeAll(PlayState.values.map((e) => e.name));
        }
      case PlayState.gameOver:
        {
          overlays.removeAll(PlayState.values.map((e) => e.name));
          overlays.add(playState.value.name);
        }
    }
  }

  late final AudioPool bounceEffect;

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    obstacleHelper = ObstacleHelper();
    //By default, Flame follows Flutter’s canvas anchoring, which means that (0, 0) is anchored on the top left corner
    // of the canvas. So the game and all components use that same anchor by default. We can change this by changing
    // our component’s anchor attribute to Anchor.center, which will make our life way easier if you want to center the
    // component on the screen.
    camera.viewfinder.anchor = Anchor.topLeft;
    bounceEffect = await FlameAudio.createPool('bounce.mp3', maxPlayers: 3);

    setPlayState(PlayState.ready);

    //Adds the PlayArea to the world. The world represents the game world. It projects all of its children through the
    // CameraComponents view transformation.
    world.add(PlayArea());
    loadGame();
  }

  void loadGame() {
    score.value = 0; // Add this line

    world.removeAll(world.children.query<Ball>());
    world.removeAll(world.children.query<Obstacle>());
    world.removeAll(world.children.query<MoneyMultiplier>());

    world.addAll([
      // Add from here...
      for (var i = 0; i < obstacleRows; i++)
        for (var j = 0;
            j < (topRowObstaclesCount + i);
            j++) //start with 3 obstacles in the 1st row
          Obstacle(
            row: i,
            column: j,
            position: obstacleHelper.getObstaclePosition(i, j),
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
  }

  Future<void> playGame(RoundInfo info) async {
    if (playState.value == PlayState.playing) return;
    roundInfo = info;
    activeBalls = roundInfo.balls;
    world.removeAll(world.children.query<Ball>());
    score.value = 0;
    gameResults.value = [];
    setPlayState(PlayState.playing);
    //This change adds the Ball component to the world. To set the ball's position to the center of the display area,
    // the code first halves the size of the game, as Vector2 has operator overloads (* and /) to scale a Vector2 by a
    // scalar value.
    // To set the ball's velocity involves more complexity. The intent is to move the ball down the screen in a random
    // direction at a reasonable speed. The call to the normalized method creates a Vector2 object set to the same
    // direction as the original Vector2, but scaled down to a distance of 1. This keeps the speed of the ball consistent
    // no matter which direction the ball goes. The ball's velocity is then scaled up to be a 1/4 of the height of the game.
    // Getting these various values right involves some iteration, also known as playtesting in the industry.

    for (int i = 0; i < roundInfo.balls; i++) {
      await Future.delayed(const Duration(milliseconds: 250));
      var random = rand.nextDouble();
      world.add(Ball(
          index: i,
          radius: ballRadius,
          position: Vector2(width / 2, height / 4.85),
          //initial position of the ball, which s  center
          velocity:
              Vector2(random > 0.5 ? random * 130 : random * -320, height * 0.2)
                  .normalized()
                ..scale(height / 3.5))); //scale is the speed, how fast it moves
    }
  }

  Future<void> simulateGame(RoundInfo info) async {
    if (playState.value == PlayState.playing) return;
    simulationResult = []; //reset simulation results
    roundInfo = info..isSimulation = true;
    activeBalls = roundInfo.balls;
    world.removeAll(world.children.query<Ball>());
    score.value = 0;
    gameResults.value = [];
    setPlayState(PlayState.playing);
    //This change adds the Ball component to the world. To set the ball's position to the center of the display area,
    // the code first halves the size of the game, as Vector2 has operator overloads (* and /) to scale a Vector2 by a
    // scalar value.
    // To set the ball's velocity involves more complexity. The intent is to move the ball down the screen in a random
    // direction at a reasonable speed. The call to the normalized method creates a Vector2 object set to the same
    // direction as the original Vector2, but scaled down to a distance of 1. This keeps the speed of the ball consistent
    // no matter which direction the ball goes. The ball's velocity is then scaled up to be a 1/4 of the height of the game.
    // Getting these various values right involves some iteration, also known as playtesting in the industry.

    for (int i = 0; i < roundInfo.balls; i++) {
      await Future.delayed(const Duration(milliseconds: 400));
      var random = rand.nextDouble();
      world.add(Ball(
          index: i,
          radius: ballRadius,
          position: Vector2(width / 2, height / 4.85),
          //initial position of the ball, which s  center
          velocity:
              Vector2(random > 0.5 ? random * 130 : random * -320, height * 0.2)
                  .normalized()
                ..scale(height / 3.5))); //scale is the speed, how fast it moves
    }
  }

  @override
  Color backgroundColor() => Colors.transparent; //make game transparent

  Vector2 _calculateMoneyMultiplierPosition(int column) {
    var bottomPadding = 30;
    var bottomObstacle = obstacleHelper.getObstaclePosition(
        obstacleRows - 1, column); //-1 as index is 0 < maxRows

    return Vector2(bottomObstacle.x + 2, bottomObstacle.y + bottomPadding);
  }

  Vector2 _calculateMoneyMultiplierSize() {
    var height = 80.0;
    var width = obstacleDistance.toDouble() - 2;
    return Vector2(width, height);
  }
}
