import 'flipBloc.dart';
import 'package:flutter/material.dart';


class FlipProvider extends InheritedWidget{
  final FlipBloc bloc=FlipBloc();

  FlipProvider ({ Key key, Widget child})
      : super (key: key, child: child);

  static FlipBloc of(BuildContext context){
    return (context.inheritFromWidgetOfExactType(FlipProvider) as FlipProvider).bloc;
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    // TODO: implement updateShouldNotify
    return true;
  }
}