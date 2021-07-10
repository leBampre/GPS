import 'package:flutter/widgets.dart';
import 'package:holding_app/config/global.dart' as global;

class Imei with ChangeNotifier {
  String _imei = 'no imei';

  String get currentImei => _imei;

  void changeImei(String newImei) {
    _imei = newImei;
    //print(_imei);
    global.imei = newImei;

    notifyListeners();
  }
}
