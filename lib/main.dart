import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(App());


class App extends StatefulWidget{
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App>{

  String _currentCoordinates = "no t"; // переменная в которую заносятся текущие координаты
  Timer _timer;
  int _commonInquirySec = 5;

  void initState(){
    _getCurrentLocation();
    super.initState();
  }

  void dispose (){
    _timer.cancel();
    super.dispose();
  }

  // ф-ция запроса места нахождения
  void _getCurrentLocation() async {

    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    print(position);

    setState(() {
      _currentCoordinates = "${position.latitude}, ${position.longitude}";
    });

    _commonInquiry();
  } 

  // ф-ция описывающий работу таймера по истечении которого идет запрос текущих координат
  void _commonInquiry(){
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if(_commonInquirySec == 0){
          setState(() {
            _commonInquirySec = 5;
            _getCurrentLocation();
            _timer.cancel();
          });
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
    return MaterialApp(
      title: 'Holding Track',
      home: Scaffold(
        appBar: AppBar(
          title: Text("Location Services")
        ),
        body: Align(
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
            Text(_currentCoordinates),
            /*TextButton(
              onPressed: (){
                _getCurrentLocation();
              },
              style: TextButton.styleFrom(
                primary: Colors.white,
                backgroundColor: Colors.teal,
                onSurface: Colors.white,
              ),
              child: Text("Find Location")
            )*/
          ]),
        )
      ),
    );
  }
}