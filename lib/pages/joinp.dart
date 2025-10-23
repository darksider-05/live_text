import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:live_text/providers.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

// ignore: must_be_immutable
class Jp extends StatefulWidget {
  General general;
  Jp({super.key, required this.general});

  @override
  State<Jp> createState() => _JpState();
}

class _JpState extends State<Jp> {
  var controller = TextEditingController();
  WebSocketChannel? _channel;

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
          }
        },
        onDone: () {
          setState(() {
            general.ready = false;
          });
        },
        onError: (error) {
          setState(() {
            general.ready = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        general.ready = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    startclient(widget.general);
  }

  @override
  void dispose() {
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
                    final message = jsonEncode({
                      "hint": "GU",
                      "content": controller.text,
                    });
                    _channel?.sink.add(message);
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

        Positioned(
          top: trueheight * 0.09,
          left: truewidth * 0.06,
          child: IconButton(
            onPressed: () {
              widget.general.mready(0);
            },
            icon: Icon(Icons.arrow_back_rounded),
          ),
        ),
      ],
    );
  }
}
