import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlipCard',
      theme: ThemeData.dark(),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  _renderBg() {
    return Container(
      decoration: BoxDecoration(color: const Color(0xFFFFFFFF)),
    );
  }

  _renderAppBar(context) {
    return MediaQuery.removePadding(
      context: context,
      removeBottom: true,
      child: AppBar(
        brightness: Brightness.dark,
        elevation: 0.0,
        backgroundColor: Color(0x00FFFFFF),
      ),
    );
  }

  _renderContent(context) {
    return Card(
      elevation: 0.0,
      margin: EdgeInsets.only(left: 32.0, right: 32.0, top: 20.0, bottom: 0.0),
      color: Color(0x00000000),
      child: FlipCard(
        direction: FlipDirection.HORIZONTAL,
        front: Container(
          decoration: BoxDecoration(
            color: Color(0xFF006666),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Front', style: Theme.of(context).textTheme.headline),
              Text('Click here to flip back',
                  style: Theme.of(context).textTheme.body1),
            ],
          ),
        ),
        back: Container(
          decoration: BoxDecoration(
            color: Color(0xFF006666),
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Back', style: Theme.of(context).textTheme.headline),
              Text('Click here to flip front',
                  style: Theme.of(context).textTheme.body1),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('FlipCard'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _renderBg(),
          Column(
            children: <Widget>[
              _renderAppBar(context),
              Expanded(
                flex: 4,
                child: _renderContent(context),
              ),
              Expanded(
                flex: 1,
                child: Container(),
              ),
            ],
          )
        ],
      ),
    );
  }
}
