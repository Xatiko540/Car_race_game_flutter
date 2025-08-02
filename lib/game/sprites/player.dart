import 'dart:async';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:mario_game/game/car_race.dart';

enum PlayerState { left, right, center }

class Player extends SpriteGroupComponent<PlayerState>
    with HasGameRef<CarRace>, KeyboardHandler, CollisionCallbacks {
  Player({
    required this.character,
    this.moveLeftRightSpeed = 700,
  }) : super(size: Vector2(79, 109), anchor: Anchor.center, priority: 1);

  double moveLeftRightSpeed;
  Character character;

  int _hAxisInput = 0;
  final int movingLeftInput = -1;
  final int movingRightInput = 1;
  Vector2 _velocity = Vector2.zero();

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    await add(CircleHitbox());
    await _loadCharacterSprites();
    current = PlayerState.center;
  }

  @override
  void update(double dt) {
    if (game.gameManager.isIntro || game.gameManager.isGameOver) return;

    _velocity.x = _hAxisInput * moveLeftRightSpeed;

    final double marioHorizontalCenter = size.x / 2;

    if (position.x < marioHorizontalCenter) {
      position.x = game.size.x - marioHorizontalCenter;
    }
    if (position.x > game.size.x - marioHorizontalCenter) {
      position.x = marioHorizontalCenter;
    }

    position += _velocity * dt;

    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    game.onLose();
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    _hAxisInput = 0;

    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      moveLeft();
    }
    if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      moveRight();
    }

    return true;
  }

  void moveLeft() {
    _hAxisInput = movingLeftInput;
    current = PlayerState.left;
  }

  void moveRight() {
    _hAxisInput = movingRightInput;
    current = PlayerState.right;
  }

  void resetDirection() {
    _hAxisInput = 0;
  }

  void reset() {
    _velocity = Vector2.zero();
    current = PlayerState.center;
  }

  void resetPosition() {
    position = Vector2(
      (game.size.x - size.x) / 2,
      (game.size.y - size.y) / 2,
    );
  }

  Future<void> _loadCharacterSprites() async {
    final left = await game.loadSprite('game/${character.name}.png');
    final right = await game.loadSprite('game/${character.name}.png');
    final center = await game.loadSprite('game/${character.name}.png');

    sprites = <PlayerState, Sprite>{
      PlayerState.left: left,
      PlayerState.right: right,
      PlayerState.center: center,
    };
  }
}