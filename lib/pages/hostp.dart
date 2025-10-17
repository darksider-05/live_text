import 'package:flutter/material.dart';
import 'package:live_text/providers.dart';

// ignore: must_be_immutable
class Hp extends StatefulWidget {
  Navigation nav;
  Hp({super.key, required this.nav});

  @override
  State<Hp> createState() => _HpState();
}

class _HpState extends State<Hp> {
  bool sure = true;
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.shortestSide;
    var height = MediaQuery.of(context).size.longestSide;
    bool isver = MediaQuery.of(context).orientation == Orientation.portrait;
    var truewidth = isver ? width : height;
    var trueheight = isver
        ? height - kBottomNavigationBarHeight
        : width - kBottomNavigationBarHeight;

    List clients = [];

    return sure
        ? Container(
            width: truewidth,
            height: trueheight,
            color: Colors.blueGrey[800],
            child: Column(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: truewidth),
                Text("start hosting?"),
                FloatingActionButton(
                  onPressed: () {
                    setState(() {
                      sure = false;
                    });
                  },
                  child: Text("yes"),
                ),
              ],
            ),
          )
        : Stack(
            children: [
              Container(
                color: Colors.black87,
                height: trueheight,
                width: truewidth,
                child: Transform.translate(
                  offset: Offset(0, trueheight * -1 * 0.1),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      width: truewidth * 0.65,
                      height: trueheight * 0.5,

                      child: TextField(
                        controller: TextEditingController(),
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(border: InputBorder.none),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                left: truewidth * 0.06,
                top: trueheight * 0.09,
                child: Row(
                  children: [
                    Text(
                      "connected devices: ${clients.length}",
                      style: TextStyle(color: Colors.tealAccent),
                    ),
                  ],
                ),
              ),

              Positioned(
                top: trueheight * 0.75,
                height: trueheight * 0.1,
                width: truewidth,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FloatingActionButton.extended(
                      onPressed:
                          null, //////////////////////////////////////////////////
                      label: Text("auto clipboard"),
                    ),
                    FloatingActionButton.extended(
                      onPressed:
                          null, /////////////////////////////////////////////////
                      label: Text("copy to clipboard"),
                    ),
                  ],
                ),
              ),
            ],
          );
  }
}
