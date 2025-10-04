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
