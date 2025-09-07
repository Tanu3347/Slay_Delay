import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() {
    return _GameScreenState();
  }
}

class _GameScreenState extends State<GameScreen> {
  final Random _rand = Random();

  int _score = 0;
  int _timeLeft = 30;
  bool _isRunning = false;

  double _monsterX = 0;
  double _monsterY = 0;
  bool _monsterVisible = false;

  final double _monsterSize = 80;
  Timer? _gameTimer;
  Timer? _moveTimer;
  Timer? _hideTimer;

  BoxConstraints? _playAreaConstraints;

  final Duration _moveInterval = const Duration(milliseconds: 800);
  final Duration _showDuration = const Duration(milliseconds: 700);

  final List<String> _monsters = ['🐌', '😴', '👾', '🦥'];
  String get _currentMonster => _monsters[_rand.nextInt(_monsters.length)];

  @override
  void dispose() {
    _cancelAllTimers();
    super.dispose();
  }

  void _cancelAllTimers() {
    _gameTimer?.cancel();
    _moveTimer?.cancel();
    _hideTimer?.cancel();
    _gameTimer = null;
    _moveTimer = null;
    _hideTimer = null;
  }

  void _startGame() {
    if (_isRunning) return;
    if (_playAreaConstraints == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wait a moment — UI not ready')),
      );
      return;
    }

    setState(() {
      _score = 0;
      _timeLeft = 30;
      _isRunning = true;
    });

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_timeLeft <= 1) {
        _endGame();
      } else {
        setState(() => _timeLeft -= 1);
      }
    });

    _moveTimer = Timer.periodic(_moveInterval, (t) {
      _showMonsterRandomly();
    });

    _showMonsterRandomly();
  }

  void _endGame() {
    _cancelAllTimers();
    setState(() {
      _isRunning = false;
      _monsterVisible = false;
      _timeLeft = 0;
    });

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Game over!',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Theme.of(context).colorScheme.primaryFixed,
          ),
        ),
        content: Text(
          'Your score: $_score\nNice job fighting procrastination!',
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: Theme.of(context).colorScheme.primaryFixed,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _startGame();
            },
            child: const Text('Play again'),
          ),
        ],
      ),
    );
  }

  void _showMonsterRandomly() {
    final constraints = _playAreaConstraints!;
    final maxX = (constraints.maxWidth - _monsterSize).clamp(
      0.0,
      double.infinity,
    );
    final maxY = (constraints.maxHeight - _monsterSize).clamp(
      0.0,
      double.infinity,
    );

    final nextX = _rand.nextDouble() * maxX;
    final nextY = _rand.nextDouble() * maxY;

    _hideTimer?.cancel();

    setState(() {
      _monsterX = nextX;
      _monsterY = nextY;
      _monsterVisible = true;
    });

    _hideTimer = Timer(_showDuration, () {
      setState(() {
        _monsterVisible = false;
      });
    });
  }

  void _onMonsterTap() {
    if (!_isRunning || !_monsterVisible) return;

    setState(() {
      _score += 1;
      _monsterVisible = false;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_funHitMessage(_score)),
        duration: const Duration(milliseconds: 600),
      ),
    );

    _hideTimer?.cancel();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (_isRunning && mounted) _showMonsterRandomly();
    });
  }

  String _funHitMessage(int score) {
    if (score < 3) return 'Nice! You slapped it!';
    if (score < 7) return 'Boom — procrastination trembles!';
    if (score < 12) return 'You\'re on fire 🔥';
    return 'Procrastination obliterated! 💥';
  }

  void _stopGame() {
    _cancelAllTimers();
    setState(() {
      _isRunning = false;
      _monsterVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _playAreaConstraints = constraints;
        final double playAreaTop = 100;
        final double playAreaBottom = constraints.maxHeight - 150;

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  left: 16,
                  right: 16,
                  top: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Score',
                            style: Theme.of(context).textTheme.labelLarge!
                                .copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$_score',
                            style: Theme.of(context).textTheme.headlineMedium!
                                .copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primaryFixed,
                                ),
                          ),
                        ],
                      ),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Time',
                            style: Theme.of(context).textTheme.labelLarge!
                                .copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$_timeLeft s',
                            style: Theme.of(context).textTheme.headlineMedium!
                                .copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primaryFixed,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                AnimatedPositioned(
                  left: _monsterX.clamp(
                    0.0,
                    constraints.maxWidth - _monsterSize,
                  ),
                  top: _monsterY.clamp(
                    playAreaTop,
                    playAreaBottom - _monsterSize,
                  ),
                  duration: const Duration(milliseconds: 220),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 120),
                    opacity: _monsterVisible ? 1.0 : 0.0,
                    child: GestureDetector(
                      onTap: _onMonsterTap,
                      child: SizedBox(
                        width: _monsterSize,
                        height: _monsterSize,
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.amberAccent.withAlpha(38),
                            ),
                            alignment: Alignment.center,
                            width: _monsterSize,
                            height: _monsterSize,
                            child: Text(
                              _currentMonster,
                              style: const TextStyle(fontSize: 42),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 18,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Tap the snail/monster quickly to score!',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.primaryFixed,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _isRunning ? _stopGame : _startGame,
                            icon: Icon(
                              _isRunning ? Icons.stop : Icons.play_arrow,
                            ),
                            label: Text(_isRunning ? 'Stop' : 'Start'),
                          ),
                          const SizedBox(width: 14),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _score = 0;
                                _timeLeft = 30;
                                _monsterVisible = false;
                              });
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Reset'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
