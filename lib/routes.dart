//core & plugins
import 'package:flutter/cupertino.dart';

//Import Screen
import 'package:Cashiera/screen/login.dart';
import 'package:Cashiera/screen/dashboard.dart';

var listRoutes = <String, WidgetBuilder>{
  '/': (context) => Login(),
  '/dashboard': (context) => Dashboard(),
};

var mainRoutes = "/";
