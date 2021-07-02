import 'dart:async';
import 'dart:convert';
//import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
//import 'package:http/http.dart' as http;

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:holding_app/models/connection_info.dart';
import 'package:holding_app/models/imei.dart';
import 'package:holding_app/models/location_info.dart';
import 'package:holding_app/models/time.dart';
import 'package:imei_plugin/imei_plugin.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

class HomePageFunctions {
  //! Переменные страницы home_page.dart

  //  описание стиля кнопок нижнего бара
  final ButtonStyle bottomButtonStyle = ButtonStyle(
    textStyle: MaterialStateProperty.all<TextStyle>(
      TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        fontStyle: FontStyle.italic,
      ),
    ),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
        side: BorderSide(
          color: Colors.yellow,
          width: 1.0,
        ),
      ),
    ),
    overlayColor:
        MaterialStateProperty.all<Color>(Colors.yellow.withOpacity(0.5)),
    minimumSize: MaterialStateProperty.all<Size>(const Size(100, 80)),
    backgroundColor:
        MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
      if (states.contains(MaterialState.pressed))
        return Colors.yellow.withOpacity(0.75);
      return Colors.black.withOpacity(0.15);
    }),
    foregroundColor:
        MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
      if (states.contains(MaterialState.pressed)) return Colors.black;
      return Colors.yellow;
    }),
  );

  //  описание SOS кнопки
  final ButtonStyle sosButtonStyle = ButtonStyle(
    textStyle: MaterialStateProperty.all<TextStyle>(
      TextStyle(
        fontSize: 60,
        fontWeight: FontWeight.w900,
        fontStyle: FontStyle.italic,
      ),
    ),
    fixedSize: MaterialStateProperty.all<Size>(const Size(180, 180)),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(90),
      ),
    ),
    overlayColor: MaterialStateProperty.all<Color>(Colors.red),
    backgroundColor:
        MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
      if (states.contains(MaterialState.pressed)) return Colors.red;
      return Colors.yellow;
    }),
    foregroundColor:
        MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
      if (states.contains(MaterialState.pressed)) return Colors.white;
      return Colors.black;
    }),
  );

  //  описание стиля текста апп бара
  final TextStyle appBarText = TextStyle(
    color: Colors.yellow,
    fontSize: 36,
    fontStyle: FontStyle.italic,
  );

  //  описание стиля текста верхнего бара
  final TextStyle topBarText = TextStyle(
    color: Colors.yellow,
    fontWeight: FontWeight.w500,
    fontSize: 13,
    fontStyle: FontStyle.italic,
  );

  //  описание отступов для текста в верхнем баре
  final EdgeInsets topBarContainersPaddings = EdgeInsets.only(
    left: 15,
    bottom: 5,
  );

  //  список из значений и ключей для иконокЮ названий и пр.
  final Map statementIcons = {
    'Настройки': Icons.settings_outlined,
    'Чат': Icons.chat,
    'Карта': Icons.map_rounded,
    ConnectivityResult.wifi: Icons.wifi,
    ConnectivityResult.mobile: Icons.signal_cellular_alt_outlined,
    ConnectivityResult.none: Icons.signal_cellular_off_outlined,
    true: Icons.place,
    false: Icons.bubble_chart,
  };

  //! Методы страницы home_page.dart

  //  метод описывающий получение и передачу imei через провайдер
  Future<void> getImei(BuildContext context) async {
    final getImei = await ImeiPlugin.getImei();
    context.read<Imei>().changeImei(getImei);
  }

  //  метод описывающий тест, который проверяет есть ли доступ к интернету
  Future<void> checkStatus(BuildContext context) async {
    final Connectivity _connectivity = Connectivity();
    // инициализация переменной для описания предыдущего состоняния подключения
    bool isOnline = false;
    //полечение в переменную result значения о текущем состоянии связи(подключен вай-фай, мобильная сеть или нет подключений)
    ConnectivityResult result = await _connectivity.checkConnectivity();
    /* проверка непосредственно наличия связи с интернетом, а не только
      активности определенного модуля*/
    try {
      // ожидание отклика от указанного сайта
      final result = await InternetAddress.lookup('google.com');
      // есть он или нет, по результату выставляется значение для isOnline
      (result.isNotEmpty && result[0].rawAddress.isNotEmpty)
          ? isOnline = true
          : isOnline = false;
    }
    // при ошибке
    on SocketException catch (_) {
      // выдается что интернет отсутствует
      isOnline = false;
    }
    context.read<Connection>().changeConnectionState(result, isOnline);
  }

  //  метод описывающий получение информации о текущем местоположении
  Future<void> checkLocation(BuildContext context) async {
    final Location location = Location();
    bool newGPSStatus = false;

    newGPSStatus = await location.serviceEnabled();
    if (!newGPSStatus) {
      do {
        newGPSStatus = await location.requestService();
        print(newGPSStatus);
      } while (newGPSStatus == false);
    }
    LocationData newLocation = await location.getLocation();
    dynamic newLat = newLocation.latitude;
    dynamic newLong = newLocation.longitude;

    context
        .read<LocationInfo>()
        .changeLocationandGPSActivity(newLat, newLong, newGPSStatus);
  }

  //  метод описывающий получение текущего времени
  Future<void> checkTime(BuildContext context) async {
    //final currentTime = DateTime.now();
    dynamic hour = checkDoubleCounting(DateTime.now().hour);
    dynamic minute = checkDoubleCounting(DateTime.now().minute);
    dynamic second = checkDoubleCounting(DateTime.now().second);

    String clockTime = '$hour:$minute';
    String currentTime = '$hour$minute$second';

    context.read<Time>().changedTime(clockTime, currentTime);
  }

  /*  метод описывающий проверку является ли какая-то часть полученнного времени
   меньше 10 и добавляет 0 спереди, если да, такой формат необходим для отправки
   времени на сервер  */
  dynamic checkDoubleCounting(dynamic isItDoubleCounting) {
    (isItDoubleCounting < 10)
        ? isItDoubleCounting = '0$isItDoubleCounting'
        : isItDoubleCounting = isItDoubleCounting;
    return isItDoubleCounting;
  }

  //  метод определяющий какую иконку отображать в верхнем баре в текущий момент
  IconData topBarIcon(Map statesMap, dynamic valueToCompare) {
    IconData icon;
    for (int i = 0; i < statesMap.length; i++) {
      (statesMap.keys.toList()[i] == valueToCompare)
          ? icon = statesMap.values.toList()[i]
          : icon = icon;
    }
    return icon;
  }

  //  метод описывающий расположение и стиль иконки и текста в нижних кнопках
  Column bottomButtonTextAndIconLook(IconData icon, String label) {
    return Column(
      // описание дете Column
      children: [
        Icon(
          icon,
          size: 36,
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 5),
          child: Text(
            label,
          ),
        ),
      ],
    );
  }

  Future<void> apiRequest() async {
    String url = 'http://77.123.137.100:20332';
    String data = '#L#358240051111110;NA\r\n';
    print(data);

    HttpClient httpClient = new HttpClient();
    print(2);
    httpClient.postUrl(Uri.parse(url)).then((HttpClientRequest request) {
      print(3);
      request.write(utf8.encode(data));
      print(4);
      return request.close();
    }).then((HttpClientResponse response) {
      print(5);
      String z = response.toString();
      print(z);
    });
    print(6);
  }

  //!!!!!!!!!!!!!
/*
  Future<http.Response> httpPost(BuildContext context) async {
    //String url = 'https://json.flutter.su/echo';
    String url = 'https://77.123.137.100:20332';
/*
    Map data = {
      "host": "193.193.165.37",
      "port": "26759",
      "unitId": "358240051111110",
      "password": "111",
    };
*/
    String data = '#L#358240051111110;NA';
    print(data);
    //var body = jsonEncode(data);

    //var z = jsonDecode(body);
    //print(z);

    var sendData = await http.post(
      Uri.parse(url),
      //headers: {'Contant-type': 'application/json'},
      body: data,
    );

    print('Ну хеллоу');
    print("${sendData.statusCode}");
    log("${sendData.body}");
    return sendData;
  }

  Future<void> httpPost2(BuildContext context) async {
    //String url = 'https://json.flutter.su/echo';
    String url = 'https://77.123.137.100:20332';

    String data = '#SD#010721;142030;5355.09260;N;02732.40990;E;0;0;300;7';
    print(data);
    //var body = jsonEncode(data);

    //var z = jsonDecode(body);
    //print(z);

    var sendData = await http.post(
      Uri.parse(url),
      //headers: {'Contant-type': 'application/json'},
      body: data,
    );
    log("${sendData.body}");
  }

  Future<void> getCallback(BuildContext context) async {
    String url = 'https://77.123.137.100:20332';
    var getressponse = await http.get(Uri.parse(url));
    print(getressponse);
  }
*/
}
