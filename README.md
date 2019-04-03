# flip_card

A component that provides flip card animation. It could be used for hide and show details of a product.

<p>
<img src="https://github.com/fedeoo/flip_card/blob/master/screenshots/flip-h.gif?raw=true&v1" width="320" />
<img src="https://github.com/fedeoo/flip_card/blob/master/screenshots/flip-v.gif?raw=true&v1" width="320" />
</p>

## How to use


````dart
import 'package:flip_card/flip_card.dart';
````

Create a flip card

```dart
FlipCard(
  direction: FlipDirection.HORIZONTAL, // default
  front: Container(
        child: Text('Front'),
    ),
    back: Container(
        child: Text('Back'),
    ),
);
```

Trigger the flip from outside the card;

```dart
import 'package:flip_card/flipBloc.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';

class ContainingWidget extends StatefulWidget{


  @override
  _ContainingWidgetState createState() => _TransporterTicketState();
}

class _ContainingWidgetState extends State<ContainingWidget>{
  FlipBloc flipBloc= FlipBloc();

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:FlipCard(
        flipBloc: flipBloc,
        fullScreen:false,
        speed:500,
        direction: FlipDirection.HORIZONTAL,
        front: MyFrontWidget(),
        back: MyBackWidget()
      ),
    bottomNavigationBar:RaisedButton(
      onPressed:(){
        flipBloc.toggle();
      })
    );
  }
}
```
