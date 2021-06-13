/*
  httpGet () async {
    var response = await http.get(Uri.parse('https://json.flutter.su/echo'));
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");
  }

  httpPost () async {
    String z = _currentCoordinates(_gpsIsActive);
    var response = await http.post(Uri.parse('https://json.flutter.su/echo'), body: {'imei':'$_deviceIMEI','location':'$z',});
    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");
  }
*/