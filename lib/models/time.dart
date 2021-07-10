import 'package:flutter/widgets.dart';
import 'package:holding_app/config/global.dart' as global;

class Time with ChangeNotifier {
  dynamic _timeForClock;

  dynamic get timeForClock => _timeForClock;

  void changedTime(newClockTime, newTime, newDate) {
    _timeForClock = newClockTime;
    //print('$_timeForClock, $_currentTime');
    global.time = newTime;
    
    global.date = newDate;

    notifyListeners();
  }
}
