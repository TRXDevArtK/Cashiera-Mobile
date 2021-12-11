//core & plugins
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:intl/intl.dart';

//public data
import 'package:Cashiera/datas/public.dart';

Future<String> datePickerBuilder(context) async{
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  DateTime? date = await showDatePicker(
    context: context,
    initialDate: dateFormat.parse(dateTimeBuilder('now', StoreData.timeZone)),
    firstDate: DateTime(2000),
    lastDate: DateTime(2050),
  );

  if(date.toString() == 'null'){
    date = dateFormat.parse(dateTimeBuilder('now', StoreData.timeZone));
  }

  String results = DateFormat("yyyy-MM-dd").format(date!);

  return results;
}

String dateTimeBuilder(String condi, String timezone, [String format = "yyyy-MM-dd HH:mm:ss"]){
  tz.initializeTimeZones();
  DateFormat dateFormat = DateFormat(format);
  if(condi == 'now'){
    if(timezone == 'UTC' || timezone == 'utc'){
      return dateFormat.format(DateTime.now().toUtc()).toString();
    }

    var locations = tz.getLocation(timezone);
    var settime = tz.TZDateTime.now(locations);
    return dateFormat.format(settime).toString();
  }
  else{
    return "";
  }
}