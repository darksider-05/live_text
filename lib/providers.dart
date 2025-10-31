import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:shared_preferences/shared_preferences.dart';
import 'names.dart';

class Navigation extends ChangeNotifier {
  final controller = PageController();
  int currentpage = 0;

  void changepage(int targetpage) {
    if (currentpage != targetpage) {
      currentpage = targetpage;
      controller.animateToPage(
        targetpage,
        curve: Curves.decelerate,
        duration: Duration(milliseconds: 350),
      );
      notifyListeners();
    }
  }
}

class General extends ChangeNotifier {
  bool busy = false;
  String name = "";
  int firstName = 0;
  int lastName = 0;
  String current = "";
  bool ready = false;
  bool setf = false;

  void initName() {
    List a = naime().split("|");
    name = a[0];
    firstName = int.tryParse(a[1]) ?? 0;
    lastName = int.tryParse(a[2]) ?? 0;
    notifyListeners();
  }

  void updateNameFromIndices() {
    name = "${techWords[firstName]}${natureWords[lastName]}";
    notifyListeners();
  }

  void mready(int n) {
    if (n == 0) {
      ready = false;
    } else if (n == 1) {
      ready = true;
    }
    notifyListeners();
  }

  void undo() {
    busy = !busy;
    notifyListeners();
  }

  void setName(String neww, String first, String last) {
    if (neww != "") {
      name = neww;
      firstName = int.parse(first);
      lastName = int.parse(last);
      notifyListeners();
    }
  }

  void unset() {
    setf = !setf;
    notifyListeners();
  }
}

class Palette extends ChangeNotifier {
  Color primary = Color(0xff00BCD4);
  Color primaryl = Color(0xff62EFFF);
  Color primaryd = Color(0xff008BA3);
  Color secondary = Color(0xFF1ED2A5);
  Color accent = Color(0xffFF4081);
  Map<String, Color>? current;
  bool dark = true;

  Palette() {
    current = {
      "primary": dark ? primaryd : primaryl,
      "notp": !dark ? primaryl : primaryl,
      "secondary": secondary,
      "accent": accent,
      "text": Color(0xffffffff),
      "untext": Color(0xff000000),
      "background": Color(0xff303030),
      "bgtint": dark
          ? Color(0xff000000).withAlpha(50)
          : Color(0xffffffff).withAlpha(50),
    };
  }

  void setColor(String theme) {
    if (theme == "dark") {
      md();
    } else if (theme == "bright") {
      mb();
    }
  }

  void md() {
    dark = true;
    current = {
      "primary": dark ? primaryd : primaryl,
      "notp": !dark ? primaryl : primaryl,
      "secondary": secondary,
      "accent": accent,
      "text": Color(0xffffffff),
      "untext": Color(0xff000000),
      "background": Color(0xff303030),
      "bgtint": dark
          ? Color(0xff000000).withAlpha(50)
          : Color(0xffffffff).withAlpha(50),
    };
    notifyListeners();
  }

  void mb() {
    dark = false;
    current = {
      "primary": dark ? primaryd : primaryl,
      "notp": !dark ? primaryl : primaryl,
      "secondary": secondary,
      "accent": accent,
      "text": Color(0xff000000),
      "untext": Color(0xffffffff),
      "background": Color(0xffcfcfcf),
      "bgtint": dark
          ? Color(0xff000000).withAlpha(50)
          : Color(0xffffffff).withAlpha(50),
    };
    notifyListeners();
  }
}
