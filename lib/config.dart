///Created by Aabhash Shakya on 9/11/24
import 'package:flutter/material.dart';

//This game will be 820 pixels wide and 1600 pixels high. The game area scales to fit the window in which it is displayed,
//but all the components added to the screen conform to this height and width.
const gameWidth = 820.0;
const gameHeight = 1400.0;
const ballRadius = gameWidth * 0.020;

const moneyMultiplierColors = [                                           // Add this const
  Color(0xfff94144),
  Color(0xfff3722c),
  Color(0xfff8961e),
  Color(0xff43aa8b),
  Color(0xff90be6d),
  Color(0xfff9c74f),
  Color(0xff90be6d),
  Color(0xff43aa8b),
  Color(0xfff8961e),
  Color(0xfff3722c),
  Color(0xfff94144),
  Color(0xfff94144),
  Color(0xfff3722c),
  Color(0xfff8961e),
  Color(0xff43aa8b),
  Color(0xff90be6d),
  Color(0xfff9c74f),
  Color(0xff90be6d),
  Color(0xff43aa8b),
  Color(0xfff8961e),
  Color(0xfff3722c),
  Color(0xfff94144),

];

//obstacles
const obstacleRows = 14;
const obstacleDistance = 50;
const topRowObstaclesCount = 3;
const obstacleRadius = ballRadius * 0.525;

const obstacleGutter = gameWidth * 0.021;                          // Add from here...

