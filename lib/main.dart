import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const TimerApp());
}

class TimerApp extends StatelessWidget {
  const TimerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timer & Stopwatch',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      home: const TimerHomePage(),
    );
  }
}

class TimerHomePage extends StatefulWidget {
  const TimerHomePage({super.key});

  @override
  State<TimerHomePage> createState() => _TimerHomePageState();
}

class _TimerHomePageState extends State<TimerHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _stopwatchTimer;
  int _stopwatchTime = 0;
  bool _isStopwatchRunning = false;

  Timer? _countdownTimer;
  int _countdownTime = 0;
  final TextEditingController _hourController = TextEditingController();
  final TextEditingController _minuteController = TextEditingController();
  final TextEditingController _secondController = TextEditingController();
  
  // Ініціалізація аудіоплеєра
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _stopwatchTimer?.cancel();
    _countdownTimer?.cancel();
    _tabController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    _secondController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatTime(int milliseconds) {
    int seconds = (milliseconds / 1000).truncate() % 60;
    int minutes = (milliseconds / (1000 * 60)).truncate() % 60;
    int hours = (milliseconds / (1000 * 60 * 60)).truncate();
    int millisecondsPart = milliseconds % 1000;

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${(millisecondsPart / 10).truncate().toString().padLeft(2, '0')}';
  }

  String _formatTimeForTimer(int milliseconds) {
    int seconds = (milliseconds / 1000).truncate() % 60;
    int minutes = (milliseconds / (1000 * 60)).truncate() % 60;
    int hours = (milliseconds / (1000 * 60 * 60)).truncate();

    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _startStopwatch() {
    if (!_isStopwatchRunning) {
      _stopwatchTimer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
        setState(() {
          _stopwatchTime += 10;
        });
      });
      setState(() {
        _isStopwatchRunning = true;
      });
    }
  }

  void _stopStopwatch() {
    _stopwatchTimer?.cancel();
    setState(() {
      _isStopwatchRunning = false;
    });
  }

  void _resetStopwatch() {
    _stopStopwatch();
    setState(() {
      _stopwatchTime = 0;
    });
  }

  void _startCountdown() {
    int hours = int.tryParse(_hourController.text) ?? 0;
    int minutes = int.tryParse(_minuteController.text) ?? 0;
    int seconds = int.tryParse(_secondController.text) ?? 0;

    int totalTime = hours * 3600 + minutes * 60 + seconds;

    if (totalTime > 0) {
      setState(() {
        _countdownTime = totalTime;
      });

      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_countdownTime > 0) {
          setState(() {
            _countdownTime--;
          });
        } else {
          _countdownTimer?.cancel();
          // Відтворюємо звук, коли таймер закінчується
          _playEndSound();
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введіть значення для таймера')),
      );
    }
  }

  void _stopCountdown() {
    _countdownTimer?.cancel();
  }

  void _resetCountdown() {
    _stopCountdown();
    setState(() {
      _countdownTime = 0;
      _hourController.clear();
      _minuteController.clear();
      _secondController.clear();
    });
  }

  // Функція для відтворення звуку по закінченню таймера
  void _playEndSound() async {
    // Локальний звуковий файл
    await _audioPlayer.play(AssetSource('sounds/timer_end.wav'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timer & Stopwatch'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Секундомір'),
            Tab(text: 'Таймер'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatTime(_stopwatchTime),
                  style: const TextStyle(fontSize: 60, fontFamily: 'monospace'),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _isStopwatchRunning ? _stopStopwatch : _startStopwatch,
                      child: Text(_isStopwatchRunning ? 'Стоп' : 'Старт'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: _resetStopwatch,
                      child: const Text('Скинути'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatTimeForTimer(_countdownTime * 1000),
                  style: const TextStyle(fontSize: 60, fontFamily: 'monospace'),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 70,
                      child: TextField(
                        controller: _hourController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Години'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 70,
                      child: TextField(
                        controller: _minuteController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Хвилини'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 70,
                      child: TextField(
                        controller: _secondController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Секунди'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _startCountdown,
                      child: const Text('Старт'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: _stopCountdown,
                      child: const Text('Стоп'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: _resetCountdown,
                      child: const Text('Скинути'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
