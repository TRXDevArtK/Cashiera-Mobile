//core & plugins
import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

//public data
import 'package:Cashiera/datas/public.dart';

//helper
import 'package:Cashiera/helper/db_helper.dart';

class LoginBloc {
  static final enableSubmit = BehaviorSubject<bool>.seeded(false);
  static final loginSuccess = BehaviorSubject<bool>.seeded(false);
  static final loginEffect = BehaviorSubject<bool>.seeded(false);
  static final loginNotf = BehaviorSubject<String>.seeded("");

  final checkSameUsers = BehaviorSubject<String>.seeded("");

  //data akhir bloc
  //rencana, buat loginfalse / loginsalah, dan notifikasinya dengan combinelatest stream
  final loginNotfData = CombineLatestStream.list([loginNotf, loginEffect]);
  final loginConfData = CombineLatestStream.list([enableSubmit, loginSuccess]);

  //first initialization
  //put something you need
  LoginBloc(){
    readStoreData();
    checkUser();
  }

  Future<void> readStoreData() async{
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "tenant.db");
    var dbExists = await databaseExists(path);
    Database database = await openDatabase(path, version: 1);

    List<Map<String, dynamic>> storeData = [];

    if(dbExists == true){
      await database.transaction((txn) async {
        var sqlHeader = "SELECT";
        var sqlColumn = [
          ['ids.id', 'id'],
          ['ids.name', 'name'],
          ['ids.location', 'location'],
          ['ids.config', 'config'],
          ['ids.color', 'color'],
          ['ids.logo', 'logo'],
          ['ids.print_logo', 'print_logo'],
          ['ids.print_msg', 'print_msg'],
          ['ids.mode', 'mode'],
          ['ids.timezone', 'timezone'],
          ['ids.latest_data', 'latest_data'],
          ['ids.image_url', 'image_url']
        ];
        var sqlTable = "FROM id_store ids";
        var sqlWhere = [];
        var sqlGroup = "";
        var sqlLimit = ["",""];

        storeData = await sqlReadBuilder(sqlHeader,sqlColumn,sqlTable,sqlWhere,sqlGroup,sqlLimit,txn,false);
      });
      await database.close();

      Map data = storeData[0];

      print(storeData);

      StoreData.name = data['name'] ?? "Cashiera";
      StoreData.location = data['location'] ?? "NULL";
      StoreData.config = data['config'];
      StoreData.color = data['color'] ?? "#0000FF";
      StoreData.logo = data['logo'] ?? "NULL";
      StoreData.printLogo = data['print_logo'] ?? "NULL";
      StoreData.printMsg = data['print_msg'] ?? "Terima Kasih";
      StoreData.mode = data['mode'];
      StoreData.timeZone = data['timezone'] ?? "UTC";
      StoreData.latestData = data['latest_data'] ?? "NULL";
      StoreData.imageUrl = data['image_url'] ?? "NULL";

    }
    else{

    }
  }

  void checkInput(String username, String password, String key) {
    if ((username.length > 0) && (password.length > 0) && (key.length > 0)) {
      enableSubmit.add(true);
    }
    else {
      enableSubmit.add(false);
    }
  }

  Future<bool> createDbTable() async{
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "tenant.db");

    if(checkSameUsers.value != UserData.username){
      await deleteDatabase(path);
    }

    var dbExists = await databaseExists(path);

    //inisialisasi database
    Database database = await openDatabase(path, version: 1);

    loginNotf.add("Pengecekkan database . . .");
    if (dbExists == true) {
      var latestData = await database.rawQuery("SELECT * FROM id_store");
      var latestDataResults = latestData[0]['latest_data'].toString();

      var terms = "read_latest_table_data";
      var data = {
        'terms':terms,
        'db_name':DbData.name,
        'db_hostname':DbData.hostname,
        'db_username':DbData.username,
        'db_password':DbData.password,
        'user_id':UserData.id.toString(),
        'id_store':UserData.idStore.toString(),
        'latest_data':latestDataResults
      };
      var results = await httpBuilder(DbData.serviceUrl, data);

      if(results['status'] == false){
        loginNotf.add("Terjadi kesalahan server, data tidak bisa diambil, silahkan coba lagi . . .");
        return false;
      }

      loginNotf.add("Update database terbaru, mohon tunggu sebentar . . .");
      //insert data to sqlite
      var productData = results['data']['read_product'];
      var typeProductData = results['data']['type_product'];
      var categoryProductData = results['data']['category_product'];
      var bundlingData = results['data']['bundling'];
      var storeData = results['data']['store'];

      //set store data to variable, check null
      if(storeData != null){
        StoreData.name = storeData['name'] ?? "Cashiera";
        StoreData.location = storeData['location'] ?? "NULL";
        StoreData.config = int.parse(storeData['config']);
        StoreData.color = storeData['color'] ?? "#0000FF";
        StoreData.logo = storeData['logo'] ?? "NULL";
        StoreData.printLogo = storeData['print_logo'] ?? "NULL";
        StoreData.printMsg = storeData['print_msg'] ?? "Terima Kasih";
        StoreData.mode = int.parse(storeData['mode']);
        StoreData.timeZone = storeData['timezone'] ?? "UTC";
        StoreData.latestData = storeData['latest_data'] ?? "NULL";
        StoreData.imageUrl = storeData['image_url'] ?? "NULL";
      }

      // Insert some records in a transaction
      await database.transaction((txn) async {
        //always insert username as temp
        txn.rawInsert("INSERT OR REPLACE INTO `login_temp` (`id`, `username`, `image_url`) VALUES ('"+UserData.id.toString()+"', '"+UserData.username+"', NULL)");

        if(productData != null){
          for(var i=0;i<productData.length;i++){
            await txn.rawInsert("INSERT OR REPLACE INTO `product` (`id`, `code`, `name`, `category`, `brand`, `desc`, `type`, "
                "`stock`, `id_store`, `capital`, `profit_min`, `profit_max`, `discount`, `weight`, `bundling`, `stats`, "
                "`inputter`, `receipt`, `latest_data`, `image_url`) "
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                [productData[i]['id'], productData[i]['code'], productData[i]['name'],
                  productData[i]['category'], productData[i]['brand'], productData[i]['desc'],
                  productData[i]['type'], productData[i]['stock'], productData[i]['id_store'],
                  productData[i]['capital'], productData[i]['profit_min'], productData[i]['profit_max'],
                  productData[i]['discount'], productData[i]['weight'], productData[i]['bundling'],
                  productData[i]['stats'], productData[i]['inputter'], productData[i]['receipt'],
                  productData[i]['latest_data'], productData[i]['image_url']]
            );
          }
        }

        if (typeProductData != null) {
          for(var i=0;i<typeProductData.length;i++){
            await txn.rawInsert("INSERT OR REPLACE INTO `type_product` (`id`, `name`, `image_url`) "
                "VALUES (?, ?, ?)",
                [typeProductData[i]['id'], typeProductData[i]['name'], typeProductData[i]['image_url']]
            );
          }
        }

        if(categoryProductData != null){
          for(var i=0;i<categoryProductData.length;i++){
            await txn.rawInsert("INSERT OR REPLACE INTO `category_product` (`id`, `name`) VALUES (?, ?)",
                [categoryProductData[i]['id'], categoryProductData[i]['name']]
            );
          }
        }

        if(bundlingData != null){
          for(var i=0;i<bundlingData.length;i++){
            await txn.rawInsert("INSERT OR REPLACE INTO `bundling` (`id`, `product_id`, `profit_max`, `name`, `amount`, `status`) "
                "VALUES (?, ?, ?, ?, ?, ?)",
                [bundlingData[i]['id'], bundlingData[i]['product_id'], bundlingData[i]['profit_max'],
                  bundlingData[i]['name'], bundlingData[i]['amount'], bundlingData[i]['status']]
            );
          }
        }

        if(storeData != null){
          await txn.rawInsert("INSERT OR REPLACE INTO `id_store` (`id`, `name`, `location`, `config`, `color`, `logo`, "
              "`print_logo`, `print_msg`, `mode`, `timezone`, `latest_data`, `image_url`) "
              "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
              [storeData['id'], storeData['name'], storeData['location'], storeData['config'],
                storeData['color'], storeData['logo'], storeData['print_logo'],
                storeData['print_msg'], storeData['mode'], storeData['timezone'],
                storeData['latest_data'], storeData['image_url']]
          );
        }
      });

      await database.close();
      loginNotf.add("Berhasil Ditambahkan, akan redirect, mohon tunggu sebentar . . .");
      loginSuccess.add(true);
      loginEffect.add(false);
      return true;
    }
    else {
      loginNotf.add("Membuat database");
      await database.transaction((txn) async {
        // When creating the db, create the table
        await txn.execute("CREATE TABLE `type_product` (`id` INTEGER,"
            "`name` TEXT,"
            "`image_url` TEXT,"
            "PRIMARY KEY (`id` AUTOINCREMENT)"
            ")");

        await txn.execute("CREATE TABLE `selling_history` (`id` INTEGER,"
            "`datetime` TEXT ,"
            " `capital` NUMERIC ,"
            "`profit` NUMERIC ,"
            "`report` TEXT ,"
            " `pricing_report` NUMERIC ,"
            "`amount` INTEGER ,"
            "`product_id` INTEGER ,"
            "`teller` INTEGER ,"
            "`online` INTEGER ,"
            "PRIMARY KEY (`id` AUTOINCREMENT)"
            ")");

        await txn.execute("CREATE TABLE `selling_temp` (`id` INTEGER  ,"
            "`datetime` TEXT ,"
            " `capital` NUMERIC ,"
            "`profit` NUMERIC ,"
            "`amount` INTEGER ,"
            "`product_id` INTEGER ,"
            "`teller` INTEGER ,"
            "PRIMARY KEY (`id` AUTOINCREMENT)"
            ")");

        await txn.execute("CREATE TABLE `product` (`id` INTEGER  ,"
            "`code` TEXT ,"
            "`name` TEXT ,"
            " `category` INTEGER ,"
            " `brand` TEXT ,"
            " `desc` TEXT ,"
            " `type` INTEGER ,"
            "`stock` INTEGER ,"
            "`id_store` INTEGER ,"
            " `capital` NUMERIC ,"
            " `profit_min` NUMERIC ,"
            "`profit_max` NUMERIC ,"
            "`discount` INTEGER ,"
            "`weight` NUMERIC ,"
            "`bundling` INTEGER ,"
            "`stats` INTEGER ,"
            " `inputter` TEXT ,"
            "`receipt` INTEGER ,"
            " `latest_data` TEXT ,"
            "`image_url` TEXT ,"
            "PRIMARY KEY (`id` AUTOINCREMENT)"
            ")");

        await txn.execute("CREATE TABLE `category_product` (`id` INTEGER  ,"
            "`name` TEXT ,"
            "PRIMARY KEY (`id` AUTOINCREMENT)"
            ")");

        await txn.execute("CREATE TABLE `bundling` (`id` INTEGER ,"
            "`product_id` INTEGER ,"
            "`profit_max` NUMERIC ,"
            "`name` TEXT ,"
            "`amount` INTEGER ,"
            "`status` INTEGER ,"
            "PRIMARY KEY (`id` AUTOINCREMENT)"
            ")");

        await txn.execute("CREATE TABLE `login_temp` (`id` INTEGER  ,"
            "`username` TEXT ,"
            "`image_url` TEXT ,"
            "PRIMARY KEY (`id` AUTOINCREMENT)"
            ")");

        await txn.execute("CREATE TABLE `printer` (`id` INTEGER  ,"
            "`username` TEXT ,"
            "`key` TEXT ,"
            "PRIMARY KEY (`id` AUTOINCREMENT)"
            ")");

        await txn.execute("CREATE TABLE `id_store` (`id` integer, "
            "`name` text DEFAULT NULL,"
            "`location` text DEFAULT NULL,"
            " `config` integer NOT NULL,"
            "`color` text NOT NULL,"
            "`logo` text DEFAULT NULL,"
            "`print_logo` text DEFAULT NULL,"
            "`print_msg` text DEFAULT NULL,"
            "`mode` integer NOT NULL,"
            "`timezone` text NOT NULL,"
            "`latest_data` datetime DEFAULT NULL,"
            "`image_url` text DEFAULT NULL,"
            "PRIMARY KEY (`id` AUTOINCREMENT)"
            ")");

            loginNotf.add("Database berhasil di tambahkan");
          });

      loginNotf.add("Memasukkan data terbaru");

      var terms = "read_table_data";
      var data = {
        'terms':terms,
        'db_name':DbData.name,
        'db_hostname':DbData.hostname,
        'db_username':DbData.username,
        'db_password':DbData.password,
        'id_store':UserData.idStore.toString(),
        'user_id':UserData.id.toString()
      };
      var results = await httpBuilder(DbData.serviceUrl, data);

      if(results['status'] == false){
        loginNotf.add(results['notf']);
        loginEffect.add(false);
        return false;
      }

      //insert data to sqlite
      var productData = results['data']['read_product'];
      var typeProductData = results['data']['type_product'];
      var categoryProductData = results['data']['category_product'];
      var bundlingData = results['data']['bundling'];
      var storeData = results['data']['store'];

      //set store data to variable
      if(storeData != null){
        StoreData.name = storeData['name'] ?? "Cashiera";
        StoreData.location = storeData['location'] ?? "NULL";
        StoreData.config = int.parse(storeData['config']);
        StoreData.color = storeData['color'] ?? "#0000FF";
        StoreData.logo = storeData['logo'] ?? "NULL";
        StoreData.printLogo = storeData['print_logo'] ?? "NULL";
        StoreData.printMsg = storeData['print_msg'] ?? "Terima Kasih";
        StoreData.mode = int.parse(storeData['mode']);
        StoreData.timeZone = storeData['timezone'] ?? "UTC";
        StoreData.latestData = storeData['latest_data'] ?? "NULL";
        StoreData.imageUrl = storeData['image_url'] ?? "NULL";
      }

      // Insert some records in a transaction
      await database.transaction((txn) async {
        //insert username
        txn.rawInsert("INSERT OR REPLACE INTO `login_temp` (`id`, `username`, `image_url`) VALUES ('"+UserData.id.toString()+"', '"+UserData.username+"', NULL)");

        if(productData != null){
          for(var i=0;i<productData.length;i++){
            await txn.rawInsert("INSERT INTO `product` (`id`, `code`, `name`, `category`, `brand`, `desc`, `type`, "
                "`stock`, `id_store`, `capital`, `profit_min`, `profit_max`, `discount`, `weight`, `bundling`, `stats`, "
                "`inputter`, `receipt`, `latest_data`, `image_url`) "
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                [productData[i]['id'], productData[i]['code'], productData[i]['name'],
                  productData[i]['category'], productData[i]['brand'], productData[i]['desc'],
                  productData[i]['type'], productData[i]['stock'], productData[i]['id_store'],
                  productData[i]['capital'], productData[i]['profit_min'], productData[i]['profit_max'],
                  productData[i]['discount'], productData[i]['weight'], productData[i]['bundling'],
                  productData[i]['stats'], productData[i]['inputter'], productData[i]['receipt'],
                  productData[i]['latest_data'], productData[i]['image_url']]
            );
          }
        }

        if(typeProductData != null){
          for(var i=0;i<typeProductData.length;i++){
            await txn.rawInsert("INSERT INTO `type_product` (`id`, `name`, `image_url`) "
                "VALUES (?, ?, ?)",
                [typeProductData[i]['id'], typeProductData[i]['name'], typeProductData[i]['image_url']]
            );
          }
        }

        if(categoryProductData != null){
          for(var i=0;i<categoryProductData.length;i++){
            await txn.rawInsert("INSERT INTO `category_product` (`id`, `name`) "
                "VALUES (?, ?)",
                [categoryProductData[i]['id'], categoryProductData[i]['name']]
            );
          }
        }

        if(bundlingData != null){
          for(var i=0;i<bundlingData.length;i++){
            await txn.rawInsert("INSERT INTO `bundling` (`id`, `product_id`, `profit_max`, `name`, `amount`, `status`) "
                "VALUES (?, ?, ?, ?, ?, ?)",
                [bundlingData[i]['id'], bundlingData[i]['product_id'], bundlingData[i]['profit_max'],
                  bundlingData[i]['name'], bundlingData[i]['amount'], bundlingData[i]['status']]
            );
          }
        }

        if(storeData != null){
          await txn.rawInsert("INSERT INTO `id_store` (`id`, `name`, `location`, `config`, `color`, `logo`, "
              "`print_logo`, `print_msg`, `mode`, `timezone`, `latest_data`, `image_url`) "
              "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
              [storeData['id'], storeData['name'], storeData['location'], storeData['config'],
                storeData['color'], storeData['logo'], storeData['print_logo'],
                storeData['print_msg'], storeData['mode'], storeData['timezone'],
                storeData['latest_data'], storeData['image_url']]
          );
        }
      });

      await database.close();
      loginNotf.add("Berhasil Ditambahkan, akan redirect, mohon tunggu sebentar . . .");
      loginSuccess.add(true);
      loginEffect.add(false);
      return true;
    }
  }

  Future<bool> checkUser() async{
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "tenant.db");
    var dbExists = await databaseExists(path);

    Database database = await openDatabase(path, version: 1);
    if(dbExists == true){
      var usernameCheck = await database.rawQuery("SELECT username FROM login_temp");

      if(usernameCheck.isEmpty){
        return false;
      }

      var usernameData = usernameCheck[0]['username'].toString();
      checkSameUsers.add(usernameData);

      return true;
    }
    else{
      return false;
    }
  }

  Future<bool> login(String username, String password, String key) async{
    loginEffect.add(true);
    loginNotf.add("Check akun mohon tunggu sebentar . . .");
    var terms = "login";
    var data = {
      'terms':terms,
      'username':username,
      'password':password,
      'key':key
    };
    var results = await httpBuilder(DbData.serviceUrl, data);
    if(results['status'] == true){
      loginNotf.add("Berhasil login, mengecek database . . .");

      //set the login session
      LoginData.status = results['status'];
      LoginData.start = results['data']['start'];
      LoginData.end = results['data']['expire'];

      //set database data
      DbData.id = results['data']['db_id'];
      DbData.name = results['data']['db_name'];
      DbData.hostname = results['data']['db_hostname'];
      DbData.username = results['data']['db_username'];
      DbData.password = results['data']['db_password'];

      //set user data
      UserData.id = results['data']['id'];
      UserData.username = results['data']['username'];
      UserData.fullName = results['data']['full_name'];
      UserData.callName = results['data']['call_name'];
      UserData.phone =  results['data']['phone'];
      UserData.email = results['data']['email'];
      UserData.idStore = results['data']['id_store'];

      return await createDbTable();
    }
    else if(results['status'] == false){
      loginEffect.add(false);
      loginNotf.add(results['notf']);
      LoginData.status = results['status'];

      return false;
    }
    else{
      loginEffect.add(false);
      loginNotf.add("Server OFFLINE");
      LoginData.status = false;

      return false;
    }
  }

  //permanent removal
  void dispose() {
    enableSubmit.close();
    loginSuccess.close();
    loginEffect.close();
    loginNotf.close();
    checkSameUsers.close();
  }

  void drain(){
    enableSubmit.drain();
    loginSuccess.drain();
    loginEffect.drain();
    loginNotf.drain();
    checkSameUsers.drain();

    enableSubmit.add(false);
    loginSuccess.add(false);
    loginEffect.add(false);
    loginNotf.add("");
    checkSameUsers.add("");
  }
}
