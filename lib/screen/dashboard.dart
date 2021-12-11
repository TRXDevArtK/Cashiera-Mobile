//core & plugins
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//public data
import 'package:Cashiera/datas/public.dart';

//helper
import 'package:Cashiera/helper/format_helper.dart';

//screen / fragment
import 'package:Cashiera/screen/cart.dart';
import 'package:Cashiera/screen/product.dart';
import 'package:Cashiera/screen/cart_history.dart';

//bloc
import 'package:Cashiera/blocs/dashboard_bloc.dart';

//class untuk menampung data sementara dashboard
class DashboardVar{
  static Widget dashboardFragment = Product();
}

//stateful untuk widget dinamis
class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  //inisiaslisi BLOC
  DashboardBloc dashboardBloc = DashboardBloc();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
            title: Text(StoreData.name),
            backgroundColor: parseColor(StoreData.color),
            centerTitle: true,
        ),
        drawer: Theme(
            data: Theme.of(context).copyWith(
              // Set the transparency here
              canvasColor: Colors.white,
            ),
            child: Drawer(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Flexible(
                    flex: 1,
                    fit: FlexFit.loose,
                    child: DrawerHeader(
                      decoration: BoxDecoration(
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: Colors.black54,
                              blurRadius: 15.0,
                              offset: Offset(0.0, 0.75)
                          )
                        ],
                        color: parseColor(StoreData.color),
                      ),
                      child: Text(
                          'Cashiera Navigation',
                          style: TextStyle(
                            fontWeight: FontWeight.bold
                          )
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    fit: FlexFit.loose,
                    child: Container(
                      alignment: Alignment.center,
                      color: Colors.greenAccent,
                      child: Text(
                        "User Profile",
                        style: TextStyle(
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    fit: FlexFit.loose,
                    child: Card(
                      child: ListTile(
                        title: Text('Nama : '+UserData.fullName),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    fit: FlexFit.loose,
                    child: Card(
                      child: ListTile(
                        title: Text('Nama Panggil : '+UserData.callName),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    fit: FlexFit.loose,
                    child: Card(
                      child: ListTile(
                        title: Text('No HP : '+UserData.phone),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    fit: FlexFit.loose,
                    child: Card(
                      child: ListTile(
                        title: Text('Di Toko : '+StoreData.name),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    fit: FlexFit.loose,
                    child: Card(
                      child: ListTile(
                        title: Text('Zona Waktu : '+StoreData.timeZone),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    fit: FlexFit.loose,
                    child: Card(
                      child: ListTile(
                        title: Text('Data Terakhir : '+StoreData.latestData),
                      ),
                    ),
                  ),
                  //apabila ditekan tombolnya maka redirect ke . . .
                  Flexible(
                    flex: 1,
                    fit: FlexFit.loose,
                    child: Container(
                      margin: EdgeInsets.all(5.0),
                      child: TextButton(
                        style: TextButton.styleFrom(
                          alignment: Alignment.center,
                          textStyle: TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              side: BorderSide(color: parseColor(StoreData.color), width: 2)
                          ),
                          backgroundColor: Colors.orange,
                        ),
                        child: Text(
                            "Logout",
                            style: TextStyle(
                                color: Colors.black
                            )
                        ),
                        onPressed: () async{
                          Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
                          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                        },
                      ),
                    ),
                  ),
                ],
              )
              // All other codes goes here.
            )
        ),
        body:Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Flexible(
              fit:FlexFit.loose,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    fit:FlexFit.tight,
                    flex: 1,
                    child: TextButton(
                      style: TextButton.styleFrom(
                        alignment: Alignment.center,
                        textStyle: const TextStyle(fontSize: 18),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: parseColor(StoreData.color))
                        ),
                        backgroundColor: Color(0xFFE3E3E3),
                      ),
                      child: Text(
                        "Product",
                        style: TextStyle(color: parseColor(StoreData.color))
                      ),
                      onPressed: () async{
                        setState(() {
                          DashboardVar.dashboardFragment = Product();
                        });
                      }
                    )
                  ),
                  Flexible(
                      fit:FlexFit.tight,
                      flex: 1,
                      child: TextButton(
                          style: TextButton.styleFrom(
                            alignment: Alignment.center,
                            textStyle: const TextStyle(fontSize: 18),
                            shape: RoundedRectangleBorder(
                                side: BorderSide(color: parseColor(StoreData.color))
                            ),
                            backgroundColor: Color(0xFFE3E3E3),
                          ),
                          child: Text(
                              "Cart",
                              style: TextStyle(color: parseColor(StoreData.color))
                          ),
                          onPressed: () async{
                            setState(() {
                              DashboardVar.dashboardFragment = Cart();
                            });
                          }
                      )
                  ),
                  Flexible(
                    fit:FlexFit.tight,
                    flex: 1,
                      child: TextButton(
                          style: TextButton.styleFrom(
                            alignment: Alignment.center,
                            textStyle: const TextStyle(fontSize: 18),
                            shape: RoundedRectangleBorder(
                                side: BorderSide(color: parseColor(StoreData.color))
                            ),
                            backgroundColor: Color(0xFFE3E3E3),
                          ),
                          child: Text(
                              "Riwayat",
                              style: TextStyle(color: parseColor(StoreData.color))
                          ),
                          onPressed: () async{
                            setState(() {
                              DashboardVar.dashboardFragment = CartHistory();
                            });
                          }
                      )
                  ),
                ]
              ),
            ),
            DashboardVar.dashboardFragment
          ],
        )
    );
  }
}
