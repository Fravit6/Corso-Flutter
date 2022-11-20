import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/*
 * Widget che mostra un bottone senza sfondo in base alla natura del device (Android/iOS)
 */
class AdaptiveFlatButton extends StatelessWidget {
  final String text;      // Testo bottone
  final Function handler; // Puntatore funzione onPressed

  AdaptiveFlatButton(this.text, this.handler);

  @override
  Widget build(BuildContext context) {
    return (Platform.isIOS)
        ? CupertinoButton(
            child: Text(
              text,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: handler,
          )
        : FlatButton(
            textColor: Theme.of(context).primaryColor,
            child: Text(
              text,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: handler,
          );
  }
}
