// MIT License
// 
// Copyright (c) 2020 Konstantin Rolf
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SimulationController extends ChangeNotifier {
  bool _setter = true;
  bool _play = false;
  int _speed = 250;
  SimulationData _data;

  Stream _updateStream;
  StreamSubscription _subscription;

  SimulationController({SimulationData data}) : _data = data {
    setSpeedStream();
  }

  // ---- Getters ---- //
  bool get setter => _setter;
  bool get play => _play;
  int get speed => _speed;
  SimulationData get data => _data;

  // ---- Setters ---- //
  set setter(bool val) { if (_setter != val) { _setter = val; notifyListeners(); }}
  set play(bool val) { if (_play != val) { _play = val; notifyListeners(); }}
  set speed(int speed) { if (_speed != speed) { _speed = speed; notifyListeners(); }}
  set data(SimulationData data) { if (data != _data) { _data = data; notifyListeners(); }}

  void setSpeedStream() {
    _subscription?.cancel();

    _updateStream = Stream.periodic(Duration(milliseconds: _speed));
    _subscription = _updateStream.listen((event) {
      if (play) _data?.updateAll();
    });
  }

}

class SimulationData extends ChangeNotifier {
  SimulationController _controller;
  List<List<bool>> _currentMap;
  List<List<bool>> _nextMap;

  SimulationData({SimulationController controller}) : _controller = controller;

  int get width => _currentMap.length;
  int get height => _currentMap[0].length;

  void resize(int w, int h) {
    _currentMap = List.generate(w,
      (index) => List.generate(h, (index) => false, growable: false),
      growable: false);
    _nextMap = List.generate(w,
      (index) => List.generate(h, (index) => false, growable: false),
      growable: false);
    notifyListeners();
  }

  // ---- Getters ---- //
  bool getCurrent(int w, int h) => _currentMap[w][h];
  SimulationController get controller => _controller;

  void setCurrent(int w, int h, bool val) {
    _currentMap[w][h] = val; notifyListeners(); }
  set controller(SimulationController controller) {
    if (_controller != controller) {
      _controller = controller;
      notifyListeners();
    }
  }

  bool _getCell(int w, int h) =>
    (w < 0 || w >= _currentMap.length) ? false :
      (h < 0 || h >= _currentMap[w].length) ? false : _currentMap[w][h];
  int _boolToNum(bool v) => v ? 1 : 0;

  void updateAll() {
    for (int w = 0; w < _currentMap.length; w++) {
      for (int h = 0; h < _currentMap[w].length; h++)
        _nextMap[w][h] = nextCellState(w, h);
    }
    var temp = _currentMap;
    _currentMap = _nextMap;
    _nextMap = temp;
    notifyListeners();
  }

  bool nextCellState(int w, int h) {
    int neighbours =
      _boolToNum(_getCell(w-1, h+1)) + 
      _boolToNum(_getCell(w-1, h)) + 
      _boolToNum(_getCell(w-1, h-1)) + 
      _boolToNum(_getCell(w, h+1)) + 
      _boolToNum(_getCell(w, h-1)) + 
      _boolToNum(_getCell(w+1, h+1)) + 
      _boolToNum(_getCell(w+1, h)) + 
      _boolToNum(_getCell(w+1, h-1));

    return _currentMap[w][h] ?
      neighbours >= 2 && neighbours <= 3 :
      neighbours == 3;
  }

  void clearMap() {
    _currentMap.forEach((col) =>
      col.fillRange(0, col.length, false));
    notifyListeners();
  }
}

class GameOfLifeHome extends StatefulWidget {
  final int width, height;
  const GameOfLifeHome({this.width = 10, this.height = 10,
    Key key}) : super(key: key);

  @override
  GameOfLifeHomeState createState() => GameOfLifeHomeState();
}

class ControlPanel extends StatelessWidget {
  const ControlPanel({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const iconPadding = EdgeInsets.symmetric(horizontal: 5, vertical: 5);
    return Consumer<SimulationController>(
      builder: (context, sim, child) {
        return Container(
          height: 70.0,
          child: Row(
            children: [
              IconButton(
                padding: iconPadding,
                icon: Icon(!sim.play ? Icons.play_arrow : Icons.stop),
                onPressed: () => sim.play = !sim.play,
                tooltip: !sim.play ? 'Run Simulation' : 'Stop Simulation',
              ),
              IconButton(
                padding: iconPadding,
                icon: Icon(Icons.clear),
                onPressed: () => sim.data.clearMap(),
                tooltip: 'Clear Map',
              ),
              IconButton(
                padding: iconPadding,
                icon: Icon(sim.setter ? Icons.add : Icons.remove),
                onPressed: () => sim.setter = !sim.setter,
                tooltip: sim.setter ? 'Adder' : 'Substractor',
              ),
              Slider(
                value: sim.speed.toDouble(),
                onChanged: (newVal) => sim.speed = newVal.toInt(),
                onChangeEnd: (newVal) {
                  sim.speed = newVal.toInt();
                  sim.setSpeedStream();
                },
                min: 100.0, max: 1000.0,
              )
            ],
          ),
        );
      }
    );
  }
}

class CellWidget extends CustomPainter {
  static Paint inactiveColor = Paint()
    ..color = Colors.yellow
    ..style = PaintingStyle.fill;
  static Paint activeColor = Paint()
    ..color = Colors.green
    ..style = PaintingStyle.fill;

  final SimulationData parent;
  final double padding;
  const CellWidget(this.parent, {this.padding = 1.0});

  static double getSquareSize(Size size, int countWidth, int countHeight) {
    var dW = size.width / countWidth;
    var dH = size.height / countHeight;
    return math.min(dW, dH);
  }

  @override
  void paint(Canvas canvas, Size size) {
    var square = getSquareSize(size, parent.width, parent.height);
    for (int w = 0; w < parent.width; w++) {
      for (int h = 0; h < parent.height; h++) {
        var rect = Rect.fromLTWH(
          square * w + padding, square * h + padding,
          square - padding, square - padding);
        canvas.drawRect(rect, parent.getCurrent(w, h) ? activeColor : inactiveColor);
      }
    }
  }
  
  @override
  bool shouldRepaint(CellWidget oldDelegate) => true;
}

class GameOfLifeHomeState extends State<GameOfLifeHome> {
  GlobalKey gestureKey = GlobalKey();

  void setPointer(SimulationData data, Offset local) {
    var box = gestureKey.currentContext
      .findRenderObject() as RenderBox;
    var square = CellWidget.getSquareSize(
      box.size, widget.width, widget.height);

    var countWidth = local.dx ~/ square;
    var countHeight = local.dy ~/ square;
    if (countWidth >= 0 && countWidth < widget.width &&
      countHeight >= 0 && countHeight < widget.height) {
      // applies the state if it is not new
      data.setCurrent(countWidth, countHeight, data.controller.setter);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SimulationData>(
      builder: (context, data, child) {
        return Scaffold(
          body: Column(
            children: <Widget> [
              const ControlPanel(),
              Expanded(
                child: CustomPaint(
                  foregroundPainter: CellWidget(data, padding: 1.0),
                  child: GestureDetector(
                    key: gestureKey,
                    onPanStart: (details) => setPointer(data, details.localPosition),
                    onPanUpdate: (details) => setPointer(data, details.localPosition),
                    onPanEnd: (details) {},
                  ),
                  willChange: true,
                  isComplex: true,
                ),
              ),
            ]
          ),
        );
      }
    );
  }
}
