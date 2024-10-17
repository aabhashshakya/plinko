///Created by Aabhash Shakya on 10/17/24
import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';

import '../../../config.dart';

class ObstacleHelper {
  Vector2? _lastObstaclePosition;
  Vector2? _firstObstaclePosition;

  final Map<List<int>, Vector2> _position = {};

  ObstacleHelper() {
    for (var i = 0; i < obstacleRows; i++) {
      for (var j = 0;
          j < (topRowObstaclesCount + i);
          j++) //start with 3 obstacles in the 1st row
      {
        _calculateObstaclePosition(i, j);
      }
    }
  }

  Vector2 _calculateObstaclePosition(int row, int column) {
    if (row == 0 && column == 0) {
      _reset();
    }

    var y = (row + 16) * (obstacleRadius * 2.7) + (row * obstacleGutter * 2);
    double x;
    if (column == 0) {
      if (row == 0) {
        x = (gameWidth / 2.0) - (obstacleDistance);
        _firstObstaclePosition = Vector2(x, y);
      } else {
        x = _firstObstaclePosition!.x - (row * obstacleDistance/2);
      }
    } else {
      x = (_lastObstaclePosition!.x) + obstacleDistance;
    }
    _lastObstaclePosition = Vector2(x, y);
    _position[[row, column]] = _lastObstaclePosition!;
    return _lastObstaclePosition!;
  }

  Vector2 getObstaclePosition(int row, int column) {
    print("we are getting: $row, $column");
    _position.forEach((k, v) {
      print("[$k,$v");
    });
    return _position.entries.firstWhere((mapElement) {
      return listEquals(mapElement.key, [row, column]);
    }).value;
  }

  void _reset() {
    _lastObstaclePosition = null;
  }
}
