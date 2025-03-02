import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'brick_breaker_game_setting_screen.dart';
import 'galaga_game_setting_screen.dart';
import 'tetris_game_setting_screen.dart';

class GameListScreen extends StatefulWidget {
  final Stream<List<double>> bluetoothDataStream;

  const GameListScreen({
    super.key,
    required this.bluetoothDataStream,
    required double initialRoll,
    required double initialPitch,
    required double initialYaw,
    required double initialAccx,
    required double initialAccy,
    required double initialAccz,
    required double initialPressure1,
    required double initialPressure2,
  });

  @override
  _GameListScreenState createState() => _GameListScreenState();
}

class _GameListScreenState extends State<GameListScreen>
    with WidgetsBindingObserver {
  late StreamSubscription<List<double>> _bluetoothSubscription;

  double roll = 0.0, pitch = 0.0, yaw = 0.0;
  double accx = 0.0, accy = 0.0, accz = 0.0;
  double pressure1 = 0.0, pressure2 = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _bluetoothSubscription = widget.bluetoothDataStream.listen((data) {
      if (!mounted) return;
      setState(() {
        roll = data[0];
        pitch = data[1];
        yaw = data[2];
        accx = data[3];
        accy = data[4];
        accz = data[5];
        pressure1 = data[6];
        pressure2 = data[7];
      });
    });
  }

  @override
  void dispose() {
    _cancelBluetoothSubscription();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _cancelBluetoothSubscription() {
    _bluetoothSubscription.cancel();
  }

  Future<void> _showExitConfirmation() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('앱 종료'),
        content: const Text('앱을 종료하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              _cancelBluetoothSubscription();
              Navigator.pop(context, true);
            },
            child: const Text('확인'),
          ),
        ],
      ),
    );

    if (mounted && (shouldExit ?? false)) {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          await _showExitConfirmation();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('게임 목록'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 실시간 블루투스 데이터 표시
            // Padding(
            //   padding: const EdgeInsets.all(8.0),
            //   child: Card(
            //     elevation: 4,
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //     child: Padding(
            //       padding: const EdgeInsets.all(16.0),
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           const Text('실시간 데이터',
            //               style: TextStyle(
            //                   fontSize: 18, fontWeight: FontWeight.bold)),
            //           // 실시간 데이터 표시
            //           Text("Roll(세로축 회전 각도): ${roll.toStringAsFixed(2)}"),
            //           Text("Pitch(가로축 회전 각도): ${pitch.toStringAsFixed(2)}"),
            //           Text("Yaw(수직축 회전 각도): ${yaw.toStringAsFixed(2)}"),
            //           Text("AccX(X축 가속도 값 - 좌,우): ${accx.toStringAsFixed(2)}"),
            //           Text("AccY(Y축 가속도 값 - 앞,뒤): ${accy.toStringAsFixed(2)}"),
            //           Text("AccZ(Z축 가속도 값 - 위,아래): ${accz.toStringAsFixed(2)}"),
            //           Text(
            //               "Pressure1(바깥쪽 압력): ${pressure1.toStringAsFixed(2)}"),
            //           Text("Pressure2(안쪽 압력): ${pressure2.toStringAsFixed(2)}"),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildGameCard(
                    context,
                    "1. 벽돌 깨기 게임",
                    Icons.sports_esports,
                    BrickBreakerGameSettingScreen(
                      initialRoll: roll,
                      initialPitch: pitch,
                      initialYaw: yaw,
                      initialAccx: accx,
                      initialAccy: accy,
                      initialAccz: accz,
                      initialPressure1: pressure1,
                      initialPressure2: pressure2,
                      bluetoothDataStream: widget.bluetoothDataStream,
                    ),
                  ),
                  _buildGameCard(
                    context,
                    "2. 비행기 게임",
                    Icons.airplanemode_active,
                    GalagaGameSettingScreen(
                      initialRoll: roll,
                      initialPitch: pitch,
                      initialYaw: yaw,
                      initialAccx: accx,
                      initialAccy: accy,
                      initialAccz: accz,
                      initialPressure1: pressure1,
                      initialPressure2: pressure2,
                      bluetoothDataStream: widget.bluetoothDataStream,
                    ),
                  ),
                  _buildGameCard(
                    context,
                    "3. 테트리스 게임",
                    Icons.grid_view,
                    TetrisGameSettingScreen(
                      initialRoll: roll,
                      initialPitch: pitch,
                      initialYaw: yaw,
                      initialAccx: accx,
                      initialAccy: accy,
                      initialAccz: accz,
                      initialPressure1: pressure1,
                      initialPressure2: pressure2,
                      bluetoothDataStream: widget.bluetoothDataStream,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, String gameTitle, IconData icon,
      Widget nextScreen) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => nextScreen),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Colors.blue),
              const SizedBox(width: 16),
              Text(
                gameTitle,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
