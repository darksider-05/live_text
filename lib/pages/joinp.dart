import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:livetext/providers.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

// ignore: must_be_immutable
class Jp extends StatefulWidget {
  Navigation nav;
  General general;
  Palette theme;
  Jp({
    super.key,
    required this.nav,
    required this.general,
    required this.theme,
  });

  @override
  State<Jp> createState() => _JpState();
}

class _JpState extends State<Jp> {
  var controller = TextEditingController();
  WebSocketChannel? _channel;
  bool clip = false;

  void startclient(General general) async {
    try {
      final ip = general.current;

      // 1. Connect using the 'ws://' URI scheme
      _channel = IOWebSocketChannel.connect('ws://$ip:50988');
      // 2. Listen for messages from the server
      _channel?.stream.listen(
        (message) {
          final decoded = json.decode(message);
          if (decoded["hint"] == "FU") {
            controller.text = decoded["content"];
            if (clip) Clipboard.setData(ClipboardData(text: controller.text));
          }
        },
        onDone: () {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("The Host Stopped Hosting"),
                duration: Duration(seconds: 3),
              ),
            );
          }
          general.mready(0);
        },
        onError: (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Couldn't connect"),
                duration: Duration(seconds: 3),
              ),
            );
          }
          general.mready(0);
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Something Went WRONG"),
            duration: Duration(seconds: 3),
          ),
        );
      }
      general.mready(0);
    }
  }

  @override
  void initState() {
    super.initState();
    startclient(widget.general);
  }

  @override
  void dispose() {
    Clipboard.setData(ClipboardData(text: ""));
    _channel?.sink.close();
    _channel = null;
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

    return Stack(
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
                    final message = jsonEncode({
                      "hint": "GU",
                      "content": controller.text,
                    });
                    _channel?.sink.add(message);
                    if (clip) {
                      Clipboard.setData(ClipboardData(text: controller.text));
                    }
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
                  if (mounted) {
                    setState(() {
                      clip = !clip;
                    });
                  }
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

        Positioned(
          top: trueheight * 0.09,
          left: truewidth * 0.06,
          child: IconButton(
            onPressed: () {
              widget.general.mready(0);
            },
            icon: Icon(
              Icons.arrow_back_rounded,
              color: widget.theme.current!["text"],
            ),
          ),
        ),
      ],
    );
  }
}
