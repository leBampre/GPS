import 'package:flutter/widgets.dart';
import 'package:holding_app/config/global.dart' as global;

class SN with ChangeNotifier {
  String _serialNumber = 'no imei';

  String get currentSN => _serialNumber;

  void changeSN(String newSN) {
    _serialNumber = newSN;
    //print(_imei);
    global.serialNumber = newSN;

    notifyListeners();
  }
}
