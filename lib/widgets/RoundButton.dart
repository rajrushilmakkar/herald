import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  final Function pressed;
  final text;
  RoundButton(this.pressed, this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Material(
        borderRadius: BorderRadius.circular(45),
        elevation: 6,
        color: Theme.of(context).primaryColor,
        child: MaterialButton(
          child: Text(text),
          onPressed: pressed,
          minWidth: 325,
          height: 45,
          //color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
