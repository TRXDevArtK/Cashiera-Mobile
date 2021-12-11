//core & plugins
import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

//public data
import 'package:Cashiera/datas/public.dart';

//helper
import 'package:Cashiera/helper/db_helper.dart';

class DashboardBloc{
  final cartAmount = BehaviorSubject<int>.seeded(0);

  DashboardBloc(){
    readCartAmount();
  }

  Future<bool> readCartAmount() async{
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "tenant.db");
    Database database = await openDatabase(path, version: 1);

    var sqlHeader = "SELECT";
    var sqlColumn = [
      ['COUNT(st.amount)', 'amount'],
    ];
    var sqlTable = "FROM selling_temp st";
    var sqlWhere = [];
    var sqlGroup = "";
    var sqlLimit = ["",""];

    List<Map<String, dynamic>> productList = await sqlReadBuilder(sqlHeader,sqlColumn,sqlTable,sqlWhere,sqlGroup,sqlLimit,database,false);

    cartAmount.add(productList[0]['amount']);

    return true;
  }

  Future<bool> calcCartAmount(int amount, String operation) async{
    if(operation == ""){
      return false;
    }

    int calcAmt = amount;

    if(operation == 'decrease'){
      calcAmt = cartAmount.value - amount;
    }
    else if(operation == 'increase'){
      calcAmt = cartAmount.value + amount;
    }

    cartAmount.add(calcAmt);
    return true;
  }

}