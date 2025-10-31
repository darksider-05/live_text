import 'package:flutter/material.dart';
import 'providers.dart';
import 'dart:math';

class Bar extends StatelessWidget {
  final Navigation nav;
  final Palette theme;
  const Bar({super.key, required this.nav, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.current!["background"]?.withAlpha(200),
        enableFeedback: false,
        currentIndex: nav.currentpage,
        selectedItemColor: theme.current!["text"],
        unselectedItemColor: theme.current!["untext"],
        onTap: (value) {
          nav.changepage(value);
        },
        items: [
          BottomNavigationBarItem(
            label: "join",
            icon: Transform.rotate(angle: pi / 2, child: Icon(Icons.sync_alt)),
          ),
          BottomNavigationBarItem(
            label: "host",
            icon: Icon(Icons.wifi_tethering),
          ),
        ],
      ),
    );
  }
}
