///Created by Aabhash Shakya on 10/21/24
import 'package:flutter/material.dart';

extension Precision on double {
  //set the precision for a double
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
}