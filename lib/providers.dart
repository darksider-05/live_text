import 'package:flutter/material.dart';

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
  String current = "";
  bool ready = false;

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

  bool setname(String neew) {
    if (neew != "") {
      name = neew;
      notifyListeners();
      return true;
    }
    return false;
  }
}
