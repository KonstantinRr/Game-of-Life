

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class GameOfLifeHome extends StatefulWidget {
  final int width, height;
  const GameOfLifeHome({this.width = 10, this.height = 10,
    Key key}) : super(key: key);

  @override
  GameOfLifeHomeState createState() => GameOfLifeHomeState();
}

class CellWidget extends CustomPainter {
  static Paint inactiveColor = Paint()
    ..color = Colors.yellow
    ..style = PaintingStyle.fill;
  static Paint activeColor = Paint()
    ..color = Colors.green
    ..style = PaintingStyle.fill;

  final GameOfLifeHomeState parent;
  final double padding;
  const CellWidget(this.parent, {this.padding = 1.0});

  static double getSquareSize(Size size, int countWidth, int countHeight) {
    var dW = size.width / countWidth;
    var dH = size.height / countHeight;
    return math.min(dW, dH);
  }

  @override
  void paint(Canvas canvas, Size size) {
    var square = getSquareSize(size, parent.widget.width, parent.widget.height);
    for (int w = 0; w < parent.widget.width; w++) {
      for (int h = 0; h < parent.widget.height; h++) {
        var rect = Rect.fromLTWH(
          square * w + padding, square * h + padding,
          square - padding, square - padding);
        canvas.drawRect(rect, parent.currentMap[w][h] ? activeColor : inactiveColor);
      }
    }
  }
  
  @override
  bool shouldRepaint(CellWidget oldDelegate) => true;
}

class GameOfLifeHomeState extends State<GameOfLifeHome> {
  List<List<bool>> currentMap;
  List<List<bool>> nextMap;
  GlobalKey gestureKey = GlobalKey();
  bool setter = true;
  bool play = false;

  Stream updateStream;
  StreamSubscription subscription;

  @override
  void initState() {
    super.initState();
    // creates an empty game map
    currentMap = List.generate(widget.width,
      (index) => List.generate(widget.height, (index) => false));
    nextMap = List.generate(widget.width,
      (index) => List.generate(widget.height, (index) => false));

    updateStream = Stream.periodic(Duration(milliseconds: 500));
    subscription = updateStream.listen((event) {
      if (play) {
        updateAll();
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  bool getCell(int w, int h) =>
    (w < 0 || w >= currentMap.length) ? false :
      (h < 0 || h >= currentMap[w].length) ? false : currentMap[w][h];
  int boolToNum(bool v) => v ? 1 : 0;

  void updateAll() {
    for (int w = 0; w < currentMap.length; w++) {
      for (int h = 0; h < currentMap[w].length; h++)
        nextMap[w][h] = nextCellState(w, h);
    }
    var temp = currentMap;
    currentMap = nextMap;
    nextMap = temp;
  }

  bool nextCellState(int w, int h) {
    int neighbours =
      boolToNum(getCell(w-1, h+1)) + 
      boolToNum(getCell(w-1, h)) + 
      boolToNum(getCell(w-1, h-1)) + 
      boolToNum(getCell(w, h+1)) + 
      boolToNum(getCell(w, h-1)) + 
      boolToNum(getCell(w+1, h+1)) + 
      boolToNum(getCell(w+1, h)) + 
      boolToNum(getCell(w+1, h-1));

    return currentMap[w][h] ?
      neighbours >= 2 && neighbours <= 3 :
      neighbours == 3;
  }

  void clearMap() {
    currentMap.forEach((col) =>
      col.fillRange(0, col.length, false));
  }

  void setPointer(Offset local) {
    var box = gestureKey.currentContext
      .findRenderObject() as RenderBox;
    var square = CellWidget.getSquareSize(
      box.size, widget.width, widget.height);

    var countWidth = local.dx ~/ square;
    var countHeight = local.dy ~/ square;
    if (countWidth >= 0 && countWidth < widget.width &&
      countHeight >= 0 && countHeight < widget.height) {
      // applies the state if it is not new
      if (currentMap[countWidth][countHeight] != setter)
        setState(() => currentMap[countWidth][countHeight] = setter);
    }
  }

  @override
  Widget build(BuildContext context) {
    const iconPadding = EdgeInsets.symmetric(horizontal: 5, vertical: 5);
    return Scaffold(
      body: Column(
        children: <Widget> [
          Container(
            height: 70.0,
            child: Row(
              children: [
                IconButton(
                  padding: iconPadding,
                  icon: Icon(!play ? Icons.play_arrow : Icons.stop),
                  onPressed: () => setState(() { play = !play; }),
                  tooltip: !play ? 'Run Simulation' : 'Stop Simulation',
                ),
                IconButton(
                  padding: iconPadding,
                  icon: Icon(Icons.clear),
                  onPressed: () => clearMap(),
                  tooltip: 'Clear Map',
                ),
                IconButton(
                  padding: iconPadding,
                  icon: Icon(setter ? Icons.add : Icons.remove),
                  onPressed: () => setState(() { setter = !setter; }),
                  tooltip: setter ? 'Adder' : 'Substractor',
                ),
              ],
            ),
          ),
          Expanded(
            child: CustomPaint(
              foregroundPainter: CellWidget(this, padding: 1.0),
              child: GestureDetector(
                key: gestureKey,
                onPanStart: (DragStartDetails details) => setPointer(details.localPosition),
                onPanUpdate: (DragUpdateDetails details) => setPointer(details.localPosition),
                onPanEnd: (DragEndDetails details) {},
              ),
              willChange: true,
              isComplex: true,
            ),
          ),
        ]
      ),
    );
  }
}
