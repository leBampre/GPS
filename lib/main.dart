import 'dart:async';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:imei_plugin/imei_plugin.dart';
//import 'package:http/http.dart' as http;

import 'package:holding_app/connection_listener.dart';
import 'package:holding_app/location_listener.dart';

//запуск приложения
void main() => runApp(App());

// инициализируем класс App на основе StatefulWidget
class App extends StatefulWidget {
  @override
  // создает изменяемое состояние для этого виджета в заданном месте дерева.
  _AppState createState() => _AppState();
}

/* переопределить этот метод для подкласса,
  чтобы вернуть вновь созданный экземпляр их связанного подкласса */
class _AppState extends State<App> {

  /* создаем коллекцию для состояний модулей мобильной связи и wifi для 
    их дальнейшего удобного использования*/
  Map _currentStates = {ConnectivityResult.none: false};
  // коллекция, храняшая в себе названия необходимых иконок для отображения
  Map statementIcons = {
    ConnectivityResult.wifi: Icons.wifi,
    ConnectivityResult.mobile: Icons.signal_cellular_alt_outlined,
    ConnectivityResult.none: Icons.signal_cellular_off_outlined,
    true: Icons.place,
    false: Icons.bubble_chart,
  };
  Map _gpsIsActive = {false: null};

  // инициализируем переменную для взаимодействия с синглтоном ConnectionStatusSingleton
  ConnectionStatusSingleton _connectionStatus =
      ConnectionStatusSingleton.getInstance();
  
  LocationSingleton _locationStatus = 
      LocationSingleton.getInstance();
  

  // инициализиация значение цвета для иконок
  Color iconsColor = Colors.yellowAccent[700];

  // описание переменных
  //String _currentCoordinates =
  //    "no coordinates"; // переменная в которую заносятся текущие координаты
  String _deviceIMEI =
      "no IMEI"; // переменная в которую заносится данные о imei устройства

  Timer _timer; // инициализация таймера
 // int _commonInquirySec = 5; // переменная описывающая длительность цикла таймера

  // метод вызываемый при запуске этого подкласса в приложении
  @override
  void initState() {
    super.initState();

    // вызов метода initialize() синглтона
    _connectionStatus.initialize();
    // инициализация процесса слежения за состоянием интернета и подключений
    _connectionStatus.connectionChange.listen((source) {
      // указание в какую переменную записываеть происходящие изменения
      setState(() => _currentStates = source);
    });


    _locationStatus.initializeLocation();

    _locationStatus.locationChange.listen((event) {
      setState(() => _gpsIsActive = event);
    });


    // запуск метода определения текущего местоположения
  //  _getCurrentLocation();

    // запуск метода определения imei устройства
    _getDeviceImei();
  }

  // метод вызывается при завершении этого подкласса в приложении
  void dispose() {
    // завершение потока опроса модулей на подключению к интернету
    _connectionStatus.disposeStream();
    _locationStatus.disposeLocationStream();

    // отключение таймера
    _timer.cancel();

    super.dispose();
  }

  // ф-ция получения имей устройства
  void _getDeviceImei() async {
    // в переменную imei заносятся полученные от плагина ImeiPlugin данные о IMEI усьройства
    final imei = await ImeiPlugin.getImei();
    // в переменную _deviceIMEI заносятся данные из переменной imei
    setState(() {
      _deviceIMEI = "$imei";
    });
    // временный вывод переменной в консоль для дебага
    print(_deviceIMEI);
  }
/*
  // ф-ция определения текущего местоположения
  void _getCurrentLocation() async {
    // проверка, включен ли GPS, затем записываем в string активен ли он (краткая форма записа if-else)
    (await Geolocator.isLocationServiceEnabled() == true)
        ? setState(() {
            _gpsIsActive[0] = 'GPS is active';
          })
        : setState(() {
            _gpsIsActive[0] = 'GPS is inactive';
          });

    // записываем в переменную position текущую широту и долготу обьекта с указанной точностью
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // для дебага, контроль позиции в терминале
    print(position);

    // записываем в string переменную _currentCoordinates координаты, для дальнейшего вывода
    setState(() {
      _currentCoordinates = "${position.latitude}  ${position.longitude}";
    });

    // запуск стандартного такта таймера
    _commonInquiry();
  }

  // ф-ция описывающий работу таймера по истечении которого идет запрос текущих координат
  void _commonInquiry() {
    // инициализация переменной, описывающей единицу времени для таймера
    const oneSec = const Duration(seconds: 1);

    // создаем конкретный обьект таймера и задаем параметры его работы
    _timer = new Timer.periodic(oneSec, (Timer timer) {
      // условие выполняемое таймером когда он досчитал до нуля
      if (_commonInquirySec == 0) {
        setState(() {
          // возврат исходного состояния таймера
          _commonInquirySec = 5;
          // запуск определения текущего положения
          _getCurrentLocation();
          // отключение текущего таймера, чтоб не возникло утечки памяти
          _timer.cancel();
        });
        // условие если таймер все еще считает
      } else {
        setState(() {
          // декремент таймера на 1сек
          _commonInquirySec--;
          // для отладки
          print(_commonInquirySec);
        });
      }
    });
  }
*/
  //This widget is the root of the app
  @override
  Widget build(BuildContext context) {
    // виджет описывающий апп бар
    Widget appBar = Container(
      // выводится имей, для дебага
      child: Text(
        'phone ID: $_deviceIMEI',
        style: TextStyle(
          color: Colors.yellow,
          fontSize: 16,
        ),
      ),
    );

    /* виджет описывающий ряд в котором будут выводиться текущее
      местополодение и иконки описывающие состояние различных
      типов подключения (к сети, вай фай, GPS) */
    Widget coordinatesAndSatusIcons = Container(
      // заданные отступы внутри контейнера
      padding: EdgeInsets.only(
        bottom: 5,
      ),
      //цвет бэкграунда
      color: Colors.black,
      // инициализируем внутри контейнера наследника Row
      child: Row(
        // описываем детей Row
        children: [
          /* помещение столбца в Expanded виджет, который растягивает столбец,
           чтобы использовать все оставшееся свободное место в строке */
          Expanded(
            // описываем первого ребенка Row - Column
            child: Column(
              // задаем расположение детей внутри Column
              crossAxisAlignment: CrossAxisAlignment.start,
              // описываем детей Column
              children: [
                Container(
                  padding: EdgeInsets.only(
                    left: 15,
                    top: 5,
                  ),
                  child: Text(
                    _currentCoordinates(_gpsIsActive),
                    style: TextStyle(
                      color: Colors.yellow,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // описываем 2го ребенка Row - Row с иконками
          Row(
            /* описываем детей Row вызывая для каждого созданный стандартизированый
              метод для описания контейнера с иконками, передавая в них данные о 
              желаемом цвете иконки и ее озображении */
            children: [
              _iconContainer(
                  iconsColor, _currentStates, statementIcons),
              _iconContainer(
                  iconsColor, _gpsIsActive, statementIcons),
            ],
          ),
        ],
      ),
    );

    // виджет с тревожной кнопкой
    Widget alarmButton = Container(
      // для дебага выводится текст о состояния интернет подключения
      child: Column(
        children: [
          Text(test(),style: TextStyle(color: Colors.yellow),),
          Text(testGPS(),style: TextStyle(color: Colors.yellow),),
          Expanded(
            child: Container(),
          ),
          _alarmButtonContainer(),
        ],
      ),
    );

    // виджет описывабщий нижний ряд кнопок
    Widget bottomButtons = Container(
      //описание внутренних отступов контейнера
      padding: EdgeInsetsDirectional.only(top: 10, bottom: 10),
      child: Row(
        // описание позиционирования внутри ряда Row
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        // инициализация кнопок с необходимыми вводными данными
        children: [
          _bottomMenuButton(iconsColor, Icons.settings_outlined, 'OPTIONS'),
          _bottomMenuButton(iconsColor, Icons.chat, 'CHAT'),
          _bottomMenuButton(iconsColor, Icons.map_rounded, 'MAP'),
        ],
      ),
    );

    // возвращает прописанные в нем параметры, т.е. то что нужно вывести на экран
    return MaterialApp(
      title: 'Holding Track',
      home: Scaffold(
        appBar: AppBar(
          title: appBar,
          backgroundColor: Colors.black,
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('image/fon.jpg'),
              fit: BoxFit.fill),
          ),
          child:Column(
            children: [
              coordinatesAndSatusIcons,
              /*центральная часть растягивается чтобы занять все незанятое другими
                виджетами пространство*/
              Expanded(child: alarmButton),
              bottomButtons,
            ],
          ),
        ),
      ),
    );
  }

  // иконки верхнего бара
  Container _iconContainer(Color color, Map _switchMap, Map _caseMap) {
    IconData icon;
        for (int i = 0; i < _caseMap.length; i++) {
          (_switchMap.keys.toList()[0] == _caseMap.keys.toList()[i])
              ? icon = _caseMap.values.toList()[i]
              : icon = icon;
        }
        print(_switchMap.keys.toList()[0]);
    // после вызова возвращает контейнер с прописанными ниже характеристиками
    return Container(
      padding: EdgeInsets.only(right: 5),
      child: Icon(
        icon,
        color: color,
      ),
    );
  }

  String _currentCoordinates(Map _coordinates){
    final coordinates = _coordinates.values.toList()[0];
    String currentCoordinates = '$coordinates';
    return currentCoordinates;
  }

  /* !!!!ДОРАБОТАТЬ!!! --> чтобы внутрь передавалась инфа о странице на которую нужно перейти
      ф-ция описывающая кнопку нижнего бара, в нее передаются все необходимые
      данные для инициализации и работы кнопки*/
  ElevatedButton _bottomMenuButton(Color color, IconData icon, String label) {
    return ElevatedButton(
      // описывается стиль кнопки
      style: ButtonStyle(
        // минимальный размер кнопки
        minimumSize: MaterialStateProperty.all<Size>(const Size(100, 75)),
        // описание фона кнопки в зависимости от состояния
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
          // если нажата
          if (states.contains(MaterialState.pressed))
            return color.withOpacity(0.75);
          // и если не нажата
          return Colors.black.withOpacity(0.15);
        }),
        // описание цвета наполнения кнопки (текст, иконки), в зависимости от состояния
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
          // если нажата
          if (states.contains(MaterialState.pressed)) return Colors.black;
          // и если не нажата
          return color; // Defer to the widget's default.
        }),
      ),
      // описание для наследников кнопки
      child: Column(
        // описание дете Column
        children: [
          Icon(
            icon,
          ),
          Container(
            padding: EdgeInsetsDirectional.only(
              top: 5,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      onPressed: () {},
    );
  }

  /* метод для текстового выведения данных о наличии связи с интернетом
     !!!!ДЛЯ ДЕБАГА!!! */
  String test() {
    String string;
    switch (_currentStates.keys.toList()[0]) {
      case ConnectivityResult.none:
        string = "Offline";
        break;
      case ConnectivityResult.mobile:
        string = "Mobile: Online";
        break;
      case ConnectivityResult.wifi:
        string = "WiFi: Online";
    }
    return string;
  }

  String testGPS(){
    String string;
    switch (_gpsIsActive.keys.toList()[0]) {
    case true:
      string = "true";
      break;
    case false:
      string = "false";
      break;
    }
    return string;
  }


  Container _alarmButtonContainer() {
    return Container(
      child: Container(
        margin: EdgeInsetsDirectional.only(bottom:40),
        //color: Colors.blue,
        child: InkWell(
          borderRadius: BorderRadius.circular(75),
          overlayColor: MaterialStateProperty.all(Colors.red[700]),
          highlightColor: Colors.red[700],
          enableFeedback: true,
          onLongPress: () {
            setState(() {

            });
          },
          child: SizedBox(
            width: 150,
            height: 150,
            child:Container(
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),          
              padding: EdgeInsetsDirectional.only(top:35,bottom:45),
              child: Text(
                "SOS",
                style: TextStyle(
                  color: Colors.yellow,
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
