import 'package:flutter/material.dart';
import 'package:game_of_life/page_404.dart';
import 'package:game_of_life/page_home.dart';

void main() {
  runApp(GameOfLife());
}

class GameOfLife extends StatelessWidget {
  // This widget is the root of your application.
  Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/': return MaterialPageRoute(
        builder: (context) => GameOfLifeHome());
      default: return MaterialPageRoute(
        builder: (context) => GameOfLife404());
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conway\'s Game of Life',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: onGenerateRoute,
    );
  }
}
