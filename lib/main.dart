import 'dart:convert';
import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame_audio/flame_audio.dart';

void main() {
  var plantGame = PlantGame();
  runApp(
    MaterialApp(
      home: Scaffold(
        body: GestureDetector(
          onTapUp: (details) => plantGame.playerTap(details),
          child: GameWidget(game: plantGame),
        ),
      ),
    ),
  );
}


class PlantGame extends Game {
  late List<double> robotActionTimes = [];
  late List<double> playerActionTimes = [];
  late List<double> robotInactionTimes = [];
  late List<double> playerInactionTimes = [];
  double currentTime = 0;
  int nextRobotActionIndex = 0;
  int nextPlayerActionIndex = 0;

  late Size screenSize;

  final plantText = TextComponent(
    text: 'Water the Plant!',
  );
  TextPaint textPaint = TextPaint(
    style: const TextStyle(
        fontSize: 48.0,
        fontFamily: 'Awesome Font',
        color: Colors.purple
    ),
  );


  late Rect wateringCan;
  late Rect platform;
  late Rect water;
  late Rect plant;

  Paint canPaint = Paint()..color = Colors.red;
  Paint platformPaint = Paint()..color = Colors.yellow;
  Paint waterPaint = Paint()..color = Colors.blue;
  Paint plantPaint = Paint()..color = Colors.green;

  bool win = true;
  int timesPressed = 0;

  PlantGame() {
    wateringCan = Rect.zero;
    platform = Rect.zero;
    water = Rect.zero;
    plant = Rect.zero;
  }

  @override
  Future<void>? onLoad() async {
    final jsonData = loadJson();
    robotActionTimes = List<double>.from(jsonData['song']['robot']['action']);
    playerActionTimes = List<double>.from(jsonData['song']['player']['action']);
    robotInactionTimes = List<double>.from(jsonData['song']['robot']['inaction']);
    playerInactionTimes = List<double>.from(jsonData['song']['player']['inaction']);
    FlameAudio.playLongAudio('drumbeat.wav');
  }


  @override
  void update(double dt) {
    currentTime += dt;
    if (nextRobotActionIndex < robotActionTimes.length &&
        currentTime >= robotActionTimes[nextRobotActionIndex]) {
      action(nextRobotActionIndex);
      if (nextRobotActionIndex == 3){
        water = Rect.zero;
        plant = Rect.fromLTWH(screenSize.width / 2, screenSize.height - 75, 10, 40);
      }
      if (nextRobotActionIndex == 4) {
        if (timesPressed == 3 && win) {
          plantText.text = "You Won!";
        } else {
          plantText.text = "You Lost!";
          plantPaint.color = Colors.brown;
        }
      }
      nextRobotActionIndex++;
    }
  }

  void action(int currIndex) {
    if (currIndex == 0) {
      growPlant(60, 95, 195);
    }
    else if (currIndex == 1) {
      growPlant(80, 115, 175);
    }
    else if (currIndex == 2) {
      growPlant(100, 135, 155);
    }
  }

  void playerTap(TapUpDetails details) {
      double playerActionTime = playerActionTimes[nextPlayerActionIndex];
      if (currentTime >= playerActionTime - 0.3 &&
          currentTime <= playerActionTime + 0.3) {
        action(nextPlayerActionIndex);
        ++timesPressed;
        nextPlayerActionIndex++;
      } else {
        print("Failed player action at $currentTime");
        plantPaint.color = Colors.brown;
        win = false;
      }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(wateringCan, canPaint);
    canvas.drawRect(platform, platformPaint);
    canvas.drawRect(water, waterPaint);
    canvas.drawRect(plant, plantPaint);
    plantText.textRenderer = textPaint;
    plantText.render(canvas);
  }

  @override
  void onGameResize(Vector2 size) {
    screenSize = size.toSize();
    super.onGameResize(size);
    wateringCan = Rect.fromLTWH(screenSize.width / 2 + 15, screenSize.height / 4, 100, 100);
    platform = Rect.fromLTWH(0, screenSize.height - 50, 1000, 50);
    plant = Rect.fromLTWH(screenSize.width / 2, screenSize.height - 75, 10, 40);
  }

  void growPlant(double pHeight, int pBase, double wHeight) {
    plant = Rect.fromLTWH(screenSize.width / 2, screenSize.height - pBase, 10, pHeight);
    water = Rect.fromLTWH(screenSize.width / 2, screenSize.height / 4, 10, wHeight);
  }
}



Map<String, dynamic> loadJson() {
  try {
    const jsonString =
      {
          "song": {
              "player": {
                  "action": [
                        15.6,
                        17.5,
                        19.3,
                    ],
                  "inaction": [
                        14.0,
                        14.9,
                        18.3,
                        18.6,
                        19.2,
                        19.5,
                        20.5,
                        20.6
                    ]
          },
        "robot": {
            "action": [
                        8.2,
                        10.0,
                        11.9,
                        13.8,
                        21.0


            ],
            "inaction": [
                17.4,
                18.1,
                19.6,
                19.9
            ]
        }
          }
      };
    const Map<String, dynamic> jsonData = jsonString;
    return jsonData;
  } catch (e) {
    print('Error loading JSON data: $e');
    return {};
  }
}













