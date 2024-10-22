///Created by Aabhash Shakya on 9/11/24

//This game will be 820 pixels wide and 1600 pixels high. The game area scales to fit the window in which it is displayed,
//but all the components added to the screen conform to this height and width.
const gameWidth = 820.0;
const gameHeight = 1400.0;
const ballRadius = gameWidth * 0.020;



//obstacles
const obstacleRows = 14;
const obstacleDistance = 50;
const topRowObstaclesCount = 3;
const obstacleRadius = ballRadius * 0.525;
const obstacleGutter = gameWidth * 0.021;

//game config
const minBet = 10;
const minBalls =1;
const maxBalls = 1000;
const defaultCredit = 99999;

