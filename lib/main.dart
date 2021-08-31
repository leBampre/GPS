import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:holding_app/models/time.dart';
import 'package:holding_app/models/serial_number.dart';
import 'package:holding_app/models/connection_info.dart';
import 'package:holding_app/models/location_info.dart';

//import 'pages/sign_in.dart';
import 'pages/home_page.dart';
import 'pages/options_page.dart';
import 'pages/chat_page.dart';
import 'pages/map_page.dart';

void main() =>  runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Time>(create: (context) => Time()),
        ChangeNotifierProvider<SN>(create: (_) => SN()),
        ChangeNotifierProvider<Connection>(create: (_) => Connection()),
        ChangeNotifierProvider<LocationInfo>(create: (context) => LocationInfo()),
      ],
      child: MaterialApp(
        theme: ThemeData(primaryColor: Colors.black),
        home: HomePage(),
        routes: {
          '/options_page': (BuildContext context) => OptionsPage(),
          '/chat_page': (BuildContext context) => ChatPage(),
          '/map_page': (BuildContext context) => MapPage(),
        },
      ),
    );
  }
}
