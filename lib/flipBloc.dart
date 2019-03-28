import 'dart:async';
import 'package:frideos/frideos.dart';

class FlipBloc {

  FlipBloc(){
    _isFront.value=true;
    print("Flipbloc");
  }

  final _isFront=StreamedValue<bool>();

  Stream<bool> get isFront => _isFront.stream;

  void toggle(){
    if (_isFront.value=null) {
     _isFront.value=true;
     return;
    }
    _isFront.inStream(!_isFront.value);
  }

  dispose(){
    _isFront.dispose();
  }
}