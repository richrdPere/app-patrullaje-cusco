import 'package:flutter/material.dart';

class DefaultButton extends StatelessWidget {
  String text;
  Function onPressed;
  Color color;
  EdgeInsetsGeometry? margin;

  DefaultButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = Colors.black,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 55,
      margin:
          margin ?? const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: ElevatedButton(
        onPressed: () {
          onPressed();
        },
        style: ElevatedButton.styleFrom(backgroundColor: color),
        child: Text(text, style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
