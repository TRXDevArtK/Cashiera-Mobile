//core & plugins
import 'package:flutter/material.dart';

//package file
import 'package:Cashiera/routes.dart';
import 'package:flutter/services.dart';

void main() {
  //force potrait
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cashiera',
      initialRoute: mainRoutes,
      routes: listRoutes,

      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
