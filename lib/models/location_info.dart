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

    global.latitude = '$newLatitude';
    global.longitude = '$newLongitude';
    //print('$_location, gps is: $_gpsIsActive');

    notifyListeners();
  }
}
