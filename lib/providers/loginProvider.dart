import 'package:flutter/cupertino.dart';

class SecureText extends ChangeNotifier {
  bool _secureText = true;
  bool get secureText => _secureText;
  set secureText(bool value) {
    _secureText = !_secureText;
    notifyListeners();
  }
}
