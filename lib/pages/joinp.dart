import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:live_text/providers.dart';
import 'package:network_info_plus/network_info_plus.dart';

class Jp extends StatefulWidget {
  final Navigation nav;
  final Lobby router;
  final General general;
  Jp({
    super.key,
    required this.nav,
    required this.router,
    required this.general,
  });

  @override
  State<Jp> createState() => _JpState();
  RawDatagramSocket? _udpclient;
}

class _JpState extends State<Jp> {
  @override
  void initState() {
    super.initState();
    final nav = widget.nav;
    if (nav.currentpage == 0) {
      /////////////////////////////////////////////////////////////////////////// start();
    }
  }

  void start() async {
    widget._udpclient = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      0,
    );
    widget._udpclient?.listen((event) {
      if (event == RawSocketEvent.read) {
        final dg = widget._udpclient?.receive();
        if (dg != null) {
          final msg = utf8.decode(dg.data);
          final lst = msg.split("|").toList();
          if (lst[0] == "pong") {
            final target = lst[1];
            widget.router.add(
              "$target:50987",
            ); // this is the port that the udp servers will be on
          }
        }
      }
    });
  }

  Future<void> scout(General general) async {
    general.busy = true;
    final selfip = await NetworkInfo().getWifiIP() ?? "0.0.0.0";
    var iplist = selfip.split(".").toList();
    iplist = iplist.sublist(0, 3);
    final subnet = iplist.join(".");

    await Future.forEach<int>(List.generate(254, (i) => i + 1), (sub) async {
      widget._udpclient?.send(
        utf8.encode("ping"),
        InternetAddress("$subnet.$sub"),
        2022,
      );
      await Future.delayed(Duration(milliseconds: 5));
    });
    general.busy = false;
  }

  @override
  void dispose() {
    super.dispose();
    widget.router.clean();
  }

  @override
  Widget build(BuildContext context) {
    final router = widget.router;
    var width = MediaQuery.of(context).size.shortestSide;
    var height = MediaQuery.of(context).size.longestSide;
    bool isver = MediaQuery.of(context).orientation == Orientation.portrait;
    var truewidth = isver ? width : height;
    var trueheight = isver
        ? height - kBottomNavigationBarHeight
        : width - kBottomNavigationBarHeight;

    return Container(
      width: truewidth,
      height: trueheight,
      color: Colors.black87,
      child: Column(
        children: [
          SizedBox(height: trueheight * 0.1),
          Container(
            decoration: BoxDecoration(
              color: Colors.white30,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              spacing: truewidth * 0.01,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.flip_camera_android_sharp,
                    size: 28,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    ///////////////////////////////////////////////////////////scout(widget.general);
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.clear_all_rounded,
                    size: 28,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    router.clean();
                  },
                ),
              ],
            ),
          ),

          router.hosts.isNotEmpty
              ? Expanded(
                  child: ListView.builder(
                    itemCount: router.hosts.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.fromLTRB(0, 2.5, 0, 2.5),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: truewidth * 0.05),
                            child: Container(
                              width: truewidth * 0.75,
                              height: trueheight * 0.09,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.teal,
                              ),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: truewidth * 0.15,
                                  ),
                                  child: Text(
                                    router.hosts[index],
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              : Padding(
                  padding: EdgeInsets.only(top: trueheight * 0.01),
                  child: Container(
                    width: truewidth * 0.75,
                    height: trueheight * 0.09,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.teal,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.only(left: truewidth * 0.15),
                        child: Row(
                          children: [
                            Text(
                              "press the ",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            Icon(
                              Icons.flip_camera_android_rounded,
                              color: Colors.white,
                              size: 25,
                            ),
                            Text(
                              " icon to search",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
