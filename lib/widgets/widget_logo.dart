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

import 'package:flutter/material.dart';

class WidgetLogo extends StatelessWidget {
  final double size;
  final EdgeInsets margin;
  const WidgetLogo({@required this.size,
    this.margin, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      margin: margin,
      decoration: const BoxDecoration(
        image: const DecorationImage(
          image: const AssetImage('assets/logo.png')
        )
      ),
    );
  }
}

class WidgetHeaderLogo extends StatelessWidget {
  final bool dense;
  final String name;
  const WidgetHeaderLogo({this.name = 'Game of Life',
    this.dense=false, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 20),
      child: dense ?
        const Align(
          alignment: Alignment.center,
          child: const WidgetLogo(size: 35.0,)
        ) :
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget> [
            const WidgetLogo(size: 35.0,),
            const SizedBox(width: 10.0,),
            Text(name, style: Theme.of(context).textTheme.headline5,),
          ]
        ),
    );
  }
}
