import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

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

class Lobby extends ChangeNotifier {
  List<String> hosts = ["hhhhhhhhh", "gggjydj"];

  void add(String neew) {
    hosts.add(neew);
    _safeNotify();
  }

  void remove(String target) {
    hosts.remove(target);
    _safeNotify();
  }

  void clean() {
    hosts = [];
    _safeNotify();
  }

  void _safeNotify() {
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }
}

class General extends ChangeNotifier {
  bool busy = false;
  String name = "";
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
