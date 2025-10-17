import 'package:flutter/material.dart';
import '../providers.dart';

class Sp extends StatelessWidget {
  final General general;
  final Navigation navigation;
  const Sp({super.key, required this.general, required this.navigation});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextField(controller: controller),
            FloatingActionButton.extended(
              label: Text("set name"),
              onPressed: () {
                final done = general.setname(controller.text);
                if (done) navigation.changepage(0);
              },
            ),
          ],
        ),
      ],
    );
  }
}
