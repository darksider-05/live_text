import 'package:flutter/material.dart';
import 'package:live_text/bottom_navigation_bar.dart';
import 'package:live_text/pages/hostp.dart';
import 'package:live_text/pages/joinp.dart';
import 'package:live_text/pages/lobby.dart';
import 'package:live_text/pages/setp.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Navigation()),
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
    final general = context.watch<General>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scf(nav: nav, general: general),
    );
  }
}

class Scf extends StatefulWidget {
  final Navigation nav;
  final General general;
  const Scf({super.key, required this.nav, required this.general});

  @override
  State<Scf> createState() => _ScfState();
}

class _ScfState extends State<Scf> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    saveLoad(widget.general);
  }

  Future<void> saveLoad(General general) async {
    //TODO: not complete: colors
    final settings = await SharedPreferences.getInstance();
    List name = await settings.getString("name")?.split("|") ?? ["", "", ""];
    String color = await settings.getString("colors") ?? "";
    general.initName();
    general.setName(name[0], name[1], name[2]);
    await settings.setString(
      "name",
      "${general.name}|${general.firstName}|${general.lastName}",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: !widget.general.setf ? Bar(nav: widget.nav) : null,
      body: Pv(nav: widget.nav, general: widget.general),
    );
  }
}

class Pv extends StatefulWidget {
  final Navigation nav;
  final General general;
  const Pv({super.key, required this.nav, required this.general});

  @override
  State<Pv> createState() => _PvState();
}

class _PvState extends State<Pv> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.shortestSide;
    var height = MediaQuery.of(context).size.longestSide;
    bool isver = MediaQuery.of(context).orientation == Orientation.portrait;
    var truewidth = isver ? width : height;
    var trueheight = isver
        ? height - kBottomNavigationBarHeight
        : width - kBottomNavigationBarHeight;

    return Stack(
      children: [
        !widget.general.setf
            ? PageView(
                controller: widget.nav.controller,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  widget.nav.currentpage != 1
                      ? widget.general.ready
                            ? Jp(general: widget.general)
                            : Lb(nav: widget.nav, general: widget.general)
                      : Lb(nav: widget.nav, general: widget.general),
                  widget.nav.currentpage == 1
                      ? Hp(nav: widget.nav, general: widget.general)
                      : Hp(nav: widget.nav, general: widget.general),
                ],
              )
            : Container(),

        !widget.general.setf
            ? Positioned(
                top: trueheight * 0.08,
                right: truewidth * 0.06,
                child: IconButton(
                  onPressed: () {
                    widget.general.unset();
                  },
                  icon: Icon(Icons.settings, color: Colors.white),
                ),
              )
            : Container(),

        widget.general.setf
            ? Sp(general: widget.general, navigation: widget.nav)
            : Container(),
      ],
    );
  }
}
