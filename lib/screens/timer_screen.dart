import 'dart:async';

import 'package:flutter/material.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() {
    return _TimerScreenState();
  }
}

class _TimerScreenState extends State<TimerScreen> {
  final int _initialSeconds = 30; //10 while testing
  int _remainingSeconds = 0;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _initialSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    if (_isRunning) return; //to not start multiple timers
    setState(() {
      _isRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {}
    });
  }

  void _pause() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _isRunning = false;
    });
  }

  void _reset() {
    _timer?.cancel();
    _timer = null;
    setState(() {
      _isRunning = false;
      _remainingSeconds = _initialSeconds;
    });
  }

  // void _finish() {
  //   _timer?.cancel();
  //   _timer = null;
  //   setState(() {
  //     _isRunning = false;
  //     _remainingSeconds = 0;
  //   });
  //   if (mounted) {
  //     ScaffoldMessenger.of(context).clearSnackBars();
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Session complete — take a break!')),
  //     );
  //   }
  // }

  void _handleFocusBroken() {
    _reset();
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Focus broken — timer reset.')),
      );
    }
  }

  String _formatMmSs(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  double get _progress {
    final elapsed = (_initialSeconds - _remainingSeconds).clamp(
      0,
      _initialSeconds,
    );
    return elapsed / _initialSeconds;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return; //if already popped we do nothing
        if (!_isRunning) {
          //if timer is not running we can pop
          Navigator.of(context).pop();
          return;
        }
        final shouldLeave = await showDialog<bool>(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: Text(
                'Leave Session',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              content: Text(
                'Leaving will break your focus session and reset the timer.\n\nDo you want to leave?',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Stay'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Leave'),
                ),
              ],
            );
          },
        );
        if (shouldLeave == true) {
          _handleFocusBroken();
          if (mounted) {
            Navigator.of(context).pop(result);
          }
        }
      },
      child: Scaffold(
        // appBar: AppBar(title: const Text('Your Focus Timer')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 220,
                width: 220,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: _progress,
                      strokeWidth: 12,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    Center(
                      child: Text(
                        _formatMmSs(_remainingSeconds),
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _isRunning ? null : _start,
                    child: const Text('Start'),
                  ),
                  const SizedBox(width: 30),
                  ElevatedButton(
                    onPressed: _isRunning ? _pause : null,
                    child: const Text('Pause'),
                  ),
                  const SizedBox(width: 30),
                  ElevatedButton(onPressed: _reset, child: const Text('Reset')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
