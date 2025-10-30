import 'package:flutter/material.dart';
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
