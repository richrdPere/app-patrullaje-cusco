import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  final String titulo;

  const Logo({super.key, required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 170,
        child: Column(
          children: [
            Image(image: AssetImage('assets/img/tag-logo.png')),

            SizedBox(height: 20),

            Text(titulo, style: TextStyle(fontSize: 30)),
          ],
        ),
      ),
    );
  }
}
