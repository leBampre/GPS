import 'package:flutter/widgets.dart';

class Time with ChangeNotifier {

  dynamic _currentTime;
  dynamic _timeForClock;

  dynamic get currentTime => _currentTime;
  dynamic get timeForClock => _timeForClock;

  void changedTime(newClockTime, newTime) {
    _timeForClock = newClockTime;
    _currentTime = newTime;

    //print('$_timeForClock, $_currentTime');
    
    notifyListeners();
  }
}
