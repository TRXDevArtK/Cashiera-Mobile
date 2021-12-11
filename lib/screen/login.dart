//core & plugins
import 'package:flutter/material.dart';

//public data
import 'package:Cashiera/datas/public.dart';

//helper
import 'package:Cashiera/helper/format_helper.dart';

//bloc
import 'package:Cashiera/blocs/login_bloc.dart';

//class untuk menampung data sementara yang public di login
class LoginVar{
  static var username = TextEditingController();
  static var password = TextEditingController();
  static var key = TextEditingController();
}

//widget stateful untuk widget dinamis
class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  //panggil BLOC / inisialisai BLOC
  late LoginBloc loginBloc;

  @override
  initState() {
    super.initState();
    loginBloc = LoginBloc();
  }


  //bangun tampilannya
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Cashiera Login"),
          backgroundColor: parseColor(StoreData.color),
          centerTitle: true,
      ),
      body:Container(
        alignment: Alignment.topCenter,
        child:Wrap(
          spacing: 10.0,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(25.0),
              child: Column(
                children: [
                  Text("Selamat Datang di"),
                  Text(
                    StoreData.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: parseColor(StoreData.color)
                      )
                  )
                ],
              ),
            ),
            StreamBuilder(
                stream: loginBloc.loginNotfData,
                builder: (BuildContext context, AsyncSnapshot snapshot){
                  if (!snapshot.hasData) {
                    return Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.all(20.0),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          backgroundColor: Colors.grey,
                        ),
                        child: Text(
                            "Loading . . .",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white)
                        ),
                        onPressed: () async {
                          return null;
                        },
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }
                  return Wrap(
                    spacing: 5.0,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.all(20.0),
                        child: (snapshot.data[1] == true) ? CircularProgressIndicator() : SizedBox()
                      ),
                      Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.all(20.0),
                        child: Text(snapshot.data[0], textAlign: TextAlign.center, style: TextStyle(color: Colors.black))
                      ),
                    ],
                  );
                }
            ),
            StreamBuilder(
                stream: loginBloc.checkSameUsers,
                builder: (BuildContext context, AsyncSnapshot snapshot){
                  if (!snapshot.hasData) {
                    return Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.all(20.0),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          textStyle: const TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          backgroundColor: Colors.grey,
                        ),
                        child: Text(
                            "Loading . . .",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white)
                        ),
                        onPressed: () async {
                          return null;
                        },
                      ),
                    );
                  }
                  if (snapshot.hasError) {
                    return Text(snapshot.error.toString());
                  }
                  LoginVar.username.text = snapshot.data;
                  return Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.all(8.0),
                      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
                      child:TextFormField(
                        controller: LoginVar.username,
                        onChanged: (text){
                          loginBloc.checkInput(LoginVar.username.text, LoginVar.password.text, LoginVar.key.text);
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Username',
                        ),
                      )
                  );
                }
            ),
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
              child:TextFormField(
                controller: LoginVar.password,
                enableSuggestions: false,
                autocorrect: false,
                obscureText: true,
                onChanged: (text){
                  loginBloc.checkInput(LoginVar.username.text, LoginVar.password.text, LoginVar.key.text);
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
              )
            ),
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(8.0),
              padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 0.0),
              child:TextFormField(
                controller: LoginVar.key,
                enableSuggestions: false,
                autocorrect: false,
                obscureText: true,
                onChanged: (text){
                  loginBloc.checkInput(LoginVar.username.text, LoginVar.password.text, LoginVar.key.text);
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Key',
                ),
              )
            ),
            StreamBuilder(
              stream: loginBloc.loginConfData,
              builder: (BuildContext context, AsyncSnapshot snapshot){
                if (!snapshot.hasData) {
                  return Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.all(20.0),
                    child: Text(
                          "Loading . . .",
                          style: TextStyle(color: Colors.white)
                        ),
                    );
                }
                if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                }
                return Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.all(20.0),
                  child: TextButton(
                      style: TextButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        backgroundColor: snapshot.data[0] ? Colors.blue : Colors.grey,
                      ),
                      child: Text(
                        "Login / Submit",
                        style: TextStyle(color: Colors.white)
                      ),
                      onPressed: () async{
                        if(snapshot.data[0] == false){
                          return null;
                        }
                        var confirmLogin = await loginBloc.login(LoginVar.username.text, LoginVar.password.text, LoginVar.key.text);
                        if(confirmLogin == true){
                          Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (Route<dynamic> route) => false);
                        }
                      },
                    ),
                );
              }
            )
          ],
        )
      ),
    );
  }

  //buang data BLOC jika tidak digunakan lagi
  @override
  void dispose(){
    loginBloc.drain();
    super.dispose();
  }
}
