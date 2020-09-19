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

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:game_of_life/state.dart';
import 'package:game_of_life/widgets/widget_logo.dart';
import 'package:game_of_life/widgets/widget_slider.dart';
import 'package:provider/provider.dart';

class GameOfLifeHome extends StatefulWidget {
  const GameOfLifeHome({Key key}) : super(key: key);

  @override
  GameOfLifeHomeState createState() => GameOfLifeHomeState();
}

class ControlPanel extends StatelessWidget {
  const ControlPanel({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const iconPadding = EdgeInsets.symmetric(horizontal: 5, vertical: 5);
    const Size itemSize = Size(40.0, 70.0);

    return Consumer<SimulationController>(
      builder: (context, sim, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              color: Colors.grey[200],
              child: Material(
                type: MaterialType.transparency,
                child: Row(
                  children: <Widget> [
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget> [
                        const WidgetHeaderLogo(),
                        Wrap( // the ac
                          children: <Widget> [
                            SizedBox(
                              height: itemSize.height, width: itemSize.width,
                              child: Align(
                                alignment: Alignment.center,
                                child: IconButton(
                                  padding: iconPadding,
                                  icon: Icon(!sim.play ? Icons.play_arrow : Icons.stop),
                                  onPressed: () => sim.play = !sim.play,
                                  tooltip: !sim.play ? 'Run Simulation' : 'Stop Simulation',
                                )
                              ),
                            ),
                            SizedBox(
                              height: itemSize.height, width: itemSize.width,
                              child: Align(
                                alignment: Alignment.center,
                                child: IconButton(
                                  padding: iconPadding,
                                  icon: Icon(Icons.clear),
                                  onPressed: () => sim.data.clearMap(),
                                  tooltip: 'Clear Map',
                                )
                              ),
                            ),
                            SizedBox(
                              height: itemSize.height, width: itemSize.width,
                              child: Align(
                                alignment: Alignment.center,
                                child: IconButton(
                                  padding: iconPadding,
                                  icon: Icon(sim.setter ? Icons.add : Icons.remove),
                                  onPressed: () => sim.setter = !sim.setter,
                                  tooltip: sim.setter ? 'Adder' : 'Substractor',
                                ),
                              ),
                            ),
                            const Padding(
                              padding: iconPadding,
                              child: const WidgetSlider(),
                            ),
                          ]
                        )
                      ]
                    )),
                  ]
                ),
              )
            );
          }
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
    int sizeWidth = size.width ~/ 30;
    int sizeHeight = size.height ~/ 30;
    if (parent.width != sizeWidth || parent.height != sizeHeight)
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
        parent.resize(sizeWidth, sizeHeight);
      });
    
    var square = getSquareSize(size, parent.width, parent.height);
    for (int w = 0; w < parent.width; w++) {
      for (int h = 0; h < parent.height; h++) {
        var rect = Rect.fromLTWH(
          square * w + padding, square * h + padding,
          square - padding, square - padding);
        canvas.drawRect(rect, parent.getCurrent(w, h)
          ? activeColor : inactiveColor);
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
      box.size, data.width, data.height);

    var countWidth = local.dx ~/ square;
    var countHeight = local.dy ~/ square;
    if (countWidth >= 0 && countWidth < data.width &&
      countHeight >= 0 && countHeight < data.height)
      data.setCurrent(countWidth, countHeight, data.controller.setter);
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
                  willChange: false,
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
