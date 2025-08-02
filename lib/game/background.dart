import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/cupertino.dart';
import 'package:mario_game/game/car_race.dart';

class BackGround extends ParallaxComponent<CarRace> {
  double backgroundSpeed = 2;

  @override
  FutureOr<void> onLoad() async {
    parallax = await game.loadParallax(
      [
        await  ParallaxImageData('game/road1.png'),
        await  ParallaxImageData('game/road1.png'),
      ],
      fill: LayerFill.width,
      repeat: ImageRepeat.repeat,
      baseVelocity: Vector2(0, -70 * backgroundSpeed),
      velocityMultiplierDelta: Vector2(0, 1.2 * backgroundSpeed),
    );
  }
}