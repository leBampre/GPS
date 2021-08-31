import 'dart:async';
import 'package:flutter/material.dart';
import 'package:holding_app/models/serial_number.dart';
import 'package:provider/provider.dart';

import 'package:holding_app/models/time.dart';
import 'package:holding_app/models/location_info.dart';
import 'package:holding_app/models/connection_info.dart';
import 'package:holding_app/config/global.dart' as global;

import 'package:holding_app/functions/home_page_functions_and_variables.dart';

// класс описывающий домашнюю страницу
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: AppBarData(),
      ),
      body: HomePageBody(),
    );
  }
}

//  виджет для описания аппбара
class AppBarData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      child: Consumer<Time>(
        builder: (context, time, child) {
          return Text(
            '${context.watch<Time>().timeForClock}',
            style: HomePageFunctions().appBarText,
            textAlign: TextAlign.center,
          );
        },
      ),
    );
  }
}

/* виджет для описания части экрана с основным контентом
    на главной странице */
class HomePageBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Expanded(child: CoordinatesAndSatusIconsAndAlarmButton()),
          BottomButtons(),
        ],
      ),
    );
  }
}

// виджет описывающий индикационные иконки и тревожную кнопку
class CoordinatesAndSatusIconsAndAlarmButton extends StatefulWidget {
  @override
  _CoordinatesAndSatusIconsAndAlarmButton createState() =>
      _CoordinatesAndSatusIconsAndAlarmButton();
}

class _CoordinatesAndSatusIconsAndAlarmButton extends State<CoordinatesAndSatusIconsAndAlarmButton> {
  // коллекция, храняшая в себе названия необходимых иконок для отображения
  Map statementIcons = HomePageFunctions().statementIcons;

  Timer checkingPeriod;
  int commonPeriod = global.timerPeriod;
  static const oneSec = const Duration(seconds: 1);

  void initState() {
    super.initState();
    HomePageFunctions().getSerial(context);
    checkingTimer();
  }

  void dispose() {
    super.dispose();
  }

  void checkingTimer() {
    // создаем конкретный обьект таймера и задаем параметры его работы
    checkingPeriod = new Timer.periodic(oneSec, (Timer timer) {
      if (commonPeriod == global.timerPeriod) {
        HomePageFunctions().checkLocation(context);
        HomePageFunctions().checkStatus(context);
        HomePageFunctions().checkTimeAndDate(context);
        HomePageFunctions().socketConnect();
        commonPeriod--;
      } else if (commonPeriod == 0) {
        setState(() {
          commonPeriod = global.timerPeriod;
          checkingTimer();
          checkingPeriod.cancel();
        });
      } else {
        setState(() {
          commonPeriod--;
//          print(commonPeriod);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          // инициализируем внутри контейнера наследника Row
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      padding: HomePageFunctions().topBarContainersPaddings,
                      child: Consumer<LocationInfo>(
                          builder: (context, connection, child) {
                        return Text(
                          '${context.watch<LocationInfo>().getLocation}',
                          style: HomePageFunctions().topBarText,
                        );
                      }),
                    ),
                    Container(
                      padding: HomePageFunctions().topBarContainersPaddings,
                      child: Consumer<SN>(builder: (context, imei, child) {
                        return Text(
                          '${context.watch<SN>().currentSN}',
                          style: HomePageFunctions().topBarText,
                        );
                      }),
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
                  Container(
                    child:
                        Consumer<Connection>(builder: (context, connection, child) {
                      return Icon(
                        HomePageFunctions().topBarIcon(statementIcons,
                            context.watch<Connection>().getConnectionState),
                        color: Colors.yellow,
                      );
                    }),
                  ),
                  Container(
                    child:
                        Consumer<LocationInfo>(builder: (context, location, child) {
                      return Icon(
                        HomePageFunctions().topBarIcon(statementIcons,
                            context.watch<LocationInfo>().getGPSState),
                        color: Colors.yellow,
                      );
                    }),
                  ),
                  // _iconContainer(iconsColor, _gpsIsActive, statementIcons),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: Container()),
              Container(
                padding: EdgeInsets.only(bottom: 25),
                child: ElevatedButton(
                  style: HomePageFunctions().sosButtonStyle,
                  child: Text(
                    'SOS',
                  ),
                  onPressed: () {
                  },
                    onLongPress: () {
                    global.sos = 1;
                    HomePageFunctions().socketConnect();
                    global.sos = 0;
                  },
                ),
              ),
            ],
          )),
      ],
    );
  }
}

// виджет описывабщий нижний ряд кнопок
class BottomButtons extends StatelessWidget {
  final Map iconsHub = HomePageFunctions().statementIcons;

  @override
  Widget build(BuildContext context) {
    _bottomMenuButton(IconData icon, String label, String route) {
      return ElevatedButton(
        style: HomePageFunctions().bottomButtonStyle,
        child: HomePageFunctions().bottomButtonTextAndIconLook(icon, label),
        onPressed: () {
          Navigator.pushNamed(context, route);
        },
      );
    }

    return Container(
      //описание внутренних отступов контейнера
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Row(
        // описание позиционирования внутри ряда Row
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        // инициализация кнопок с необходимыми вводными данными
        children: [
          _bottomMenuButton(iconsHub.values.toList()[0],
              iconsHub.keys.toList()[0], '/options_page'),
          _bottomMenuButton(iconsHub.values.toList()[1],
              iconsHub.keys.toList()[1], '/chat_page'),
          _bottomMenuButton(iconsHub.values.toList()[2],
              iconsHub.keys.toList()[2], '/map_page'),
        ],
      ),
    );
  }
}
