import 'package:flutter/material.dart';

class JumlahService extends ChangeNotifier {
  int _jumlah = 0;
  int get jumlah => _jumlah;
  set jumlah(int value) {
    _jumlah = value;
    notifyListeners();
  }
}
