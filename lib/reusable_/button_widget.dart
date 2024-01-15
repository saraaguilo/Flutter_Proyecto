import 'dart:io';
import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback onClicked;

  const ButtonWidget({
    Key? key,
    required this.text,
    required this.onClicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: const StadiumBorder(),
          // ignore: deprecated_member_use
          onPrimary: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        ),
        // ignore: sort_child_properties_last
        child: Text(text),
        onPressed: onClicked,
      );
}

/* Exemple d'ús important el widget
Widget buildUpgradeButton() => ButtonWidget(
        text: 'Your button's name',
        onClicked: () {},
      );
*/