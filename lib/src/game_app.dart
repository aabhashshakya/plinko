import 'dart:ui';

import 'package:animated_text_lerp/animated_text_lerp.dart';
import 'package:flame/game.dart' hide Route;
import 'package:flame_audio/flame_audio.dart';
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

const _initialBet = 10;

class GameApp extends StatefulWidget {
  const GameApp({super.key});

  static const String routeName = 'GameScreen';

  static Route getRoute(RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => const GameApp());
  }

  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  late final Plinko plinko;
  var credit = 1000;
  var bet = _initialBet;
  var currentBet = 0;

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
              image: DecorationImage(
                  image: AssetImage("assets/images/bg.jpeg"),
                  fit: BoxFit.cover)),
          child: SafeArea(
            child: Center(
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.only(topLeft: Radius.circular(1.0)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 10.0),
                  child: Container(
                    color: Colors.white.withOpacity(0.05),
                    child: Column(
                      children: [
                        ScoreCard(score: plinko.score,bet:currentBet),
                        Expanded(
                          child: FittedBox(
                            child: SizedBox(
                              width: gameWidth,
                              height: gameHeight,
                              child: GameWidget(
                                game: plinko,
                                overlayBuilderMap: {
                                  PlayState.lost.name: (context, game) {
                                    FlameAudio.play('lose.mp3');
                                    return OverlayScreen(
                                      color: Colors.redAccent,
                                      title:
                                          'Y O U   L O S E ! ! ! ${plinko.score.value > 0 ? "X${plinko.score.value}" : ""}',
                                      subtitle: '',
                                    );
                                  },
                                  PlayState.won.name: (context, game) {
                                    FlameAudio.play('win.mp3');
                                    return OverlayScreen(
                                      color: Colors.amber,
                                      title:
                                          'Y O U   W O N ! ! !  X${plinko.score.value}',
                                      subtitle: '',
                                    );
                                  },
                                  PlayState.gameOver.name: (context, game) {
                                    FlameAudio.play('lose.mp3');
                                    return const OverlayScreen(
                                      color: Colors.redAccent,
                                      title:
                                      'N O   C R E D I T S',
                                      subtitle: 'Please earn more credits!',
                                    );
                                  },
                                },
                              ),
                            ),
                          ),
                        ),
                        Column(children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ValueListenableBuilder<PlayState>(
                                valueListenable: plinko.playState,
                                builder: (context, state, child) {
                                  if (state == PlayState.lost || state == PlayState.won) {
                                    credit = (credit + (currentBet * plinko.score.value)).toInt();
                                    currentBet = 0;

                                  }
                                  return _roundedTextField("Credit", credit);
                                },
                              ),
                                     _roundedTextFieldWithButtons(
                                      "Bet", "\$$bet", () {
                                    //on increase bet
                                    if (bet >= credit ||
                                        bet + 10 > credit) {
                                      return;
                                    }
                                    plinko.setPlayState(PlayState.inactive);
                                    setState(() {
                                      bet = bet + 10;
                                    });
                                  }, () {
                                    //on decrease bet
                                    if (bet == 0 || bet - 10 == 0) {
                                      return;
                                    }
                                    plinko.setPlayState(PlayState.inactive);
                                    setState(() {
                                      bet = bet - 10;
                                    });
                                  }

                              ),

                            ],
                          ),
                          const SizedBox(height: 30),
                          MaterialButton(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            minWidth: 0,
                            padding: const EdgeInsets.all(0.0),
                            textColor: Colors.white,
                            elevation: 16.0,
                            child: Container(
                              margin: EdgeInsets.zero,
                              padding: EdgeInsets.zero,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                image: const DecorationImage(
                                    image: AssetImage('assets/images/bg.jpeg'),
                                    fit: BoxFit.cover),
                              ),
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20.0, vertical: 8.0),
                                  child: ValueListenableBuilder<PlayState>(
                                    valueListenable: plinko.playState,
                                    builder: (context, state, child) {
                                      return Text(
                                        state == PlayState.playing
                                            ? "PLAYING"
                                            : "PLAY",
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge!
                                            .copyWith(color: Colors.white),
                                      );
                                    },
                                  )),
                            ),
                            // ),
                            onPressed: () {
                              setState(() {
                                currentBet = bet;
                              });
                              if(currentBet <= credit) {
                                credit = credit - currentBet;
                                plinko.playGame();
                              }else{
                                plinko.setPlayState(PlayState.gameOver);
                              }
                            },
                          ),
                        ]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _roundedTextField(String title, int value) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(color: Colors.white)),
      Container(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: const DecorationImage(
              image: AssetImage('assets/images/bg.jpeg'), fit: BoxFit.cover),
        ),
        child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            child: AnimatedNumberText(
              value, // int or double
              curve: Curves.easeIn,
              duration: const Duration(milliseconds: 500),
              style: const TextStyle(color: Colors.white),
              formatter: (value) {
                return "\$$value";
              },
            )),
      ),
    ],
  );
}

Widget _roundedTextFieldWithButtons(
    String title, String value, Function onIncrement, Function onDecrement) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title, style: const TextStyle(color: Colors.white)),
      Container(
        constraints:
            const BoxConstraints(minWidth: 50, maxWidth: 230, maxHeight: 40),
        margin: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: const DecorationImage(
              image: AssetImage('assets/images/bg.jpeg'), fit: BoxFit.cover),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                  child: Text(
                value,
                style: const TextStyle(color: Colors.white),
              )),
              ElevatedButton(
                onPressed: () {
                  onDecrement();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 0),
                  padding: EdgeInsets.zero,
                  shape: const CircleBorder(),
                  backgroundColor: Colors.pink,
                  // <-- Button color
                  foregroundColor: Colors.red, // <-- Splash color
                ),
                child: const Icon(Icons.remove, color: Colors.white),
              ),
              ElevatedButton(
                onPressed: () {
                  onIncrement();
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 0),
                  padding: EdgeInsets.zero,
                  shape: const CircleBorder(),
                  backgroundColor: Colors.pink,
                  // <-- Button color
                  foregroundColor: Colors.red, // <-- Splash color
                ),
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
