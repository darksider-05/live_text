import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers.dart';
import 'package:livetext/names.dart';

class Sp extends StatefulWidget {
  final General general;
  final Palette theme;
  final Navigation navigation;

  const Sp({
    super.key,
    required this.general,
    required this.navigation,
    required this.theme,
  });

  @override
  State<Sp> createState() => _SpState();
}

class _SpState extends State<Sp> {
  int first = 0;
  int second = 0;
  FixedExtentScrollController? _controller1;
  FixedExtentScrollController? _controller2;
  void saven() async {
    final settings = await SharedPreferences.getInstance();
    await settings.setString(
      "name",
      "${widget.general.name}|${widget.general.firstName}|${widget.general.lastName}",
    );
  }

  @override
  void initState() {
    super.initState();
    first = widget.general.firstName;
    second = widget.general.lastName;
    _controller1 = FixedExtentScrollController(initialItem: first);
    _controller2 = FixedExtentScrollController(initialItem: second);
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.shortestSide;
    var height = MediaQuery.of(context).size.longestSide;
    bool isver = MediaQuery.of(context).orientation == Orientation.portrait;
    var truewidth = isver ? width : height;
    var trueheight = isver
        ? height - kBottomNavigationBarHeight
        : width - kBottomNavigationBarHeight;

    return Container(
      color: widget.theme.current!["background"],
      child: Column(
        spacing: truewidth * 0.02,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(width: truewidth),
          Row(
            spacing: truewidth * 0.02,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: truewidth * 0.3,
                height: trueheight * 0.3,
                child: CupertinoPicker(
                  looping: true,
                  scrollController: _controller1,
                  itemExtent: 32,
                  onSelectedItemChanged: (index) {
                    first = index;
                    widget.general.firstName = index;
                    widget.general.updateNameFromIndices();
                    saven();
                  },
                  children: techWords
                      .map(
                        (val) => Center(
                          child: Text(
                            val,
                            style: TextStyle(
                              color: widget.theme.current!["text"],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),

              SizedBox(
                width: truewidth * 0.3,
                height: trueheight * 0.3,
                child: CupertinoPicker(
                  looping: true,
                  scrollController: _controller2,
                  itemExtent: 32,
                  onSelectedItemChanged: (index) {
                    second = index;
                    widget.general.lastName = index;
                    widget.general.updateNameFromIndices();
                    saven();
                  },
                  children: natureWords
                      .map(
                        (val) => Center(
                          child: Text(
                            val,
                            style: TextStyle(
                              color: widget.theme.current!["text"],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),

          SizedBox(height: truewidth * 0.1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: () async {
                  widget.theme.mb();
                  final settings = await SharedPreferences.getInstance();
                  await settings.setString("theme", "bright");
                },
                icon: Row(
                  children: [
                    Icon(Icons.circle, color: Color(0xffcfcfcf)),
                    Text(
                      " bright theme",
                      style: TextStyle(color: Color(0xffcfcfcf)),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  widget.theme.md();
                  final settings = await SharedPreferences.getInstance();
                  await settings.setString("theme", "dark");
                },
                icon: Row(
                  children: [
                    Icon(Icons.circle, color: Color(0xff303030)),
                    Text(
                      " dark theme",
                      style: TextStyle(color: Color(0xff303030)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                !widget.theme.dark
                    ? widget.theme.current!["secondary"]
                    : widget.theme.current!["accent"],
              ),
            ),
            onPressed: () {
              setState(() {
                widget.general.initName(); // updates firstName and lastName
                first = widget.general.firstName;
                second = widget.general.lastName;
                _controller1?.animateToItem(
                  first,
                  duration: Duration(milliseconds: 1000),
                  curve: Curves.easeOut,
                );
                _controller2?.animateToItem(
                  second,
                  duration: Duration(milliseconds: 1000),
                  curve: Curves.easeOut,
                );
              });

              saven();
            },

            child: Icon(Icons.casino, color: widget.theme.current!["text"]),
          ),

          FloatingActionButton(
            backgroundColor: widget.theme.current!["primary"],
            child: Text(
              "Done",
              style: TextStyle(color: widget.theme.current!["text"]),
            ),
            onPressed: () {
              widget.general.unset();
            },
          ),
        ],
      ),
    );
  }
}
