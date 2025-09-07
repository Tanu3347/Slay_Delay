import 'package:flutter/material.dart';
import 'package:slay_delay/screens/timer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.startIndex = 0});
  final int startIndex;

  @override
  State<StatefulWidget> createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedPageIndex = 0;
  @override
  void initState() {
    super.initState();
    _selectedPageIndex = widget.startIndex;
  }

  void _selectPage(index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const TimerScreen(),
      const Center(
        child: Text(
          'Habit Tracker Placeholder',
          style: TextStyle(color: Colors.white),
        ),
      ), // replace later
      const Center(
        child: Text('Game Placeholder', style: TextStyle(color: Colors.white)),
      ), // replace later
    ];
    // Widget activePage = const TimerScreen();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Pick your category',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      //drawer: Drawer(),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        currentIndex: _selectedPageIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: 'Focus Timer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Habit Tracker',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.videogame_asset),
            label: 'Game',
          ),
        ],
      ),
      body: pages[_selectedPageIndex],
    );
  }
}
