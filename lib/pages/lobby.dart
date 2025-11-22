import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:livetext/ipgetter.dart';
import 'package:livetext/providers.dart';
import 'package:network_info_plus/network_info_plus.dart';

// ignore: must_be_immutable
class Lb extends StatefulWidget {
  final Navigation nav;
  final General general;
  final Palette theme;
  Lb({
    super.key,
    required this.nav,
    required this.general,
    required this.theme,
  });

  @override
  State<Lb> createState() => _LbState();
}

class _LbState extends State<Lb> {
  RawDatagramSocket? _udpclient;
  final _hosts = [];
  double progress = 0;
  int current = 0;
  int end = 254;

  @override
  void initState() {
    super.initState();
    final nav = widget.nav;
    if (nav.currentpage == 0) {
      start();
    }
  }

  void start() async {
    _udpclient?.close();
    _udpclient = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    _udpclient?.listen((event) {
      if (event == RawSocketEvent.read) {
        final dg = _udpclient?.receive();
        if (dg != null) {
          final msg = utf8.decode(dg.data);
          final lst = msg.split("|").toList();
          if (lst[0] == "pong") {
            setState(() {
              _hosts.add({"name": lst[1], "ip": lst[2]});
            });
          }
        }
      }
    });
  }

  Future<void> scout(General general) async {
    _hosts.clear();
    general.busy = true;
    final selfip = await NetworkInfo().getWifiIP() ?? await LocalIp.get();
    if (selfip.toString() == "0.0.0.0") {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("something went wrong with getting the ip"),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
    var iplist = selfip.split(".").toList();
    iplist = iplist.sublist(0, 3);
    final subnet = iplist.join(".");
    setState(() {
      progress = 0;
      current = 0;
    });

    await Future.forEach<int>(List.generate(254, (i) => i + 1), (sub) async {
      _udpclient?.send(
        utf8.encode("ping"),
        InternetAddress("$subnet.$sub"),
        50987,
      );
      await Future.delayed(Duration(milliseconds: 15));
      setState(() {
        current += 1;
        progress = current / end;
      });
    });
    general.busy = false;
  }

  @override
  void dispose() {
    _hosts.clear();
    _udpclient?.close();
    _udpclient = null;
    widget.general.busy = false;
    super.dispose();
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
      width: truewidth,
      height: trueheight,
      color: widget.theme.current!["background"],
      child: Column(
        spacing: trueheight * 0.01,
        children: [
          SizedBox(height: trueheight * 0.1),
          Container(
            decoration: BoxDecoration(
              color: widget.theme.current!["bgtint"],
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
                    Icons.refresh_rounded,
                    size: 28,
                    color: widget.general.busy
                        ? widget.theme.current!["primary"]
                        : widget.theme.current!["text"],
                  ),
                  onPressed: () async {
                    widget.general.busy ? null : scout(widget.general);
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.clear_all_rounded,
                    size: 28,
                    color: widget.theme.current!["text"],
                  ),
                  onPressed: () {
                    setState(() {
                      _hosts.clear();
                    });
                  },
                ),
              ],
            ),
          ),

          widget.general.busy
              ? LinearProgressIndicator(
                  backgroundColor: Colors.transparent,
                  value: progress,
                  color: widget.theme.primary,
                )
              : Container(),

          _hosts.isNotEmpty
              ? Expanded(
                  child: ListView.builder(
                    itemCount: _hosts.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.fromLTRB(0, 2.5, 0, 2.5),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: EdgeInsets.only(left: truewidth * 0.05),
                            child: GestureDetector(
                              onTap: () {
                                widget.general.current =
                                    _hosts[index]["ip"] ?? "";
                                widget.general.mready(1);
                              },

                              child: Container(
                                width: truewidth * 0.75,
                                height: trueheight * 0.09,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: widget.theme.current!["primary"],
                                ),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      left: truewidth * 0.15,
                                    ),
                                    child: Text(
                                      _hosts[index]["ip"] != "0.0.0.0"
                                          ? _hosts[index]["name"] ?? "error"
                                          : "self ip error on host't side",
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: widget.theme.current!["text"],
                                      ),
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
              : Container(
                  width: truewidth * 0.75,
                  height: trueheight * 0.09,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: widget.theme.current!["primary"],
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
                              color: widget.theme.current!["text"],
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.refresh_rounded,
                              size: 22,
                              color: widget.theme.current!["text"],
                            ),
                            onPressed: () async {
                              widget.general.busy
                                  ? null
                                  : scout(widget.general);
                            },
                          ),
                          Text(
                            " icon to search",
                            style: TextStyle(
                              color: widget.theme.current!["text"],
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
