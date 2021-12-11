//core & plugins
import 'package:flutter/material.dart';

//Dynamic dialog
dialogBuilder(context, String notfText, String btnText, bool destroyBefore, bool showLoadingAnim){
  return showDialog(
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
              (showLoadingAnim == true) ? CircularProgressIndicator() : SizedBox(),
              SizedBox(height: 50),
              Text(notfText, textAlign: TextAlign.center),
              SizedBox(height: 15),
              (btnText == null || btnText == "") ? Text("") : TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(16.0),
                  primary: Colors.white,
                  backgroundColor: Colors.blue,
                  textStyle: const TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: (btnText == "") ? SizedBox() : Text(btnText),
              ),
            ],
          ),
        );
      });
    },
  );
}