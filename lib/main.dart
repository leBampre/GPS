import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

//запуск приложения
void main() => runApp(App());


class App extends StatefulWidget{
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App>{

  // описание переменных
  String _currentCoordinates = "no coordinates";  // переменная в которую заносятся текущие координаты
  Timer _timer; // инициализация таймера
  int _commonInquirySec = 5;  // переменная описывающая длительность цикла таймера

  // метод вызываемый при запуске приложения
  void initState(){
    _getCurrentLocation();  
    super.initState();
  }

  // метод вызывается при закрытии страницы
  void dispose (){
    _timer.cancel();
    super.dispose();
  }

  // ф-ция определения текущего местоположения
  void _getCurrentLocation() async {

    // записываем в переменную position текущую широту и долготу обьекта с указанной точностью
    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    
    // для дебага, контроль позиции в терминале
    print(position);

    // записываем в string переменную _currentCoordinates координаты, для дальнейшего вывода
    setState(() {
      _currentCoordinates = "${position.latitude}, ${position.longitude}";
    });

    // запуск стандартного такта таймера
    _commonInquiry();
  } 

  // ф-ция описывающий работу таймера по истечении которого идет запрос текущих координат
  void _commonInquiry(){

    // инициализация переменной, описывающей единицу времени для таймера 
    const oneSec = const Duration(seconds: 1);
    
    // создаем конкретный обьект таймера и задаем параметры его работы
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        // условие выполняемое таймером когда он досчитал до нуля
        if(_commonInquirySec == 0){
          setState(() {
            _commonInquirySec = 5;
            _getCurrentLocation();
            _timer.cancel();
          });
        // условие если таймер все еще считает
        } else {
            setState(() {
              _commonInquirySec--;
              print(_commonInquirySec);
            });
        }
      }
    );    
  }



  //This widget is the root of the app
  @override
  Widget build(BuildContext context){

    // виджет описывающий апп бар
    Widget appBar = Container(

    );


    // инициализируем значение цвета для иконок
    Color iconsColor = Colors.yellow;


    /* виджет описывающий ряд в котором будут выводиться текущее
      местополодение и иконки описывающие состояние различных
      типов подключения (к сети, вай фай, GPS) */
    Widget coordinatesAndSatusIcons = Container(
      // заданные отступы внутри контейнера
      padding: EdgeInsets.only(bottom: 5,),
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
                  padding: EdgeInsets.only(left: 15, top: 5, ),
                  child: Text(_currentCoordinates,
                   style: TextStyle(
                     color: Colors.yellow,
                     fontWeight: FontWeight.w500,
                     fontSize: 18,
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
              _iconContainer(iconsColor, Icons.network_wifi),
              _iconContainer(iconsColor, Icons.network_cell),
              _iconContainer(iconsColor, Icons.place),
            ],
          ),
        ],
      ),
    );

    // виджет с тревожной кнопкой
    Widget alarmButton = Container(
      child: Column(

      ),
    );

    // виджет описывабщий нижний ряд кнопок
    Widget bottomButtons = Container(
      child: Row(
        children: [
          Expanded(
            child: _buildButtonIconColumn(iconsColor, Icons.network_wifi),
          ),
        ],
      ),
    );


    // возвращаее прописанные в нем параметры, т.е. то что нужно вывести на экран
    return MaterialApp(
      title: 'Holding Track',
      home: Scaffold(
        appBar: AppBar(
          title: appBar,
        ),
        body: ListView(
          children: [
            coordinatesAndSatusIcons,
            alarmButton,
            bottomButtons,
          ],
        ),
      ),
    );
  }



  /* контейнер в котором описывается стандарт отображения иконок
     в верхней части экрана, в контейнер передаются значения цвета иконок и
     информация какую именно иконку отображать  */
  Container _iconContainer(Color color, IconData icon){
    // после вызова возвращает контейнер с прописанными ниже характеристиками
    return Container(
      padding: EdgeInsets.only(right: 5),
      child: Icon(icon, color: color,
      ),      
    );
  }



  Column _buildButtonIconColumn(Color color, IconData icon){
    return Column(
      
    );
  }

}