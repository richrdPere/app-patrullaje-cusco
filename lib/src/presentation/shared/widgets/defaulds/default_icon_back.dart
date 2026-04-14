import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DefauldIconBack extends StatelessWidget {
  Color color;
  EdgeInsetsGeometry? margin;

  DefauldIconBack({super.key, this.color = Colors.white, this.margin});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      margin: margin,
      child: IconButton(
        onPressed: () {
          context.pop();
        },
        icon: Icon(Icons.arrow_back_ios, size: 35, color: color),
      ),
    );
  }
}
