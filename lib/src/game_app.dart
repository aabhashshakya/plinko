import 'dart:ffi';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plinko/src/widgets/score_card.dart';

import '../config.dart';
import 'plinko.dart';
import 'widgets/overlay_screen.dart';

//Most content in this file follows a standard Flutter widget tree build. The parts specific to Flame include using
// GameWidget.controlled to construct and manage the BrickBreaker game instance and the new overlayBuilderMap argument
// to the GameWidget.
//
// This overlayBuilderMap's keys must align with the overlays that the playState setter in BrickBreaker added or removed.
// Attempting to set an overlay that is not in this map leads to unhappy faces all around.
class GameApp extends StatefulWidget {
  const GameApp({super.key});

  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  late final Plinko plinko;
  @override
  void initState() {
    super.initState();
    plinko = Plinko();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.pressStart2pTextTheme().apply(
          bodyColor: const Color(0xff184e77),
          displayColor: const Color(0xff184e77),
        ),
      ),
      home: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xffa9d6e5),
                Color(0xfff2e8cf),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  children: [
                    ScoreCard(score: plinko.score),
                    Expanded(
                      child: FittedBox(
                        child: SizedBox(
                          width: gameWidth,
                          height: gameHeight,
                          child: GameWidget(
                            game: plinko,
                            overlayBuilderMap: {
                              PlayState.welcome.name: (context, game) =>
                              const OverlayScreen(
                                title: 'TAP TO PLAY',
                                subtitle: 'Use arrow keys or swipe',
                              ),
                              PlayState.gameOver.name: (context, game) =>
                              const OverlayScreen(
                                title: 'G A M E   O V E R',
                                subtitle: 'Tap to Play Again',
                              ),
                              PlayState.won.name: (context, game) =>
                               OverlayScreen(
                                title: 'Y O U   W O N ! ! !  X${plinko.score.value}',
                                subtitle: 'Tap to Play Again',
                              ),
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}