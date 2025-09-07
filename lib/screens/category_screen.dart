import 'package:flutter/material.dart';
import 'package:slay_delay/screens/home_screen.dart';
import 'package:slay_delay/widget/category_widget.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Categories',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      body: GridView(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          mainAxisSpacing: 20,
          childAspectRatio: 3 / 2,
        ),
        children: [
          CategoryWidget(
            title: 'Focus Timer',
            icon: const Icon(
              Icons.timer,
              size: 40,
              color: Color.fromARGB(255, 52, 26, 16),
            ),
            onSelectCategory: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(startIndex: 0),
                ),
              );
            },
          ),
          CategoryWidget(
            title: 'Habit Tracker',
            icon: const Icon(
              Icons.check_circle,
              size: 40,
              color: Color.fromARGB(255, 52, 26, 16),
            ),
            onSelectCategory: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(startIndex: 1),
                ),
              );
            },
          ),
          CategoryWidget(
            title: 'Mind Refereshing Game',
            icon: const Icon(
              Icons.videogame_asset,
              size: 40,
              color: Color.fromARGB(255, 52, 26, 16),
            ),
            onSelectCategory: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(startIndex: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
