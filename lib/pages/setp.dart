import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers.dart';
import 'package:live_text/names.dart';

class Sp extends StatefulWidget {
  final General general;
  final Navigation navigation;

  const Sp({super.key, required this.general, required this.navigation});

  @override
  State<Sp> createState() => _SpState();
}

class _SpState extends State<Sp> {
  int first = 0;
  int second = 0;
  FixedExtentScrollController? _controller1;
  FixedExtentScrollController? _controller2;

  @override
  void initState() {
    // TODO: implement initState
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

    void saven() async {
      final settings = await SharedPreferences.getInstance();
      await settings.setString("name", widget.general.name);
    }

    return Container(
      color: Color(0xFFEDD607),
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
                    saven();
                  },
                  children: techWords
                      .map(
                        (val) => Center(child: Text(val, style: TextStyle())),
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
                    saven();
                  },
                  children: natureWords
                      .map(
                        (val) => Center(child: Text(val, style: TextStyle())),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
          ElevatedButton(
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

            child: Icon(Icons.casino),
          ),

          FloatingActionButton(
            child: Text("Done"),
            onPressed: () {
              widget.general.unset();
            },
          ),
        ],
      ),
    );
  }
}
