import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:livetext/ipgetter.dart';
import 'package:livetext/providers.dart';
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
  bool _dispose = false;

  @override
  void dispose() {
    Clipboard.setData(ClipboardData(text: ""));
    _dispose = true;
    _client?.sink.close();

    _httpserver?.close(force: true);
    _httpserver = null;
    _udpserver?.close();
    _udpserver = null;

    super.dispose();
  }

  ///  starts the websocket server <br>
  ///  stops the upd server also, not lettign others connect to it.<br>
  ///  if the someone was connected before, no one will be allowed to connect
  ///
  void startTcp() async {
    // initializes the handler to set up the websocket server
    final handler = webSocketHandler((WebSocketChannel channel, _) {
      // when a new client connects:
      if (_client == null) {
        _udpserver?.close();
        _udpserver = null;

        setState(() {
          _client = channel;
        });

        // Send the current text to the new client
        final initialMessage = json.encode({
          "hint": "FU",
          "content": controller.text,
        });
        channel.sink.add(initialMessage);
      }

      // listes for incoming messages:
      channel.stream.listen(
        (message) {
          final decoded = jsonDecode(message);
          if (decoded["hint"] == "GU") {
            setState(() {
              controller.text = decoded["content"];
            });
            if (clip) Clipboard.setData(ClipboardData(text: controller.text));
          }
        },

        // handles the client disconnecting
        onDone: () {
          setState(() {
            _client = null;
          });

          if (_udpserver == null && !_dispose) {
            startUdp();
          }
        },
        onError: (error) {
          // handles errors and remove the client:
          setState(() {
            _client = null;
          });

          if (_udpserver == null && !_dispose) {
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
    final selfip = await NetworkInfo().getWifiIP() ?? await LocalIp.get();
    if (selfip.toString() == "0.0.0.0") {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "something went wrong with getting the ip, please retry",
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
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
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    sure = false;
                  });
                  startTcp();
                  startUdp();
                },
                style: ElevatedButton.styleFrom(
                  elevation: 10,
                  backgroundColor: widget.theme.current!["bgtint"],
                ),
                child: Text(
                  "start hosting",
                  style: TextStyle(
                    color: widget.theme.current!["text"],
                    fontSize: 17,
                  ),
                ),
              ),
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
                          Clipboard.setData(
                            ClipboardData(text: controller.text),
                          );
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
