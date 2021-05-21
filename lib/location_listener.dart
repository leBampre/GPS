import 'dart:async';

import 'package:location/location.dart';

class LocationSingleton {

  LocationSingleton._internal();

  static final LocationSingleton _locationSingleton = new LocationSingleton._internal();

  static LocationSingleton getInstance() => _locationSingleton;

  final Location _location = new Location();

  StreamController locationController = new StreamController.broadcast();

  Stream get locationChange => locationController.stream;


  void initializeLocation() async {
    LocationData result = await _location.getLocation();
    print(result);
    locationAndGPSActivity(result);
    _location.onLocationChanged.listen((result) {
      locationAndGPSActivity(result);
    });
  }

  void locationAndGPSActivity(LocationData currentLocation) async {
    bool _gpsIsActive = false;

    _gpsIsActive = await _location.serviceEnabled();
    print(_gpsIsActive);
    if(!_gpsIsActive){
      _gpsIsActive = await _location.requestService();
      if(!_gpsIsActive){
        return;
      }
    }

    locationController.sink.add({_gpsIsActive: currentLocation});
  }

  void disposeLocationStream() => locationController.close();
}