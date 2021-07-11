import 'package:flutter/widgets.dart';
import 'package:holding_app/config/global.dart' as global;

class LocationInfo with ChangeNotifier {
  dynamic _location;
  dynamic _gpsIsActive = false;

  dynamic get getLocation => _location;
  dynamic get getGPSState => _gpsIsActive;

  void changeLocationandGPSActivity(newLatitude, newLongitude, newGPSStatus) {
    _location = 'lat: $newLatitude, long: $newLongitude';
    _gpsIsActive = newGPSStatus;

    global.latitude = degreesToMins(newLatitude, false);
    global.longitude = degreesToMins(newLongitude, true);
    //print('$_location, gps is: $_gpsIsActive');

    notifyListeners();
  }

  String degreesToMins(dynamic degrees, bool isLongitude) {
    String minsAndSecs = '';

    List<String> values = '$degrees'.split('.');
    String mins = values[1];
    mins = '0.' + mins;
    double convertedMins = double.parse(mins) * 60;
    (convertedMins < 10)?mins = '0'+convertedMins.toStringAsFixed(5):mins = convertedMins.toStringAsFixed(5);
    (isLongitude == true)?minsAndSecs = '0'+values[0] + mins:minsAndSecs = values[0] + mins;
    print(minsAndSecs);
    return minsAndSecs;
  }
}
