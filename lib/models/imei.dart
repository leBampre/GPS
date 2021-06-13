import 'package:flutter/widgets.dart';

class Imei with ChangeNotifier {
  String _imei = 'no imei';

  String get currentImei => _imei;
  void changeImei(String newImei) {
    _imei = newImei;
    print(_imei);

    notifyListeners();
  }
}