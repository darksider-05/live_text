import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:live_text/providers.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

// ignore: must_be_immutable
class Hp extends StatefulWidget {
  Navigation nav;
  General general;
  Hp({super.key, required this.nav, required this.general});

  @override
  State<Hp> createState() => _HpState();
}

class _HpState extends State<Hp> {
  HttpServer? _httpserver;
  RawDatagramSocket? _udpserver;
  WebSocketChannel? _client;
  bool sure = true;
  var controller = TextEditingController();

  @override
  void dispose() {
    _client?.sink.close();

    _httpserver?.close(force: true);
    _httpserver = null;
    _udpserver?.close();
    _udpserver = null;

    super.dispose();
  }

  void startTcp() async {
    final handler = webSocketHandler((WebSocketChannel channel, _) {
      // A new client has connected!
      setState(() {
        _client = channel;
      });

      // Send the current text to the new client
      final initialMessage = json.encode({
        "hint": "FU",
        "content": controller.text,
      });
      channel.sink.add(initialMessage);
      _udpserver?.close();
      _udpserver = null;

      channel.stream.listen(
        (message) {
          final decoded = jsonDecode(message);
          if (decoded["hint"] == "GU") {
            setState(() {
              controller.text = decoded["content"];
            });
            broadcast();
          }
        },

        // 3. Handle the client disconnecting
        onDone: () {
          setState(() {
            _client = null;
          });

          if (_udpserver == null) {
            startUdp();
          }
        },
        onError: (error) {
          // Handle errors and remove the client
          setState(() {
            _client = null;
          });

          if (_udpserver == null) {
            startUdp();
          }
        },
      );
    });

    final pipeline = const Pipeline().addHandler(handler);
    _httpserver = await shelf_io.serve(
      pipeline,
      InternetAddress.anyIPv4,
      50988,
    );
  }

  void startUdp() async {
    final selfip = await NetworkInfo().getWifiIP() ?? "0.0.0.0";
    _udpserver?.close();
    _udpserver = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 50987);
    _udpserver?.listen((event) {
      if (event == RawSocketEvent.read) {
        final dg = _udpserver?.receive();
        if (dg != null) {
          final msg = utf8.decode(dg.data);
          if (msg == "ping") {
            if (_client == null) {
              _udpserver?.send(
                utf8.encode("pong|${widget.general.name}|$selfip"),
                dg.address,
                dg.port,
              );
            }
          }
        }
      }
    });
  }

  void broadcast() {
    final message = json.encode({"hint": "FU", "content": controller.text});

    _client?.sink.add(message);
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
                    //startTcp();
                    //startUdp();
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
                        controller: controller,
                        onChanged: (value) {
                          broadcast();
                        },
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
                      _client != null ? "connected" : "no device connected",
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
