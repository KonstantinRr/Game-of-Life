

import 'package:flutter/material.dart';
import 'package:game_of_life/state.dart';
import 'package:provider/provider.dart';

class WidgetSlider extends StatelessWidget {
  final int min, max;
  const WidgetSlider({this.min = 100, this.max = 1000,
    Key key}) : super(key: key);

  // Example: max=1000, min=100
  // scale value 800 => 1000 - 800 = 200 tick speed
  // 200 tick speed => 1000 - 200 = 800 scale value
  double toScale(int value) => max - value.toDouble();
  int fromScale(double value ) => max - value.toInt();
  @override
  Widget build(BuildContext context) {
    return Consumer<SimulationController>(
      builder: (context, sim, child) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget> [
            Text('Speed', style: Theme.of(context).textTheme.headline6,),
            SizedBox(
              width: 200.0,
              child: Slider(
                value: toScale(sim.speed),
                onChanged: (newVal) => sim.speed = fromScale(newVal),
                onChangeEnd: (newVal) {
                  sim.speed = fromScale(newVal);
                  sim.setSpeedStream();
                },
                min: 0.0, max: max.toDouble(),
              ),
            )
          ]
        );
      }
    );
  }
}