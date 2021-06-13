import 'package:flutter/widgets.dart';

class LocationInfo with ChangeNotifier {
  dynamic _location;
  dynamic _gpsIsActive = false;

  dynamic get getLocation => _location;
  dynamic get getGPSState => _gpsIsActive;

  void changeLocationandGPSActivity(newLatitude,newLongitude,newGPSStatus) {
    _location = 'lat: $newLatitude, long: $newLongitude';
    _gpsIsActive = newGPSStatus;

    print('$_location, gps is: $_gpsIsActive');

    notifyListeners();
  }
}
