//core & plugins
import 'dart:async';
import 'dart:convert';
import 'package:rxdart/rxdart.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

//public data
import 'package:Cashiera/datas/public.dart';

//helper
import 'package:Cashiera/helper/db_helper.dart';

class CartHistoryBloc{
  final cartHistoryData = BehaviorSubject<List<Map<String,dynamic>>>.seeded([]);
  static final dateFilters = BehaviorSubject<String>.seeded(DateFormat("yyyy-MM-dd").format(DateTime.now()).toString());
  static final searchFilters = BehaviorSubject<String>.seeded("");

  static final enableButton = BehaviorSubject<bool>.seeded(false);
  static final countOffline = BehaviorSubject<int>.seeded(0);
  static final notfButton = BehaviorSubject<String>.seeded("Upload Data");
  static final loading = BehaviorSubject<bool>.seeded(false);

  final dataCheckNotf = CombineLatestStream.list([enableButton, countOffline, notfButton, loading]).map((event) => {
    'enableButton':event[0],
    'countOffline':event[1],
    'notfButton':event[2],
    'loading':event[3]
  });

  CartHistoryBloc(){
    readSellingHistory();
  }

  void applyDateFilters(String value) async{
    dateFilters.add(value);
    await readSellingHistory();
  }

  void applySearchFilters(String value) async{
    searchFilters.add(value);
    await readSellingHistory();
  }

  Future<bool> submitOnline() async{
    loading.add(true);
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "tenant.db");
    Database database = await openDatabase(path, version: 1);

    String datetime = dateFilters.value+"%";

    var sqlHeader = "SELECT";
    var sqlColumn = [
      ['sh.id', 'id'],
      ['sh.product_id', 'product_id'],
      ['p.name', 'name'],
      ['p.code', 'code'],
      ['p.discount', 'discount'],
      ['p.profit_min', 'profit_min'],
      ['p.profit_max', 'profit_max'],
      ['sh.datetime', 'datetime'],
      ['sh.capital', 'capital'],
      ['sh.profit', 'profit'],
      ['sh.report', 'report'],
      ['sh.pricing_report', 'pricing_report'],
      ['sh.amount', 'amount'],
      ['sh.teller', 'teller'],
      ['sh.online', 'online']
    ];
    var sqlTable = "FROM selling_history sh LEFT JOIN product p ON sh.product_id = p.id";
    var sqlWhere = [
      [[datetime], "AND sh.datetime like ?"],
      [[0], "AND online = ?"]
    ];
    var sqlGroup = "";
    var sqlLimit = ["",""];

    List<Map<String,dynamic>> results = await sqlReadBuilder(sqlHeader, sqlColumn, sqlTable, sqlWhere, sqlGroup, sqlLimit, database, false);

    if(results.length == 0){
      return false;
    }

    var terms = "create_selling_history";
    var data = {
      'terms':terms,
      'db_name':DbData.name,
      'db_hostname':DbData.hostname,
      'db_username':DbData.username,
      'db_password':DbData.password,
      'timezone':StoreData.timeZone,
      'data':jsonEncode(results)
    };

    var uploadResults = await httpBuilder(DbData.serviceUrl, data);
    if(uploadResults['status'] == false){
      await database.close();
      loading.add(false);
      notfButton.add("Upload Gagal");
      return false;
    }
    else if(uploadResults['status'] == true){
      int checkOnline = 0;
      for(int i = 0;i<results.length;i++){
        sqlHeader = "UPDATE";
        sqlTable = "selling_history";
        List sqlSet = [
          [1, "online = ?"],
        ];
        sqlWhere = [
          [[results[i]['id']], "AND id = ?"]
        ];

        checkOnline = await sqlUpdateBuilder(sqlHeader, sqlTable, sqlSet, sqlWhere, database, false);
      }

      checkOnline = 1;

      await database.close();

      if(checkOnline >= 1){
        loading.add(false);
        readSellingHistory();
        return true;
      }
      else{
        return false;
      }
    }
    else{
      loading.add(false);
      readSellingHistory();
      return false;
    }
  }

  Future<Map> submitReport(Map data) async{
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "tenant.db");
    Database database = await openDatabase(path, version: 1);

    String sqlHeader = "UPDATE";
    String sqlTable = "selling_history";
    List sqlSet = [
      [data['report'], "report = ?"],
      [data['pricing_report'], "pricing_report = ?"]
    ];
    List sqlWhere = [
      [[data['id']], "AND id = ?"]
    ];

    int results = await sqlUpdateBuilder(sqlHeader, sqlTable, sqlSet, sqlWhere, database, true);

    if(results >= 1){
      readSellingHistory();
      return {'status':true, 'notf':'Laporan berhasil di tambahkan'};
    }
    else{
      return {'status':false, 'notf':'Proses gagal, mohon ulangi lagi'};
    }
  }

  Future<bool> readSellingHistory() async{
    //db init
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "tenant.db");
    Database database = await openDatabase(path, version: 1);

    String search = "%"+searchFilters.value+"%";
    String datetime = dateFilters.value+"%";

    List<Map<String,dynamic>> results = [];
    List<Map<String,dynamic>> countOnlineHistory = [];

    await database.transaction((txn) async {
      var sqlHeader = "SELECT";
      var sqlColumn = [
        ['sh.id', 'id'],
        ['sh.product_id', 'product_id'],
        ['p.name', 'name'],
        ['p.code', 'code'],
        ['p.discount', 'discount'],
        ['p.profit_min', 'profit_min'],
        ['p.profit_max', 'profit_max'],
        ['sh.datetime', 'datetime'],
        ['sh.capital', 'capital'],
        ['sh.profit', 'profit'],
        ['sh.report', 'report'],
        ['sh.pricing_report', 'pricing_report'],
        ['sh.amount', 'amount'],
        ['sh.teller', 'teller'],
        ['sh.online', 'online']
      ];
      var sqlTable = "FROM selling_history sh LEFT JOIN product p ON sh.product_id = p.id";
      var sqlWhere = [
        [[search, search, search], "AND (p.name LIKE ? OR p.code LIKE ? OR sh.amount LIKE ?)"],
        [[datetime], "AND sh.datetime like ?"]
      ];
      var sqlGroup = "";
      var sqlLimit = ["",""];

      results = await sqlReadBuilder(sqlHeader, sqlColumn, sqlTable, sqlWhere, sqlGroup, sqlLimit, txn, false);

      sqlHeader = "SELECT";
      sqlColumn = [
        ['COUNT(sh.online)', 'offline'],
      ];
      sqlTable = "FROM selling_history sh";
      sqlWhere = [
        [[0], "AND sh.online = ?"],
        [[datetime], "AND sh.datetime like ?"]
      ];
      sqlGroup = "";
      sqlLimit = ["",""];

      countOnlineHistory = await sqlReadBuilder(sqlHeader, sqlColumn, sqlTable, sqlWhere, sqlGroup, sqlLimit, txn, false);
    });
    await database.close();

    if(countOnlineHistory[0]['offline'] == 0){
      loading.add(false);
      notfButton.add("Semua Online");
    }
    else{
      notfButton.add("Upload Data");
    }

    countOffline.add(countOnlineHistory[0]['offline']);

    if(results.length == 0){
      enableButton.add(false);
    }
    else{
      enableButton.add(true);
    }

    cartHistoryData.add(results);
    return true;
  }

  void dispose() {
    dateFilters.close();
    enableButton.close();
    searchFilters.close();
    cartHistoryData.close();
    loading.close();
  }
}