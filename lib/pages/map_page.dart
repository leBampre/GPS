import 'package:flutter/material.dart';
import 'package:holding_app/functions/home_page_functions_and_variables.dart';


class MapPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.black,
            appBar: new AppBar(
        iconTheme: IconThemeData(
          color: Colors.yellow
        ),
        title: new Text(
          'Карта',
          style: TextStyle(
            color: Colors.yellow
          ),
        )
      ),
      body: Center(
        child: ElevatedButton(
          style: HomePageFunctions().bottomButtonStyle,
          child: new Text('Назад'),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }
}