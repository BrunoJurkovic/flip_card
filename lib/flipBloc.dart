import 'dart:async';
import 'package:frideos/frideos.dart';

class FlipBloc {

  FlipBloc(){
    _isFront.value=false;
    print("Flipbloc");
  }

  final _isFront=StreamedValue<bool>();

  Stream<bool> get isFront => _isFront.stream;

  void toggle(){
    print("toggle  ${_isFront.value}");
    _isFront.inStream(!_isFront.value);
    print ("toggled ${_isFront.value}");
  }

  dispose(){
    _isFront.dispose();
  }
}