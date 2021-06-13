import 'package:flutter/widgets.dart';
import 'package:connectivity/connectivity.dart';

class Connection with ChangeNotifier {
  dynamic _connectionState = ConnectivityResult.none;
  dynamic _internetAvailiability = false;

  dynamic get getConnectionState => _connectionState;
  dynamic get getInternetActivity => _internetAvailiability;


  void changeConnectionState(newConnectionState, newInternetActivity) {
    _connectionState = newConnectionState;
    _internetAvailiability = newInternetActivity;

    print('$_connectionState, $_internetAvailiability');
    
    notifyListeners();
  }
}