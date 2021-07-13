import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:holding_app/models/connection_info.dart';
import 'package:holding_app/models/serial_number.dart';
import 'package:holding_app/models/location_info.dart';
import 'package:holding_app/models/time.dart';
import 'package:holding_app/config/global.dart' as global;

import 'package:device_info_plus/device_info_plus.dart';
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

  //  метод описывающий получение и передачу serial number через провайдер
  Future<void> getSerial(BuildContext context) async {
    var deviceInfo = DeviceInfoPlugin();
    var deviceSN;
    if (Platform.isIOS == true) {
      var deviceType = await deviceInfo.iosInfo;
      deviceSN = deviceType.identifierForVendor;
    } else {
      var deviceType = await deviceInfo.androidInfo;
      deviceSN = deviceType.androidId;
    }
    deviceSN = deviceSN.toString();
    context.read<SN>().changeSN(deviceSN);
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
    dynamic newSpeed = newLocation.speed;
    dynamic newAltitude = newLocation.altitude;
    dynamic newHeading = newLocation.heading;

    context.read<LocationInfo>().changeLocationandGPSActivity(
        newLat, newLong, newSpeed, newAltitude, newHeading, newGPSStatus);
  }

  //  метод описывающий получение текущего времени
  Future<void> checkTimeAndDate(BuildContext context) async {
    //final currentTime = DateTime.now();
    dynamic hour = checkDoubleCounting(DateTime.now().hour);
    dynamic clockHour = checkDoubleCounting(DateTime.now().toUtc().hour);
    dynamic minute = checkDoubleCounting(DateTime.now().minute);
    dynamic second = checkDoubleCounting(DateTime.now().second);
    dynamic day = checkDoubleCounting(DateTime.now().toUtc().day);
    dynamic month = checkDoubleCounting(DateTime.now().month);
    dynamic year = checkDoubleCounting(DateTime.now().year);

    String cutYear = '$year';

    String clockTime = '$hour:$minute';
    String currentTime = '$clockHour$minute$second';
    String currentDate = '$day$month${cutYear.substring(2)}';

    context.read<Time>().changedTime(clockTime, currentTime, currentDate);
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

  // метод для связи с сокетом и отправки данных
  Future<void> socketConnect() async {
    String loginData = '#L#${global.serialNumber};NA\r\n';
    String phoneInfo =
        '#D#${global.date};${global.time};${global.latitude};N;${global.longitude};E;${global.speed};${global.heading};${global.altitude};7;NA;0;0;;NA;SOS:1:${global.sos}\r\n';

    String serversResponse;
    Socket socket = await Socket.connect('193.193.165.37', 26583);

    socket.add(utf8.encode(loginData));

    socket.listen((List<int> event) {
      serversResponse = utf8.decode(event);
    });

    await Future.delayed(Duration(seconds: 1));
    (serversResponse == '#AL#1\r\n')
        ? socket.add(utf8.encode(phoneInfo))
        : socket.add(utf8.encode(phoneInfo));

    (global.sos == 0)
        ? await Future.delayed(Duration(seconds: global.timerPeriod - 2))
        : await Future.delayed(Duration(seconds: 1));

    socket.close();
  }
}
