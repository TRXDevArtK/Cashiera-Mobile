//core & plugins
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

//public data
import 'package:Cashiera/datas/public.dart';

//helper
import 'package:Cashiera/helper/dialog_helper.dart';
import 'package:Cashiera/helper/format_helper.dart';
import 'package:Cashiera/helper/time_helper.dart';

//bloc
import 'package:Cashiera/blocs/cart_history_bloc.dart';

//class untuk menampung data sementara cart_history
class CartHistoryVar{
  static TextEditingController dateTimeContr = TextEditingController();
  static TextEditingController searchContr = TextEditingController();
  static MoneyMaskedTextController reportPayContr = MoneyMaskedTextController(leftSymbol: 'Rp', precision: 0, decimalSeparator: '', thousandSeparator: '.');
  static TextEditingController reportDescContr = TextEditingController();

  static Map processedReportData = {};

  static final reportFormKey = GlobalKey<FormState>();

  //other avar
  static String profit = "";
  static String profitMin = "";
}

//widget stateful untuk widget yang dinamis : berubah ubah
class CartHistory extends StatefulWidget {
  const CartHistory({Key? key}) : super(key: key);

  @override
  _CartHistoryState createState() => _CartHistoryState();
}

class _CartHistoryState extends State<CartHistory> {
  //inisialisasi BLOC
  CartHistoryBloc cartHistoryBloc = CartHistoryBloc();

  //inisialisasi kode pertama yg di load
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    CartHistoryVar.dateTimeContr.text = dateTimeBuilder('now', StoreData.timeZone, "yyyy-MM-dd");
  }

  //modal untuk melihat detail produk beserta kalkulasi statis untuk harga
  void productDetailModal(BuildContext context, Map data){
    CartHistoryVar.profit = numberToCurrency(data['capital']+data['profit'], 'ID', 'Rp', 0, 'double');
    CartHistoryVar.profitMin = numberToCurrency(data['capital']+data['profit_min'], 'ID', 'Rp', 0, 'double');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.all(10.0),
                child: Text(
                    "Rincian Produk",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    )
                ),
              ),
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(10.0),
                child: Text(
                  "Tertera Tanggal : "+data['datetime'].toString()+" ("+StoreData.timeZone+")",
                  style: TextStyle(color: Colors.black),
                  textAlign: TextAlign.center,
                ),
              ),
              Flexible(
                flex: 1,
                fit: FlexFit.loose,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.all(5.0),
                        child: TextFormField(
                          readOnly: true,
                          initialValue: data['name'].toString(),
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Nama Produk',
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(5.0),
                        child: TextFormField(
                          readOnly: true,
                          initialValue: data['code'].toString(),
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Kode Produk',
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Container(
                              margin: EdgeInsets.all(5.0),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                readOnly: true,
                                initialValue: data['discount'].toString()+"%",
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Diskon',
                                ),
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            child: Container(
                              margin: EdgeInsets.all(5.0),
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                readOnly: true,
                                initialValue: data['amount'].toString(),
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Jumlah Dibeli',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.all(5.0),
                        child: TextFormField(
                          readOnly: true,
                          keyboardType: TextInputType.number,
                          initialValue: CartHistoryVar.profitMin,
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Harga Min',
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(5.0),
                        child: TextFormField(
                          readOnly: true,
                          keyboardType: TextInputType.number,
                          initialValue: CartHistoryVar.profit,
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Harga Set (Maks : '+(data['capital']+data['profit_max']).toString()+')',
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(5.0),
                        child: TextFormField(
                          readOnly: true,
                          keyboardType: TextInputType.number,
                          initialValue: data['amount'].toString(),
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Jumlah Barang',
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(5.0),
                        child: TextButton(
                          style: TextButton.styleFrom(
                              alignment: Alignment.center,
                              textStyle: const TextStyle(fontSize: 18),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: BorderSide(color: Colors.blue, width: 2)
                              ),
                              backgroundColor: Color(0xFFE3E3E3)
                          ),
                          child: Text(
                              "Kembali",
                              style: TextStyle(
                                  color: Colors.blueAccent
                              )
                          ),
                          onPressed: () async{
                            CartHistoryVar.reportPayContr.clear();
                            CartHistoryVar.reportDescContr.clear();
                            return Navigator.of(context).pop();
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  //modal untuk menginputkan laporan barang
  void reportData(Map data){
    CartHistoryVar.profit = numberToCurrency(data['profit'], 'ID', 'Rp', 0, 'double');
    CartHistoryVar.reportPayContr.text = data['pricing_report'].toString();
    CartHistoryVar.reportDescContr.text = data['report'].toString();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                backgroundColor: Colors.white,
                content:  SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Form(
                    key: CartHistoryVar.reportFormKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Flexible(
                            flex: 1,
                            fit: FlexFit.loose,
                            child: Text(
                                "Laporkan Kesalahan",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold)
                            )
                        ),
                        Flexible(
                          flex: 1,
                          fit: FlexFit.loose,
                          child: Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.all(20.0),
                            child: Text(
                              "Tertera Tanggal : "+data['datetime'].toString(),
                              style: TextStyle(color: Colors.black),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(5.0),
                          child: TextFormField(
                            readOnly: true,
                            initialValue: data['name'].toString(),
                            style: TextStyle(
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              fillColor: Colors.grey,
                              filled: true,
                              labelText: 'Nama Produk',
                            ),
                            validator: (value){
                              if(value == null || value.isEmpty){
                                return "Tolong inputkan teks";
                              }
                              else{
                                return null;
                              }
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(5.0),
                          child: TextFormField(
                            readOnly: true,
                            initialValue: CartHistoryVar.profit,
                            style: TextStyle(
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              fillColor: Colors.grey,
                              filled: true,
                              labelText: 'Harga Set',
                            ),
                            validator: (value){
                              if(value == null || value.isEmpty){
                                return "Tolong inputkan teks";
                              }
                              else{
                                return null;
                              }
                            },
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(5.0),
                          child: TextFormField(
                            controller: CartHistoryVar.reportPayContr,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                onPressed: () => CartHistoryVar.reportPayContr.clear(),
                                icon: Icon(Icons.clear),
                              ),
                              border: OutlineInputBorder(),
                              labelText: 'Harga Laporan',
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(5.0),
                          child: TextFormField(
                            maxLines: 8,
                            maxLength: 255,
                            controller: CartHistoryVar.reportDescContr,
                            style: TextStyle(
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                onPressed: () => CartHistoryVar.reportPayContr.clear(),
                                icon: Icon(Icons.clear),
                              ),
                              border: OutlineInputBorder(),
                              labelText: 'Deskripsi Laporan',
                            ),
                            validator: (value){
                              if(value == null || value.isEmpty){
                                return "Tidak boleh kosong";
                              }
                              else{
                                return null;
                              }
                            },
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              flex: 1,
                              fit: FlexFit.loose,
                              child: Container(
                                margin: EdgeInsets.all(5.0),
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                      alignment: Alignment.center,
                                      textStyle: const TextStyle(fontSize: 18),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                          side: BorderSide(color: Colors.blue, width: 2)
                                      ),
                                      backgroundColor: Color(0xFFE3E3E3)
                                  ),
                                  child: Text(
                                      "Kembali",
                                      style: TextStyle(
                                          color: Colors.redAccent
                                      )
                                  ),
                                  onPressed: () async{
                                    CartHistoryVar.reportPayContr.clear();
                                    CartHistoryVar.reportDescContr.clear();
                                    return Navigator.of(context).pop();
                                  },
                                ),
                              ),
                            ),
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
                                          side: BorderSide(color: Colors.blue, width: 2)
                                      ),
                                      backgroundColor: Color(0xFFE3E3E3)
                                  ),
                                  child: Text(
                                      "Selesaikan",
                                      style: TextStyle(
                                          color: Colors.blue
                                      )
                                  ),
                                  onPressed: () async{
                                    if (CartHistoryVar.reportFormKey.currentState!.validate()) {
                                      setState((){
                                        CartHistoryVar.processedReportData = Map.of(data);
                                        CartHistoryVar.processedReportData['report'] = CartHistoryVar.reportDescContr.text;
                                        CartHistoryVar.processedReportData['pricing_report'] = CartHistoryVar.reportPayContr.numberValue;
                                      });
                                      Map results = await cartHistoryBloc.submitReport(CartHistoryVar.processedReportData);
                                      Navigator.of(context).pop();
                                      if(results['status'] == true){
                                        dialogBuilder(context, results['notf'], "Baiklah", true, false);
                                      }
                                      else{
                                        dialogBuilder(context, results['notf'], "Baiklah", true, false);
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            });
      },
    );
  }

  //fungsi untuk menampilkan list data produk
  Widget listViewProduct(List<Map<String, dynamic>> data){
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 1,
        ),
      ),
      child: ListView.separated(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          padding: EdgeInsets.all(10),
          itemCount: data.length,
          separatorBuilder: (BuildContext context, int index){
            return Divider(height: 5);
          },
          itemBuilder: (BuildContext context, int index) {
            return Material(
              child: Ink(
                decoration: BoxDecoration(
                    color: (data[index]['report'].isNotEmpty) ? Colors.orangeAccent : Colors.grey
                ),
                child: InkWell(
                    onTap: (){
                      productDetailModal(context, data[index]);
                    },
                    splashColor: Colors.blue,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(
                          flex: 1,
                          fit: FlexFit.tight,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(data[index]['name'].toString()),
                              ),
                              SizedBox(
                                  height: 5,
                                  width:100,
                                  child: Container(color: Colors.black)
                              ),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Text(data[index]['code'].toString()),
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          fit: FlexFit.tight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Flexible(
                                flex: 2,
                                fit: FlexFit.loose,
                                child: Container(
                                  margin: EdgeInsets.all(10),
                                  padding: EdgeInsets.all(5),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.blueAccent,
                                    border: Border.all(
                                        color: Colors.black, // Set border color
                                        width: 3.0
                                    ),   // Set border width
                                    borderRadius: BorderRadius.all(Radius.circular(6.0)), // Set rounded corner radius // Make rounded corner of border
                                  ),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Text(data[index]['datetime'].toString()),
                                  ),
                                ),
                              ),
                              Flexible(
                                flex: 1,
                                fit: FlexFit.loose,
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    backgroundColor: Colors.orange,
                                  ),
                                  child: Text(
                                      "Laporan",
                                      style: TextStyle(color: Colors.white)
                                  ),
                                  onPressed: () async {
                                    reportData(data[index]);
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    )
                ),
              ),
            );
          }
      ),
    );
  }

  //inisialisasi tampilan awl
  @override
  Widget build(BuildContext context) {
    return Flexible(
        fit:FlexFit.loose,
        flex: 8,
        child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //tamilan fleksibel : Flexible
          Flexible(
            flex: 1,
            fit: FlexFit.loose,
            child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(10.0),
                child: TextField(
                  readOnly: true,
                  controller: CartHistoryVar.dateTimeContr,
                  onTap: () async{
                    CartHistoryVar.dateTimeContr.text = await datePickerBuilder(context);
                    cartHistoryBloc.applyDateFilters(CartHistoryVar.dateTimeContr.text);
                    CartHistoryVar.searchContr.clear();
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Pilih Tanggal, (hari ini : '+dateTimeBuilder('now', StoreData.timeZone, "yyyy-MM-dd")+") ("+StoreData.timeZone+")",
                  ),
                )
            ),
          ),
          Flexible(
            flex: 1,
            fit: FlexFit.loose,
            child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(10.0),
                child: TextField(
                  controller: CartHistoryVar.searchContr,
                  onChanged: (text){
                    cartHistoryBloc.applySearchFilters(text);
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Cari Disini . . .',
                  ),
                )
            ),
          ),
          Flexible(
            flex: 7,
            fit: FlexFit.tight,
            child: StreamBuilder(
                stream: cartHistoryBloc.cartHistoryData,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
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
                  if(snapshot.data.length == 0 && CartHistoryVar.searchContr.text.length > 0){
                    return Text("Data pencarian tidak ada atau Kosong");
                  }
                  else if(snapshot.data.length == 0 && CartHistoryVar.searchContr.text.length == 0){
                    return Text("Cart kosong");
                  }
                  else{
                    return listViewProduct(snapshot.data);
                  }
                }
            ),
          ),
          Flexible(
            flex:2,
            fit:FlexFit.loose,
            child: StreamBuilder(
                stream: cartHistoryBloc.dataCheckNotf,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
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
                  return Column(
                    children: [
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
                                side: BorderSide(color: Colors.blue, width: 2)
                              ),
                              backgroundColor: (snapshot.data['countOffline'] > 0) ? Color(0xFFE3E3E3) : Colors.green,
                            ),
                            child: (snapshot.data['loading']) ? CircularProgressIndicator() : Text(
                              snapshot.data['notfButton'].toString(),
                              style: TextStyle(
                                color: (snapshot.data['countOffline'] > 0) ? Colors.blue : Colors.white
                              )
                            ),
                            onPressed: () async{
                              if(snapshot.data['countOffline'] == 0){
                                return null;
                              }
                              await cartHistoryBloc.submitOnline();
                            },
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 1,
                        fit: FlexFit.loose,
                        child: Container(
                          margin: EdgeInsets.all(5.0),
                          child: Text("Total Offline : "+snapshot.data['countOffline'].toString()),
                        ),
                      )
                    ],
                  );
                }
            ),
          )
        ]
      )
    );
  }
}
