//core & plugins
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Color parseColor(String color) {
  String hex = color.replaceAll("#", "");
  if (hex.isEmpty) hex = "ffffff";
  if (hex.length == 3) {
    hex =
    '${hex.substring(0, 1)}${hex.substring(0, 1)}${hex.substring(1, 2)}${hex.substring(1, 2)}${hex.substring(2, 3)}${hex.substring(2, 3)}';
  }
  Color col = Color(int.parse(hex, radix: 16)).withOpacity(1.0);
  return col;
}

String currencyToNumber(var text, String format){

  if(text == "" || format == ""){
    return "null";
  }

  //convert to string if
  if(text is int){
    text = text.toString();
  }
  else if(text is TextEditingController){
    text = text.text;
  }
  else{
    //do nothing
  }

  String results = "";

  if(format == 'int'){
    results = int.parse(text.replaceAll(new RegExp(r'[^0-9]'),'')).toString();
  }
  else if(format == 'double'){
    results = double.parse(text.replaceAll(new RegExp(r'[^0-9]'),'')).toString();
  }

  return results;
}

String numberToCurrency(var text, String locale, String symbol, int digits, String format){
  // ProductVar.searchController.text = NumberFormat.currency(locale: "ID", symbol: "", decimalDigits: 0).format(int.parse(ProductVar.searchController.text.toString()));
  if(format == "" || locale == "" || text == ""){
    return "null";
  }

  //convert to string if
  if(text is int){
    text = text.toString();
  }
  else if(text is TextEditingController){
    text = text.text;
  }
  else{
    //do nothing
  }

  //convert currency
  NumberFormat converter = NumberFormat.currency(locale: locale, symbol: symbol, decimalDigits: digits);
  String results = "";
  if(format == 'int' || format == 'INT'){
    results = converter.format(int.parse(text.toString())).toString();
  }
  else if(format == 'double' || format == 'DOUBLE'){
    results = converter.format(double.parse(text.toString())).toString();
  }

  return results;
}

/// Mask for monetary values.
/// Copyright (c) 2018 Ben-hur Ott
/// modified by TRXDev
class MoneyMaskedTextController extends TextEditingController {
  MoneyMaskedTextController(
      {double initialValue = 0.0,
        this.decimalSeparator = ',',
        this.thousandSeparator = '.',
        this.rightSymbol = '',
        this.leftSymbol = '',
        this.precision = 2}) {
    _validateConfig();

    this.addListener(() {
      this.updateValue(this.numberValue);
      this.afterChange(this.text, this.numberValue);
    });

    this.updateValue(initialValue);
  }

  final String decimalSeparator;
  final String thousandSeparator;
  final String rightSymbol;
  final String leftSymbol;
  final int precision;

  Function afterChange = (String maskedValue, double rawValue) {};

  double _lastValue = 0.0;

  void updateValue(double value) {
    double valueToUse = value;

    if (value.toStringAsFixed(0).length > 12) {
      valueToUse = _lastValue;
    } else {
      _lastValue = value;
    }

    String masked = this._applyMask(valueToUse);

    if (rightSymbol.length > 0) {
      masked += rightSymbol;
    }

    if (leftSymbol.length > 0) {
      masked = leftSymbol + masked;
    }

    if (masked != this.text) {
      this.text = masked;

      var cursorPosition = super.text.length - this.rightSymbol.length;
      this.selection = new TextSelection.fromPosition(
          new TextPosition(offset: cursorPosition));
    }
  }

  double get numberValue {
    List<String> parts =
    _getOnlyNumbers(this.text).split('').toList(growable: true);

    parts.insert(parts.length - precision, '.');

    String allParts = parts.join();

    //check on null
    if(allParts == "." || allParts == ""){
      allParts = "0.0";
    }

    double results = double.parse(allParts);
    return results;
  }

  _validateConfig() {
    bool rightSymbolHasNumbers = _getOnlyNumbers(this.rightSymbol).length > 0;

    if (rightSymbolHasNumbers) {
      throw new ArgumentError("rightSymbol must not have numbers.");
    }
  }

  String _getOnlyNumbers(String text) {
    String cleanedText = text;

    var onlyNumbersRegex = new RegExp(r'[^\d]');

    cleanedText = cleanedText.replaceAll(onlyNumbersRegex, '');

    return cleanedText;
  }

  String _applyMask(double value) {
    List<String> textRepresentation = value
        .toStringAsFixed(precision)
        .replaceAll('.', '')
        .split('')
        .reversed
        .toList(growable: true);

    textRepresentation.insert(precision, decimalSeparator);

    for (var i = precision + 4; true; i = i + 4) {
      if (textRepresentation.length > i) {
        textRepresentation.insert(i, thousandSeparator);
      } else {
        break;
      }
    }

    return textRepresentation.reversed.join('');
  }
}


