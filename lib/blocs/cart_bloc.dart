//core & plugins
import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

//public data
import 'package:Cashiera/datas/public.dart';

//helper
import 'package:Cashiera/helper/db_helper.dart';
import 'package:Cashiera/helper/time_helper.dart';

class CartBloc{
  static final searchFilters = BehaviorSubject<String>.seeded("%%");
  final cartData = BehaviorSubject<List<Map<String,dynamic>>>.seeded([]);
  final enableButton = BehaviorSubject<bool>.seeded(false);

  CartBloc(){
    readSellingTemp();
  }

  Future<Map> calcCart() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "tenant.db");
    Database database = await openDatabase(path, version: 1);

    int insertSellHistory = 0;

    String sqlHeader = "SELECT";
    List sqlColumn = [
      ['SUM((st.profit+st.capital)*st.amount)','total_price'],
      ['SUM(st.amount)', 'total_product'],
    ];
    String sqlTable = "FROM selling_temp st";
    List sqlWhere = [];
    String sqlGroup = "";
    List sqlLimit = ["",""];

    List results = await sqlReadBuilder(sqlHeader, sqlColumn, sqlTable, sqlWhere, sqlGroup, sqlLimit, database, false);

    Map<String,dynamic> data = {};
    data['total_price'] = results[0]['total_price'];
    data['total_product'] = results[0]['total_product'];
    data['datetime'] = dateTimeBuilder('now', StoreData.timeZone).toString()+" ("+StoreData.timeZone+")";

    return data;
  }

  Future<Map> submitCart() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "tenant.db");
    Database database = await openDatabase(path, version: 1);

    int insertSellHistory = 0;

    await database.transaction((txn) async {

      String sqlHeader = "SELECT";
      List sqlColumn = [
        ['st.id','id'],
        ['st.datetime','datetime'],
        ['st.capital','capital'],
        ['st.profit','profit'],
        ['st.amount','amount'],
        ['st.product_id','product_id'],
        ['st.teller','teller']
      ];
      String sqlTable = "FROM selling_temp st";
      List sqlWhere = [];
      String sqlGroup = "";
      List sqlLimit = ["",""];
      List results = await sqlReadBuilder(sqlHeader, sqlColumn, sqlTable, sqlWhere, sqlGroup, sqlLimit, txn, false);

      for(int i = 0;i<results.length;i++){
        sqlHeader = "INSERT OR REPLACE INTO";
        sqlTable = "selling_history";
        List sqlInsert = [
          ['id', null],
          ['datetime', dateTimeBuilder('now', StoreData.timeZone)],
          ['capital', results[i]['capital']],
          ['profit', results[i]['profit']],
          ['report', ""],
          ['pricing_report', 0.0],
          ['amount', results[i]['amount']],
          ['product_id', results[i]['product_id']],
          ['teller', results[i]['teller']],
          ['online', 0]
        ];

        insertSellHistory = await sqlCreateBuilder(sqlHeader, sqlTable, sqlInsert, txn, false);
      }
    });
    await database.close();

    if(insertSellHistory >= 1){
      deleteAllCart(false);
      readSellingTemp();
      return {'status':true, 'notf':'Transaksi Berhasil'};
    }
    else{
      return {'status':false, 'notf':'Transaksi Gagal, silahkan coba lagi nanti'};
    }
  }

  Future<Map> deleteAllCart(bool toProduct) async{
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "tenant.db");
    Database database = await openDatabase(path, version: 1);

    int results = 0;
    await database.transaction((txn) async {

      List data = cartData.value;
      if(toProduct == true){
        for (int i = 0; i < data.length; i++) {
          String sqlHeader = "UPDATE";
          String sqlTable = "product";
          List sqlSet = [
            [data[i]['amount'], "stock = stock + ?"],
          ];
          List sqlWhere = [
            [[data[i]['product_id']], "AND product.id = ?"]
          ];

          await sqlUpdateBuilder(
              sqlHeader, sqlTable, sqlSet, sqlWhere, txn, false);
        }
      }

      //insert
      String sqlHeader = "DELETE FROM";
      String sqlTable = "selling_temp";
      List sqlWhere = [];

      results = await sqlDeleteBuilder(sqlHeader, sqlTable, sqlWhere, txn, false);
    });

    await database.close();

    if(results >= 1){
      readSellingTemp();
      return {'status':true, 'notf':'Cart di Hapus'};
    }
    else{
      return {'status':false, 'notf':'Proses gagal, mohon ulangi lagi'};
    }
  }

  Future<Map> deleteDataCart(Map data) async{
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "tenant.db");
    Database database = await openDatabase(path, version: 1);

    int results = 0;
    await database.transaction((txn) async {
      //insert
      String sqlHeader = "DELETE FROM";
      String sqlTable = "selling_temp";
      List sqlWhere = [
        [[data['id'].toString()], "AND selling_temp.id = ?"]
      ];

      await sqlDeleteBuilder(sqlHeader, sqlTable, sqlWhere, txn, false);

      sqlHeader = "UPDATE";
      sqlTable = "product";
      List sqlSet = [
        [data['amount'], "stock = stock + ?"],
      ];

      sqlWhere = [
        [[data['product_id']], "AND product.id = ?"]
      ];

      results = await sqlUpdateBuilder(sqlHeader, sqlTable, sqlSet, sqlWhere, txn, false);
    });

    await database.close();

    if(results >= 1){
      readSellingTemp();
      return {'status':true, 'notf':'Delete produk di cart berhasil'};
    }
    else{
      return {'status':false, 'notf':'Proses gagal, mohon ulangi lagi'};
    }
  }

  Future<Map> submitToCart(Map data) async{
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "tenant.db");
    Database database = await openDatabase(path, version: 1);

    int results = 0;
    //insert
    await database.transaction((txn) async {
      String sqlHeader = "UPDATE";
      String sqlTable = "selling_temp";
      List sqlSet = [
        [data['datetime'], "datetime = ?"],
        [data['capital'], "capital = ?"],
        [data['profit'], "profit = ?"],
        [data['amount'], "amount = ?"],
        [data['product_id'], "product_id = ?"],
        [data['teller'], "teller = ?"],
      ];
      List sqlWhere = [
        [[data['id'].toString()], "AND selling_temp.id = ?"]
      ];

      results = await sqlUpdateBuilder(sqlHeader, sqlTable, sqlSet, sqlWhere, txn, false);
    });

    await database.close();

    if(results >= 1){
      readSellingTemp();
      return {'status':true, 'notf':'Update produk di cart berhasil'};
    }
    else{
      return {'status':false, 'notf':'Proses gagal, mohon ulangi lagi'};
    }
  }

  bool applySearchFilters(String search){
    searchFilters.add("%"+search+"%");
    readSellingTemp();
    return true;
  }

  Future<bool> readSellingTemp() async{
    //db init
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "tenant.db");
    Database database = await openDatabase(path, version: 1);

    String search = searchFilters.value;

    var sqlHeader = "SELECT";
    var sqlColumn = [
      ['st.id', 'id'],
      ['st.product_id', 'product_id'],
      ['p.name', 'name'],
      ['p.code', 'code'],
      ['p.discount', 'discount'],
      ['p.profit_min', 'profit_min'],
      ['p.profit_max', 'profit_max'],
      ['p.stock', 'stock'],
      ['st.datetime', 'datetime'],
      ['st.capital', 'capital'],
      ['st.profit', 'profit'],
      ['st.amount', 'amount'],
      ['st.teller', 'teller']
    ];
    var sqlTable = "FROM selling_temp st LEFT JOIN product p ON st.product_id = p.id";
    var sqlWhere = [
      [[search, search, search, search], "AND p.name LIKE ? OR p.code LIKE ? OR st.amount LIKE ? OR st.datetime LIKE ?"]
    ];
    var sqlGroup = "";
    var sqlLimit = ["",""];

    List<Map<String,dynamic>> results = await sqlReadBuilder(sqlHeader, sqlColumn, sqlTable, sqlWhere, sqlGroup, sqlLimit, database, true);
    if(results.length == 0){
      enableButton.add(false);
    }
    else{
      enableButton.add(true);
    }

    cartData.add(results);
    return true;
  }

  void dispose() {
    cartData.close();
  }
}