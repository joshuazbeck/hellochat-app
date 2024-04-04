import 'package:flutter/material.dart';
import 'package:palette_chat/view/chat.dart';
import 'package:palette_chat/extension/color.dart';

class MainViewModel with ChangeNotifier {
  String _userFullname = "";
  late String _userHex;

  MainViewModel() {
    _userHex = HexColor.randomHex();
  }
  // Getters
  String get userFullname => _userFullname;
  Color get userColor {
    return HexColor.fromHex(_userHex);
  }

  String get userHex => _userHex;

  void setUserFullname(String name) {
    _userFullname = name;
    notifyListeners();
  }

  bool _isValid(String hex) {
    try {
      HexColor.fromHex(hex);
      return true;
    } on FormatException {
      return false;
    }
  }

  void setUserHex(String hex) {
    if (!_isValid(hex)) {
      return;
    }
    _userHex = hex;
    notifyListeners();
  }

  String? validateFullname(String? name) {
    if (name == null || name.isEmpty) {
      return "Must specify a fullname";
    }
    return null;
  }

  String? validateUserColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) {
      return "Must specify a color hex";
    }
    if (!_isValid(colorHex)) {
      return "Invalid color. Must be in hex format";
    }
    return null;
  }

  void openChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) =>
              ChatPage(colorHex: userHex, fullname: userFullname)),
    );
  }
}
