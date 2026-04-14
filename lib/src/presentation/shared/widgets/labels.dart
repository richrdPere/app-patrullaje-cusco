import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Labels extends StatelessWidget {
  final String ruta;
  final String titulo;
  final String subTitulo;

  const Labels({
    super.key,
    required this.ruta,
    required this.titulo,
    required this.subTitulo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          titulo,
          style: TextStyle(
            color: Colors.black54,
            fontSize: 15,
            fontWeight: FontWeight.w300,
          ),
        ),
    
        SizedBox(height: 10),
    
        GestureDetector(
          child: Text(
            subTitulo,
            style: TextStyle(
              color: Colors.blue[600],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            context.goNamed(ruta);
          },
        ),
      ],
    );
  }
}
