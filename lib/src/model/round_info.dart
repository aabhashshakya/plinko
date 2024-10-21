///Created by Aabhash Shakya on 10/18/24
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:plinko/config.dart';

import '../components/components.dart';

class RoundInfo extends ChangeNotifier {
  RoundInfo._(this.bet,this.balls, this.totalBet,this.totalWinnings,this.results);

  int bet;
  int totalBet;
  int balls;
  int totalWinnings;
  List<MoneyMultiplier> results;

  static RoundInfo getDefault() {
    return RoundInfo._(minBet,minBet * minBalls,minBalls,0,[]);
  }

  void setBet(int value) {
    bet = value;
    totalBet = bet * balls;
    notifyListeners();
  }

  void setBalls(int value) {
    balls = value;
    totalBet = bet * balls;
    notifyListeners();
  }


  void updateTotalWinnings(num score){
    totalWinnings += (score * bet).toInt();
    notifyListeners();

  }
   void setResults(List<MoneyMultiplier> value){
    results = value;
    notifyListeners();

   }

   void reset(){
    totalWinnings = 0;
    results = [];
   }

}
