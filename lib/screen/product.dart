//core & plugins
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:barcode_scan2/barcode_scan2.dart';

//helper
import 'package:Cashiera/helper/dialog_helper.dart';
import 'package:Cashiera/helper/format_helper.dart';

//bloc
import 'package:Cashiera/blocs/product_bloc.dart';

//class untuk menampung data sementara produk
class ProductVar{
  static TextEditingController searchController = TextEditingController();
  static final _formKey = GlobalKey<FormState>();

  //input controller
  static MoneyMaskedTextController profitProductContr = MoneyMaskedTextController(leftSymbol: 'Rp', precision: 0, decimalSeparator: '', thousandSeparator: '.');
  static TextEditingController amountProductContr = TextEditingController();
  static Map processedData = {};

  //carousel slider controller
  static CarouselController btnSlider = CarouselController();

  //other data
  static String profitMax = "";
  static String profitMin = "";
}

// stateful widget untuk tampilan dinamis
class Product extends StatefulWidget {
  const Product({Key? key}) : super(key: key);

  @override
  _ProductState createState() => _ProductState();
}

class _ProductState extends State<Product> {
  //inisialisasi BLOC
  ProductBloc productBloc = ProductBloc();

  //modal untuk melihat detail produk
  void productDetailModal(BuildContext context, Map data){
    //processed data
    ProductVar.profitMax = (data['capital']+data['profit_max']).toString();
    ProductVar.profitMin = (data['capital']+data['profit_min']).toString();
    ProductVar.amountProductContr.text = "1";
    ProductVar.profitProductContr.text = ProductVar.profitMax;

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
              (data['stock'] == 0) ? Container(
                alignment: Alignment.center,
                margin: EdgeInsets.all(5.0),
                child: Text(
                    "Stock Habis",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent
                    )
                ),
              ) : SizedBox(),
              Flexible(
                flex: 1,
                fit: FlexFit.loose,
                child: Form(
                  key: ProductVar._formKey,
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
                              flex: 1,
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
                                  initialValue: data['stock'].toString(),
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                    fillColor: Colors.grey,
                                    filled: true,
                                    labelText: 'Stock',
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.all(5.0),
                          child: TextFormField(
                            readOnly: true,
                            keyboardType: TextInputType.number,
                            initialValue: numberToCurrency(ProductVar.profitMin, "ID", "Rp", 0, "double"),
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
                            controller: ProductVar.profitProductContr,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Harga Set (Maks : '+numberToCurrency(ProductVar.profitMax, "ID", "Rp", 0, "double")+')',
                            ),
                            validator: (value){
                              double value = ProductVar.profitProductContr.numberValue;
                              if(value == 0.0){
                                return "Tolong inputkan harga";
                              }
                              else if(value > double.parse(ProductVar.profitMax)){
                                return "Harga harus sama atau <";
                              }
                              else if(value < double.parse(ProductVar.profitMin)){
                                return "Harga terlalu rendah";
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
                            controller: ProductVar.amountProductContr,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Jumlah Barang',
                            ),
                            validator: (value){
                              if(value == null || value.isEmpty){
                                return "Tolong inputkan jumlah";
                              }
                              else if(int.parse(value) <= 0){
                                return "Barang tidak boleh kosong";
                              }
                              else if(int.parse(value) > data['stock']){
                                return "jumlah harus < stock";
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
                                  backgroundColor: (data['stock'] == 0) ? Colors.grey : Color(0xFFE3E3E3),
                                ),
                                child: Text(
                                    "Submit",
                                    style: TextStyle(color: Colors.blue)
                                ),
                                onPressed: () async{
                                  if(data['stock'] == 0){
                                    return null;
                                  }
                                  else if (ProductVar._formKey.currentState!.validate() && data['stock'] > 0) {
                                    setState((){
                                      ProductVar.processedData = Map.of(data);
                                      ProductVar.processedData['profit'] = ProductVar.profitProductContr.numberValue - ProductVar.processedData['capital'];
                                      ProductVar.processedData['amount'] = ProductVar.amountProductContr.text;
                                      ProductVar.processedData['datetime'] = DateTime.now().toString();
                                    });

                                    Map results = await productBloc.submitToCart(ProductVar.processedData);
                                    Navigator.of(context).pop();
                                    if(results['status'] == true){
                                      dialogBuilder(context, results['notf'], "Baiklah", true, false);
                                    }
                                    else{
                                      dialogBuilder(context, results['notf'], "Baiklah", true, false);
                                    }
                                  }
                                  else{
                                    return null;
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

  //fungsi untuk menampilkan list dari produk
  Widget listViewProduct(List<Map<String, dynamic>> data){
    return ListView.separated(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        padding: EdgeInsets.all(20),
        itemCount: data.length,
        separatorBuilder: (BuildContext context, int index){
          return Divider(height: 5);
        },
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
              onTap: (){
                productDetailModal(context, data[index]);
              },
              splashColor: Colors.blue,
              child: Ink(
                color: (data[index]['stock'] == 0) ? Colors.blueGrey : Colors.grey,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(data[index]['name']),
                        ),
                        SizedBox(
                            height: 5,
                            width:100,
                            child: Container(color: Colors.black)
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Text(data[index]['code']),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: EdgeInsets.all(10),
                          padding: EdgeInsets.all(5),
                          alignment: Alignment.center,
                          height: 40,
                          width: 150,
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
                            physics: ClampingScrollPhysics(),
                            child: Text("Min "+numberToCurrency((data[index]['profit_min']+data[index]['capital']), "ID", "Rp", 0, "int")+""
                                "/ Max "+numberToCurrency((data[index]['profit_max']+data[index]['capital']), "ID", "Rp", 0, "int")),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              )
          );
        }
    );
  }

  //fungsi untuk scan pada kamera (scan QR/BAR code)
  void cameraScan() async {

    var options = ScanOptions(
        android: AndroidOptions(useAutoFocus: false)
    );

    var result = await BarcodeScanner.scan(options: options);

    ProductVar.searchController.text = result.rawContent.toString();
    productBloc.applySearch(ProductVar.searchController.text);
  }

  //inisialisai state / awal
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  //bangun tampilannya
  @override
  Widget build(BuildContext context) {
    //default value
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
                child: StreamBuilder(
                    stream: productBloc.typeDataCarousel,
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
                      return CarouselSlider(
                        options: CarouselOptions(
                            initialPage: snapshot.data['data-index'],
                            height: 65.0,
                            enableInfiniteScroll: false,
                            onPageChanged: (int index, CarouselPageChangedReason reason){
                              productBloc.applyType(index);
                            }
                        ),
                        items: snapshot.data['data-name'].map<Widget>((i) {
                          return Builder(
                            builder: (BuildContext context) {
                              return Container(
                                alignment: Alignment.center,
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.symmetric(horizontal: 10.0),
                                decoration: BoxDecoration(
                                    color: Colors.blue
                                ),
                                child: Text(i),
                              );
                            },
                          );
                        }).toList(),
                      );
                    }
                ),
              ),
              Flexible(
                flex: 1,
                fit: FlexFit.loose,
                child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.all(10.0),
                    child: TextField(
                      controller: ProductVar.searchController,
                      onChanged: (text){
                        productBloc.applySearch(text);
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Cari disini . . .',
                      ),
                    )
                ),
              ),
              Flexible(
                flex: 8,
                fit: FlexFit.tight,
                child: StreamBuilder(
                    stream: productBloc.productData,
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
                      if(snapshot.data.length > 0 && ProductVar.searchController.text.length > 0){
                        return listViewProduct(snapshot.data);
                      }
                      else{
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            (snapshot.data.length == 0 && ProductVar.searchController.text.length > 0) ?
                            Text("Data tidak ada, silahkan cari lagi, atau :", style: TextStyle(color: Colors.orange)) : SizedBox(),
                            SizedBox(height: 30),
                            TextButton(
                              style: TextButton.styleFrom(
                                minimumSize: Size(200.0, 200.0),
                                alignment: Alignment.center,
                                textStyle: const TextStyle(fontSize: 18),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    side: BorderSide(color: Colors.blue, width: 2)
                                ),
                                backgroundColor: Color(0xFFE3E3E3),
                              ),
                              child: Text(
                                  "Scan QR/BR code",
                                  style: TextStyle(color: Colors.blue)
                              ),
                              onPressed: () {
                                cameraScan();
                              },
                            ),
                          ],
                        );
                      }
                    }
                ),
              ),
            ],
          ),
    );
  }
}
