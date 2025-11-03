import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
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
  Palette theme;
  Hp({
    super.key,
    required this.nav,
    required this.general,
    required this.theme,
  });

  @override
  State<Hp> createState() => _HpState();
}

class _HpState extends State<Hp> {
  HttpServer? _httpserver;
  RawDatagramSocket? _udpserver;
  WebSocketChannel? _client;
  bool sure = true;
  var controller = TextEditingController();
  bool clip = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    startTcp();
    startUdp();
  }

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
    if (clip) Clipboard.setData(ClipboardData(text: controller.text));

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
            color: widget.theme.current!["primary"],
            child: Column(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: truewidth),
                Text(
                  "start hosting?",
                  style: TextStyle(color: widget.theme.current!["text"]),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: widget.theme.current!["bgtint"],
                  ),
                  width: (min(truewidth, trueheight) * 0.2),
                  height: (min(truewidth, trueheight) * 0.2),
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        sure = false;
                      });
                      //startTcp();
                      //startUdp();
                    },
                    icon: Text(
                      "yes",
                      style: TextStyle(
                        color: widget.theme.current!["text"],
                        fontSize: 17,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        : Stack(
            children: [
              Container(
                color: widget.theme.current!["background"],
                height: trueheight,
                width: truewidth,
                child: Transform.translate(
                  offset: Offset(0, trueheight * -1 * 0.1),
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: widget.theme.current!["bgtint"],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      width: truewidth * 0.65,
                      height: trueheight * 0.5,

                      child: TextField(
                        controller: controller,
                        onChanged: (value) {
                          broadcast();
                        },
                        style: TextStyle(color: widget.theme.current!["text"]),
                        cursorColor: widget.theme.primary,
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
                      style: TextStyle(color: widget.theme.primary),
                    ),
                  ],
                ),
              ),

              Positioned(
                top: trueheight * 0.75,
                height: trueheight * 0.1,
                width: truewidth,
                child: Row(
                  spacing: truewidth * 0.01,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FloatingActionButton.extended(
                      backgroundColor: clip
                          ? widget.theme.current!["primary"]
                          : widget.theme.current!["accent"],
                      onPressed: () {
                        setState(() {
                          clip = !clip;
                        });
                      },
                      label: Text(
                        clip ? "copy on" : "copy off",
                        style: TextStyle(color: widget.theme.current!["text"]),
                      ),
                    ),
                    FloatingActionButton.extended(
                      backgroundColor: widget.theme.current!["secondary"],
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: controller.text));
                      },
                      label: Text(
                        "copy text",
                        style: TextStyle(color: widget.theme.current!["text"]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
  }
}
