import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:sis_patrullaje_cusco/src/data/models/clasificadores/clasificador_codigo_data.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/clasificadores/view/menu/clasificadores_menu_content.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/clasificadores/view/menu/widgets/categoria_generica_option.dart';

class ClasificadoresMenuPage extends StatefulWidget {
  const ClasificadoresMenuPage({super.key});

  @override
  State<ClasificadoresMenuPage> createState() => _ClasificadoresMenuPageState();
}

class _ClasificadoresMenuPageState extends State<ClasificadoresMenuPage> {
  bool _isNavigating = false;

  Future<void> _openCategoria(CategoriaGenericaOption categoria) async {
    if (_isNavigating || !mounted) {
      return;
    }

    setState(() {
      _isNavigating = true;
    });

    try {
      final selected = await context.pushNamed<ClasificadorCodigoData>(
        'clasificador_codigos',
        pathParameters: {'categoriaGenericaId': categoria.id.toString()},
        extra: categoria,
      );

      if (selected == null || !mounted) {
        return;
      }

      // Devuelve el código seleccionado al formulario
      // que abrió el menú.
      context.pop<ClasificadorCodigoData>(selected);
    } finally {
      if (mounted) {
        setState(() {
          _isNavigating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Clasificador de ocurrencias',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),

        centerTitle: true,
      ),
      body: SafeArea(
        top: false,
        child: ClasificadoresMenuContent(
          categorias: categoriasGenericasClasificador,
          isNavigating: _isNavigating,
          onCategoriaTap: _openCategoria,
        ),
      ),
    );
  }
}
