import 'package:flutter/material.dart';
import 'package:live_text/bottom_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'providers.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => Navigation())],
      child: Ma(),
    ),
  );
}

class Ma extends StatelessWidget {
  const Ma({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<Navigation>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        bottomNavigationBar: Bar(nav: nav),
        body: Pv(nav: nav),
      ),
    );
  }
}

class Pv extends StatelessWidget {
  final Navigation nav;
  const Pv({super.key, required this.nav});

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: nav.controller,
      physics: NeverScrollableScrollPhysics(),
      children: [
        nav.currentpage == 0
            ? Container(color: Colors.teal)
            : Container(color: Colors.green),
        nav.currentpage == 1
            ? Container(color: Colors.amber)
            : Container(color: Colors.pink),
      ],
    );
  }
}
