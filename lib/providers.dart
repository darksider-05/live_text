import 'package:flutter/material.dart';

class Navigation extends ChangeNotifier {
  final controller = PageController();
  int currentpage = 0;

  void changepage(int targetpage) {
    if (currentpage != targetpage) {
      currentpage = targetpage;
      controller.animateToPage(
        curve: Curves.linear,
        duration: Duration(milliseconds: 300),
        targetpage,
      );
      notifyListeners();
    }
  }
}

class Lobby extends ChangeNotifier {
  List<String> hosts = ["ssssssssss", "rrrrrrrrrrsdsf", "ssssssssss"];

  void add(String neew) {
    hosts.add(neew);
    notifyListeners();
  }

  void remove(String target) {
    hosts.remove(target);
    notifyListeners();
  }

  void clean() {
    hosts = [];
    notifyListeners();
  }
}

class General extends ChangeNotifier {
  bool busy = false;
  void undo() {
    busy = !busy;
    notifyListeners();
  }
}
