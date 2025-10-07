import 'package:flutter/material.dart';
import 'providers.dart';
import 'dart:math';

class Bar extends StatelessWidget {
  final Navigation nav;
  const Bar({super.key, required this.nav});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: nav.currentpage,
      onTap: (value) {
        nav.changepage(value);
      },
      items: [
        BottomNavigationBarItem(
          label: "join",
          icon: Transform.rotate(angle: pi / 2, child: Icon(Icons.sync_alt)),
          backgroundColor: nav.currentpage == 0 ? Colors.blue : Colors.white,
        ),
        BottomNavigationBarItem(
          label: "host",
          icon: Icon(Icons.wifi_tethering),
          backgroundColor: nav.currentpage == 1 ? Colors.blue : Colors.white,
        ),
      ],
    );
  }
}
