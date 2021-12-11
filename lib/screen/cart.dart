//core & plugins
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

//helper
import 'package:Cashiera/helper/dialog_helper.dart';
import 'package:Cashiera/helper/format_helper.dart';

//bloc
import 'package:Cashiera/blocs/cart_bloc.dart';


//class untuk menampung data cart
class CartVar{
  static TextEditingController searchContr = TextEditingController();
  static final cartFormKey = GlobalKey<FormState>();

  //product submit (selling_temp)
  static MoneyMaskedTextController profitProductContr = MoneyMaskedTextController(leftSymbol: 'Rp', precision: 0, decimalSeparator: '', thousandSeparator: '.');
  static TextEditingController amountProductContr = TextEditingController();
  static MoneyMaskedTextController paymentContr = MoneyMaskedTextController(leftSymbol: 'Rp', precision: 0, decimalSeparator: '', thousandSeparator: '.');
  static MoneyMaskedTextController returnPayContr = MoneyMaskedTextController(leftSymbol: 'Rp', precision: 0, decimalSeparator: '', thousandSeparator: '.');
  static Map processedData = {};

  //other var
  static String profitSet = "";
  static String profitMin = "";
  static String profitMax = "";
  static String capital = "";
}

//stateful widget untuk widget dinamis (berubah ubah)
class Cart extends StatefulWidget {
  const Cart({Key? key}) : super(key: key);

  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  //inisialisasi BLOC
  CartBloc cartBloc = CartBloc();

  //Modal untuk menampilkan cart yang berhasil
  //atau berhasil transaksi
  void totalAllCart(BuildContext context, Map data){
    String moneyReturn = numberToCurrency((CartVar.paymentContr.numberValue - data['total_price']), "ID", "Rp", 0, "double");
    if(moneyReturn == "0.0"){
      moneyReturn = "Tidak ada kembalian (0)";
    }
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Flexible(
                          flex: 1,
                          fit: FlexFit.loose,
                          child: Text(
                              "Transaksi Berhasil",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)
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
                          textAlign: TextAlign.center,
                          readOnly: true,
                          initialValue: moneyReturn,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            border: UnderlineInputBorder(),
                            labelText: 'Kembalian',
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
                              "Baiklah",
                              style: TextStyle(
                                  color: Colors.blueAccent
                              )
                          ),
                          onPressed: () async{
                            return Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
      },
    );
  }

  //modal ketika mensubmit seluruh cart
  //kalkulasi harga dan inputan harga pembelian oleh kostumer
  void submitAllCart(BuildContext context, Map data){
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
                    key: CartVar.cartFormKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Flexible(
                          flex: 1,
                          fit: FlexFit.loose,
                          child: Text(
                              "Proses Transaksi",
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
                            initialValue: numberToCurrency(data['total_price'].toString(), "ID", "Rp", 0, "double"),
                            style: TextStyle(
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              fillColor: Colors.grey,
                              filled: true,
                              labelText: 'Total Harga',
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
                            initialValue: data['total_product'].toString(),
                            style: TextStyle(
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              fillColor: Colors.grey,
                              filled: true,
                              labelText: 'Total Jumlah Produk',
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
                            controller: CartVar.paymentContr,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                onPressed: () => CartVar.paymentContr.clear(),
                                icon: Icon(Icons.clear),
                              ),
                              border: OutlineInputBorder(),
                              labelText: 'Jumlah Uang',
                            ),
                            validator: (value){
                              if(value == null || value.isEmpty){
                                return "Tolong masukkan jumlah uangnya";
                              }
                              else if(double.parse(currencyToNumber(CartVar.paymentContr.text, "double")) < data['total_price']){
                                return "Uangnya kurang";
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
                                    CartVar.paymentContr.clear();
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
                                    if (CartVar.cartFormKey.currentState!.validate()) {
                                      var results = await cartBloc.submitCart();
                                      Navigator.of(context).pop();
                                      if(results['status'] == true){
                                        totalAllCart(context, data);
                                      }
                                      else{
                                        dialogBuilder(context, results['notf'], "Baiklah", true, false);
                                      }
                                    }
                                    else{
                                      return null;
                                    }
                                    CartVar.paymentContr.clear();
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

  //modal ketika seluruh cart di batalkan
  void cancelAllCart(BuildContext context){
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
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text("Hapus Semua Transaksi Cart ?", textAlign: TextAlign.center),
                    SizedBox(height: 15),
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
                                Navigator.of(context).pop();
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
                                  "Hapus",
                                  style: TextStyle(
                                      color: Colors.blue
                                  )
                              ),
                              onPressed: () async{
                                Map results = await cartBloc.deleteAllCart(true);
                                Navigator.of(context).pop();
                                dialogBuilder(context, results['notf'], "Baiklah", true, false);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            });
      },
    );
  }

  //modal untuk mengedit detail produk
  //khususnya harga produk di cart
  void productDetailModal(BuildContext context, Map data){
    CartVar.profitMin = (data['capital']+data['profit_min']).toString();
    CartVar.profitMax = (data['capital']+data['profit_max']).toString();
    CartVar.amountProductContr.text = data['amount'].toString();
    CartVar.profitProductContr.text = (data['profit'] + data['capital']).toString();
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
              Flexible(
                flex: 1,
                fit: FlexFit.loose,
                child: Form(
                    key: CartVar.cartFormKey,
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
                              initialValue: data['code'].toString(),
                              style: TextStyle(
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                fillColor: Colors.grey,
                                filled: true,
                                labelText: 'Kode Produk',
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
                                      fillColor: Colors.grey,
                                      filled: true,
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
                                      fillColor: Colors.grey,
                                      filled: true,
                                      labelText: 'Jumlah Beli',
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
                              initialValue: numberToCurrency(CartVar.profitMin, "ID", "Rp", 0, "double"),
                              style: TextStyle(
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                fillColor: Colors.grey,
                                filled: true,
                                labelText: 'Harga Min',
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(5.0),
                            child: TextFormField(
                              controller: CartVar.profitProductContr,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                color: Colors.black,
                              ),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Harga Set (Maks : '+numberToCurrency(CartVar.profitMax, "ID", "Rp", 0, "double")+')',
                              ),
                              validator: (value){
                                double value = CartVar.profitProductContr.numberValue;
                                if(value == 0.0){
                                  return "Tolong inputkan harga";
                                }
                                else if(value > double.parse(CartVar.profitMax)){
                                  return "Harga harus sama atau <";
                                }
                                else if(value < double.parse(CartVar.profitMin)){
                                  return "Harga terlalu rendah";
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
                                    backgroundColor: Color(0xFFE3E3E3),
                                  ),
                                  child: Text(
                                      "Batalkan",
                                      style: TextStyle(color: Colors.redAccent)
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
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
                                    backgroundColor: Color(0xFFE3E3E3),
                                  ),
                                  child: Text(
                                      "Update",

                                      style: TextStyle(color: Colors.blue)
                                  ),
                                  onPressed: () async{
                                    if (CartVar.cartFormKey.currentState!.validate()) {
                                      setState((){
                                        CartVar.processedData = Map.of(data);
                                        CartVar.processedData['profit'] = CartVar.profitProductContr.numberValue - CartVar.processedData['capital'];
                                        CartVar.processedData['amount'] = CartVar.amountProductContr.text;
                                        CartVar.processedData['datetime'] = DateTime.now().toString();
                                      });

                                      Map results = await cartBloc.submitToCart(CartVar.processedData);
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
                            ],
                          )
                        ],
                      ),
                    )
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  //fungsi untuk menampilkan list produk
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
            CartVar.profitSet = numberToCurrency(data[index]['profit']+data[index]['capital'], "ID", "Rp", 0, "double");
            return Material(
              child: Ink(
                decoration: BoxDecoration(
                  color: Colors.grey
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
                                    child: Text(CartVar.profitSet),
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
                                    backgroundColor: Colors.redAccent,
                                  ),
                                  child: Text(
                                      "Hapus",
                                      style: TextStyle(color: Colors.white)
                                  ),
                                  onPressed: () async {
                                    cartBloc.deleteDataCart(data[index]);
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

  //inisialisasi awal tampilan cart
  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit:FlexFit.loose,
      flex: 8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            flex: 1,
            fit: FlexFit.loose,
            child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(10.0),
                child: TextField(
                  controller: CartVar.searchContr,
                  onChanged: (text){
                    cartBloc.applySearchFilters(text);
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Cari disini . . .',
                  ),
                )
            ),
          ),
          //panggil stream, maka data akan langsung update
          //ketika terjadi perubahan data di back-end
          Flexible(
            flex: 8,
            fit: FlexFit.tight,
            child: StreamBuilder(
                stream: cartBloc.cartData,
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
                  if(snapshot.data.length == 0 && CartVar.searchContr.text.length > 0){
                    return Text("Data pencarian tidak ada atau Kosong");
                  }
                  else if(snapshot.data.length == 0 && CartVar.searchContr.text.length == 0){
                    return Text("Cart kosong");
                  }
                  else{
                    return listViewProduct(snapshot.data);
                  }
                }
            ),
          ),
          Flexible(
            flex:1,
            fit:FlexFit.loose,
            child: StreamBuilder(
              stream: cartBloc.enableButton,
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
                return Row(
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
                            backgroundColor: snapshot.data ? Color(0xFFE3E3E3) : Colors.grey,
                          ),
                          child: Text(
                              "Batalkan",
                              style: TextStyle(
                                  color: snapshot.data ? Colors.redAccent : Colors.white
                              )
                          ),
                          onPressed: () {
                            if(snapshot.data == false){
                              return null;
                            }

                            return cancelAllCart(context);
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
                            backgroundColor: snapshot.data ? Color(0xFFE3E3E3) : Colors.grey,
                          ),
                          child: Text(
                              "Submit",
                              style: TextStyle(
                                  color: snapshot.data ? Colors.blue : Colors.white
                              )
                          ),
                          onPressed: () async{
                            if(snapshot.data == false){
                              return null;
                            }
                            return submitAllCart(context, await cartBloc.calcCart());
                          },
                        ),
                      ),
                    ),
                  ],
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}
