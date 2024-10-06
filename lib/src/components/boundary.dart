import 'dart:async';
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../plinko.dart';

class TriangleBoundary extends PolygonComponent
    with CollisionCallbacks, HasGameReference<Plinko> {
  TriangleBoundary(super.vertices) : super(
    paint: Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill,
  );

  @override
  FutureOr<void> onLoad() {
    //It should be noted that if you want to use collision detection or containsPoint on the Polygon, the polygon needs
    // to be convex.
    //MEANING FOR THIS TRIANGLE, THEY SHOULD NOT BE A 90 DEGREE ANGLE OR TWO VERTICES BE IN A STRAIGHT LINE
    add(PolygonHitbox(vertices));
    return super.onLoad();
  }
}
