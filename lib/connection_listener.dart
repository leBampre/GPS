import 'dart:io';
import 'dart:async';

import 'package:connectivity/connectivity.dart';

// создаем класс Singleton для постоянного контроля за интернет подключением
class ConnectionStatusSingleton {
  //создаем единственный экземпляра, указав конструктором _internal  
  ConnectionStatusSingleton._internal();
  // записываем все данные о нем в переменную _singleton
  static final ConnectionStatusSingleton _singleton = new ConnectionStatusSingleton._internal();

  /* эта строка описывает переменную при помощи которой будет получаться доступ
   к синглтону*/
  static ConnectionStatusSingleton getInstance() => _singleton;

  /* подключаем пакет flutter connectivity, данные будут записываться в переменную
    _connectivity */
  final Connectivity _connectivity = Connectivity();

  // при помощи этого контроллера будут рассылаться данные о состоянии подключения
  StreamController connectionChangeController = new StreamController.broadcast();

  // инициализируем откуда контроллер будет брать данные о изменении состояния подключения
  Stream get connectionChange => connectionChangeController.stream;

  /* прописываем какие действия будут выполняться при инициализации сиглтона */
  void initialize() async{
    // в переменную result записываем текущее состояние активности подключений
    ConnectivityResult result = await _connectivity.checkConnectivity();
    // затем передаем ее в ф-цию проверки активности подключения
    _checkStatus(result);
    // и уже ее результат делаем доступным всем слушателям
    _connectivity.onConnectivityChanged.listen((result) {
      _checkStatus(result);
     });
  }

  // тест, который проверяет есть ли доступ к интернету
  void _checkStatus(ConnectivityResult result) async  {
    // переменная для описания предыдущего состоняния подключения 
    bool isOnline = false;

    /* проверка непосредственно наличия связи с интернетом, а не только
      активности определенного модуля*/
    try {
      // ожидание отклика от указанного сайта
      final result = await InternetAddress.lookup('google.com');
      // если он есть
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty){
        // интернет включен
        isOnline = true;
      } 
      // иначе
      else  {
        // интернет отсутствует
        isOnline = false;
      }
    }
    // при ошибке
    on SocketException catch(_) {
      // выдается что интернет отсутствует
      isOnline = false;
    }
    connectionChangeController.sink.add({result: isOnline});
  }

  // ф-ция описывающая закрытие потока, когда он уже не нужен
  void disposeStream() => connectionChangeController.close();
}