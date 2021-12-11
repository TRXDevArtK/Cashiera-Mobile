//core & plugins
import 'dart:async';
import 'dart:core';
import 'package:rxdart/rxdart.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

//public data
import 'package:Cashiera/datas/public.dart';

//helper
import 'package:Cashiera/helper/db_helper.dart';

class ProductBloc{
  static final searchFilters = BehaviorSubject<String>.seeded("");
  static final typeFiltersIndex = BehaviorSubject<int>.seeded(0);

  static final typeData = BehaviorSubject<List<Map<dynamic,dynamic>>>.seeded([]);//seems unused
  static final typeDataName = BehaviorSubject<List>.seeded([]);
  static final typeDataIndex = BehaviorSubject<int>.seeded(1);

  final typeDataCarousel = CombineLatestStream.list([typeDataName, typeFiltersIndex]).map((event) => {
    'data-name':event[0],
    'data-index':event[1]
  });

  //public data, must be set the initializer
  final productData = BehaviorSubject<List<Map<dynamic,dynamic>>>.seeded([]);

  ProductBloc(){
    readTypeList();
    searchProductData();
  }

  Future<Map> submitToCart(Map data) async{
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "tenant.db");
    Database database = await openDatabase(path, version: 1);

    int productDecr = (data['stock'] - int.parse(data['amount']));
    int results = 0;

    await database.transaction((txn) async {
      //insert
      String sqlHeader = "INSERT INTO";
      String sqlTable = "selling_temp";

      List sqlInsert = [
        ["id", null],
        ["datetime", data['datetime']],
        ["capital", data['capital']],
        ["profit", data['profit']],
        ["amount", data['amount']],
        ["product_id", data['id']],
        ["teller", UserData.id],
      ];

      await sqlCreateBuilder(sqlHeader, sqlTable, sqlInsert, txn, false);

      sqlHeader = "UPDATE";
      sqlTable = "product";
      List sqlSet = [
        [productDecr, "stock = ?"],
      ];

      List sqlWhere = [
        [[data['id']], "AND product.id = ?"]
      ];

      results = await sqlUpdateBuilder(sqlHeader, sqlTable, sqlSet, sqlWhere, txn, false);
    });
    await database.close();

    if(results >= 1){
      await searchProductData();
      return {'status':true, 'notf':'Proses berhasil, silahkan cek produk di cart'};
    }
    else{
      return {'status':false, 'notf':'Proses gagal, mohon ulangi lagi'};
    }
  }

  void applyType(int type){
    typeFiltersIndex.add(type);
    typeDataIndex.add(typeData.value[type]['id']);
    searchProductData();
  }

  Future<bool> searchProductData() async{
    String search = "";

    searchFilters.listen((value) {
      search = "%"+value+"%";
    });

    if(searchFilters.value.toString() == ""){
      productData.add([]);
      return false;
    }

    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "tenant.db");
    Database database = await openDatabase(path, version: 1);

    var sqlHeader = "SELECT";
    var sqlColumn = [
      ['p.id', 'id'],
      ['p.code', 'code'],
      ['p.name', 'name'],
      ['p.category', 'category'],
      ['p.brand', 'brand'],
      ['p.desc', 'desc'],
      ['p.type', 'type'],
      ['p.stock', 'stock'],
      ['p.id_store', 'id_store'],
      ['p.capital', 'capital'],
      ['p.profit_min', 'profit_min'],
      ['p.profit_max', 'profit_max'],
      ['p.discount', 'discount'],
      ['p.weight', 'weight'],
      ['p.bundling', 'bundling'],
      ['p.stats', 'stats'],
      ['p.inputter', 'inputter'],
      ['p.receipt', 'receipt'],
      ['p.latest_data', 'latest_data'],
      ['p.image_url', 'image_url']
    ];
    var sqlTable = "FROM product p LEFT JOIN id_store ids ON p.id_store = ids.id";
    var sqlWhere = [
      [[search, search, search, search],"AND (p.name LIKE ? OR p.code LIKE ? OR ids.name LIKE ? OR p.brand LIKE ?)"],
      [[typeDataIndex.value],"AND p.type = ?"],
    ];
    var sqlGroup = "";
    var sqlLimit = ["",""];

    List<Map<String, dynamic>> productList = await sqlReadBuilder(sqlHeader,sqlColumn,sqlTable,sqlWhere,sqlGroup,sqlLimit,database,true);

    productData.add(productList);
    return true;
  }

  void applySearch(String search){
    searchFilters.add(search);
    searchProductData();
  }

  Future<bool> readTypeList() async{
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "tenant.db");
    Database database = await openDatabase(path, version: 1);

    var typeList = [{}];
    var typeItemList = [];

    await database.transaction((txn) async {
      typeList = await txn.rawQuery("SELECT * FROM type_product");
    });

    for(var i=0;i<typeList.length;i++){
      typeItemList.add(typeList[i]['name']);
    }
    await database.close();

    typeData.add(typeList);
    typeDataName.add(typeItemList);
    return true;
  }

  void dispose() {
    searchFilters.close();
    typeFiltersIndex.close();
    typeDataName.close();
    productData.close();
  }

}