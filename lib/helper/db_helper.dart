//core & plugins
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map> httpBuilder(String url, Map data) async {
  var response;
  var results;
  Uri locUrl = Uri.parse(url);
  try {
    response = await http.post(
        locUrl,
        body: data
    );
  }
  catch (e){
    print(e);
    results = {'status':false, 'data':null, 'notf':'Terjadi kesalahan server silahkan coba lagi', 'redir':null};
    return results;
  }

  if((response.statusCode == 200) | (response.statusCode == 201)){
    final data = jsonDecode(response.body);
    if(data['status'] == true){
      results = {'status':data['status'], 'data':data['data'], 'notf':data['notf'], 'redir':null};
      return results;
    }
    else{
      results = {'status':data['status'], 'data':data['data'], 'notf':data['notf'], 'redir':null};
      return results;
    }
  }
  else {
    results = {'status':data['status'], 'data':data['data'], 'notf':data['notf'], 'redir':null};
    return results;
  }
}

Future sqlReadBuilder(String header, List column, String table, List where, String group, List limit, var conn, bool dbClose) async {
  //header (auto)

  List execute = [];
  //column process start
  int columnLength = column.length;
  String columnQuery = "";
  for(int i = 0;i < columnLength;i++){
    columnQuery += column[i][0]+" as "+"'"+column[i][1]+"', ";
  }

  columnQuery = columnQuery.substring(0,columnQuery.length - 2);
  //column process end

  //where process start
  int whereLength = where.length;
  String whereQuery = "";
  if(whereLength == 0){
    //do nothing
  }
  else{
    for(int i = 0;i < whereLength;i++){
      int whereHeaderLength = where[i][0].length;
      for(int j = 0;j < whereHeaderLength;j++){
        if(where[i][0][j] == "" || where[i][0][j] == null || where[i][0][j] == "%%" || where[i][0][j] == "null" || where[i][0][j] == "nullnull"){
          where[i][1] = "";
        }
        else{
          execute.add(where[i][0][j]);
        }
      }
      whereQuery += where[i][1]+" ";
    }

    //string to list
    List listWord = whereQuery.split(' ');
    //remove spacing
    listWord.removeWhere((element) => element == "");

    if(listWord.isNotEmpty == true){
      //remove AND & OR for first word
      if(listWord[0] == "AND" || listWord[0] == "OR"){
        listWord[0] = "";
      }

      //join all
      whereQuery = listWord.join(" ");

      //prepend where
      whereQuery = "WHERE"+whereQuery;
    }
  }
  //where process ends

  //limit process start
  String limitQuery = "LIMIT ?,?";
  int limitLength = limit.length;
  for(int i = 0;i < limitLength;i++){
    if(limit[i] == "" || limit[i] == null || limit[i] == "%%"){
      limitQuery = "";
    }
    else{
      execute.add(limit[i]);
    }
  }
  //limit process end

  //merge all process start
  String allQuery = header+" "+columnQuery+" "+table+" "+whereQuery+" "+group+" "+limitQuery;

  var results = await conn.rawQuery(allQuery,execute);

  if(dbClose == true){
    await conn.close();
  }

  return results;
}

Future sqlUpdateBuilder(String header, String table, List set, List where, var conn, bool dbClose) async{
  //header (auto)
  //table (auto)
  List execute = [];

  //set process start
  int setLength = set.length;
  String setQuery = "";
  for(var i = 0;i < setLength;i++){
    execute.add(set[i][0]);
    setQuery += set[i][1]+", ";
  }

  if(setQuery == ""){
    return {"status" : false, "notf" : "Seluruh input kosong dalam back-end, mohon diisi"};
  }
  else{
    //remove end space
    setQuery = setQuery.substring(0,setQuery.length - 2);
    setQuery = "SET "+setQuery;
  }
  //set process end

  //where process start
  int whereLength = where.length;
  String whereQuery = "";
  if(whereLength == 0){
    //do nothing
  }
  else{
    for(int i = 0;i < whereLength;i++){
      int whereHeaderLength = where[i][0].length;
      for(int j = 0;j < whereHeaderLength;j++){
        if(where[i][0][j] == "" || where[i][0][j] == null || where[i][0][j] == "%%" || where[i][0][j] == "null" || where[i][0][j] == "nullnull"){
          where[i][1] = "";
        }
        else{
          execute.add(where[i][0][j]);
        }
      }
      whereQuery += where[i][1]+" ";
    }

    //string to list
    List listWord = whereQuery.split(' ');
    //remove spacing
    listWord.removeWhere((element) => element == "");

    if(listWord.isNotEmpty == true){
      //remove AND & OR for first word
      if(listWord[0] == "AND" || listWord[0] == "OR"){
        listWord[0] = "";
      }

      //join all
      whereQuery = listWord.join(" ");

      //prepend where
      whereQuery = "WHERE"+whereQuery;
    }
  }
  //where process ends

  //all query process start
  String allQuery = header+" "+table+" "+setQuery+" "+whereQuery;
  //all query process end

  //execute filtering process start
  int executeLength = execute.length;
  List executeBuilder = [];
  for(var i = 0;i < executeLength;i++){
    if(execute[i] == '@*ignore*@'){
    //do nothing
    }
    else{
      executeBuilder.add(execute[i]);
    }
  }

  var results = await conn.rawUpdate(allQuery,execute);
  if(dbClose == true){
    await conn.close();
  }
  return results;
}

Future<int> sqlCreateBuilder(String header, String table, List insert, var conn, bool dbClose) async{
  //header (auto)
  //table (auto)

  List execute = [];

  int insert_length = insert.length;
  String insert_head = "";
  String insert_body = "";
  
  for(int i = 0;i < insert_length;i++){
    insert_head += insert[i][0]+", ";
    insert_body += "?, ";
    execute.add(insert[i][1]);
  }
  
  //remove end space
  insert_head = insert_head.substring(0,insert_head.length - 2);
  insert_head = "("+insert_head+")";

  insert_body = insert_body.substring(0,insert_body.length - 2);
  insert_body = "("+insert_body+")";

  String allQuery = header+" "+table+" "+insert_head+" VALUES "+insert_body;

  int results = await conn.rawInsert(allQuery,execute);

  if(dbClose == true){
    await conn.close();
  }

  return results;
}

Future sqlDeleteBuilder(String header, String table, List where, var conn, bool dbClose) async{
  //header (auto)
  //table (auto)

  List execute = [];

  //where process start
  int whereLength = where.length;
  String whereQuery = "";
  if(whereLength == 0){
    //do nothing
  }
  else{
    for(int i = 0;i < whereLength;i++){
      int whereHeaderLength = where[i][0].length;
      for(int j = 0;j < whereHeaderLength;j++){
        if(where[i][0][j] == "" || where[i][0][j] == null || where[i][0][j] == "%%" || where[i][0][j] == "null" || where[i][0][j] == "nullnull"){
          where[i][1] = "";
        }
        else{
          execute.add(where[i][0][j]);
        }
      }
      whereQuery += where[i][1]+" ";
    }

    //string to list
    List listWord = whereQuery.split(' ');
    //remove spacing
    listWord.removeWhere((element) => element == "");

    if(listWord.isNotEmpty == true){
      //remove AND & OR for first word
      if(listWord[0] == "AND" || listWord[0] == "OR"){
        listWord[0] = "";
      }

      //join all
      whereQuery = listWord.join(" ");

      //prepend where
      whereQuery = "WHERE"+whereQuery;
    }
  }
  //where process end

  String allQuery = header+" "+table+" "+whereQuery;

  var results = await conn.rawDelete(allQuery,execute);

  if(dbClose == true){
    await conn.close();
  }

  return results;
}

