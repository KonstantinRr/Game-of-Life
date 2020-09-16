import 'package:flutter/material.dart';
import 'package:game_of_life/page_404.dart';
import 'package:game_of_life/page_home.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(GameOfLife());
}

class GameOfLife extends StatefulWidget {
  const GameOfLife({Key key}) : super(key: key);

  @override
  GameOfLifeState createState() => GameOfLifeState();
}

class GameOfLifeState extends State<GameOfLife> {
  SimulationController controller;
  SimulationData data;

  @override
  void initState() {
    super.initState();
    controller = SimulationController();
    data = SimulationData();
    data.resize(10, 10);

    controller.data = data;
    data.controller = controller;
  }

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SimulationController>(
          create: (context) => controller,
        ),
        ChangeNotifierProvider<SimulationData>(
          create: (context) => data,
        )
      ],
      child: MaterialApp(
        title: 'Conway\'s Game of Life',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        onGenerateRoute: onGenerateRoute,
      ),
    );
  }
}
