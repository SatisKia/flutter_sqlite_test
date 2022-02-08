import 'package:flutter/material.dart';

import 'test.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State createState() => MyHomePageState();
}

class MyHomePageState extends State {
  double contentWidth  = 0.0;
  double contentHeight = 0.0;

  var console = <Widget>[];
  void addConsole( Widget widget ){
    setState(() {
      console.add( widget );
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      bool clean = false; // データベースを削除してから実行するかどうか
      bool raw = true; // raw系の関数を使用するかどうか

      test( this, clean, raw, 1 );
//      test( this, clean, raw, 2 );
//      test( this, clean, raw, 3 );
//      test2( this, clean );
    });
  }

  @override
  Widget build(BuildContext context) {
    contentWidth  = MediaQuery.of( context ).size.width;
    contentHeight = MediaQuery.of( context ).size.height - MediaQuery.of( context ).padding.top - MediaQuery.of( context ).padding.bottom;

    return Scaffold(
        appBar: AppBar(
            toolbarHeight: 0
        ),
        body: SingleChildScrollView(
            child: Column(
                children: console
            )
        )
    );
  }
}
