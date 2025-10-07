import 'package:flutter/material.dart';
import 'package:live_text/bottom_navigation_bar.dart';
import 'package:live_text/pages/joinp.dart';
import 'package:provider/provider.dart';
import 'providers.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Navigation()),
        ChangeNotifierProvider(create: (_) => Lobby()),
        ChangeNotifierProvider(create: (_) => General()),
      ],
      child: Ma(),
    ),
  );
}

class Ma extends StatelessWidget {
  const Ma({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<Navigation>();
    final router = context.watch<Lobby>();
    final general = context.watch<General>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        bottomNavigationBar: Bar(nav: nav),
        body: Pv(nav: nav, router: router, general: general),
      ),
    );
  }
}

class Pv extends StatelessWidget {
  final Navigation nav;
  final Lobby router;
  final General general;
  const Pv({
    super.key,
    required this.nav,
    required this.router,
    required this.general,
  });

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: nav.controller,
      physics: NeverScrollableScrollPhysics(),
      children: [
        nav.currentpage != 1
            ? Jp(nav: nav, router: router, general: general)
            : Jp(nav: nav, router: router, general: general),
        nav.currentpage == 1
            ? Container(color: Colors.amber)
            : Container(color: Colors.amber),
      ],
    );
  }
}
