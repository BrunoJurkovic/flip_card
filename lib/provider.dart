import 'flipBloc.dart';
import 'package:flutter/material.dart';

class FlipProvider extends InheritedWidget{
  final bloc=FlipBloc();


  FlipProvider ({ Key key, Widget child})
      : super (key: key, child: child);

  @override
  bool updateShouldNotify(_) {
    return true;
  }

  static FlipBloc of(BuildContext context){
    return (context.inheritFromWidgetOfExactType(FlipProvider) as FlipProvider).bloc;
  }
}