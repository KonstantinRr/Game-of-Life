import 'package:flutter/material.dart';

class GameOfLife404 extends StatelessWidget {
  const GameOfLife404({Key key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Text('Could not find page: Error 404',
          style: theme.textTheme.headline6,),
      ),
    );
  }
}
