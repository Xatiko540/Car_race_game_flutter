import 'dart:async';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:mario_game/game/background.dart';
import 'package:mario_game/game/managers/game_manager.dart';
import 'package:mario_game/game/managers/object_manager.dart';
import 'package:mario_game/game/sprites/competitor.dart';
import 'package:mario_game/game/sprites/player.dart';

enum Character {
  bmw,
  farari,
  lambo,
  tarzen,
  tata,
  tesla,
}

class CarRace extends FlameGame
    with HasKeyboardHandlerComponents, HasCollisionDetection {
  CarRace({super.children});

  final BackGround _backGround = BackGround();
  final GameManager gameManager = GameManager();
  ObjectManager objectManager = ObjectManager();
  int screenBufferSpace = 300;

  EnemyPlatform platFrom = EnemyPlatform();

  late Player player;
  late AudioPool pool;

  double get minCameraY => -_backGround.size.y;

  double get maxCameraY => _backGround.size.y + screenBufferSpace;

  late CameraComponent mainCamera;

  @override
  FutureOr<void> onLoad() async {
    mainCamera = CameraComponent(world: world);
    add(mainCamera);

    await add(_backGround);
    await add(gameManager);
    overlays.add('gameOverlay');

    pool = await FlameAudio.createPool(
      'audi_sound.mp3',
      minPlayers: 3,
      maxPlayers: 4,
    );
  }

  Future<void> startBgmMusic() async {
    await  FlameAudio.bgm.initialize();
    await  FlameAudio.bgm.play('audi_sound.mp3', volume: 1);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (gameManager.isGameOver) return;
    if (gameManager.isIntro) {
      overlays.add('mainMenuOverlay');
      return;
    }

    if (gameManager.isPlaying) {
      final playerY = player.position.y;
      final cameraY = playerY.clamp(minCameraY, maxCameraY);
      mainCamera.viewfinder.position = Vector2(size.x / 2, cameraY);
    }
  }


  @override
  Color backgroundColor() {
    return const Color.fromARGB(255, 241, 247, 249);
  }

  void setCharacter() {
    player = Player(
      character: gameManager.character,
      moveLeftRightSpeed: 600,
    );
    add(player);
  }


  void initializeGameStart() async {
    setCharacter();

    gameManager.reset();

    if (children.contains(objectManager)) objectManager.removeFromParent();

    await player.onLoad();  // <== ДОБАВЬ ЭТО!

    player.reset();  // теперь reset безопасно

    mainCamera.follow(player);

    player.resetPosition();

    objectManager = ObjectManager();
    add(objectManager);

    startBgmMusic();
  }

  void onLose() {
    gameManager.state = GameState.gameOver;
    player.removeFromParent();
    FlameAudio.bgm.stop();
    overlays.add('gameOverOverlay');
  }

  void togglePauseState() {
    if (paused) {
      resumeEngine();
    } else {
      pauseEngine();
    }
  }

  void resetGame() {
    startGame();
    overlays.remove('gameOverOverlay');
  }

  void startGame() {
    initializeGameStart();
    gameManager.state = GameState.playing;
    overlays.remove('mainMenuOverlay');
  }
}