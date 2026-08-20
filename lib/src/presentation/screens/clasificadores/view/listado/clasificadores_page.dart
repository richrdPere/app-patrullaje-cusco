import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Models
import 'package:sis_patrullaje_cusco/src/data/models/clasificadores/clasificador_codigo_data.dart';
import 'package:sis_patrullaje_cusco/src/data/models/common/api_response.dart';

// BLoC
import 'package:sis_patrullaje_cusco/src/presentation/screens/clasificadores/bloc/clasificadores_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/clasificadores/bloc/clasificadores_state.dart';

// Content
import 'package:sis_patrullaje_cusco/src/presentation/screens/clasificadores/view/listado/clasificadores_content.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/clasificadores/view/listado/widgets/clasificadoDetailSheet.dart';

// Resource
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/clasificadores/view/menu/widgets/categoria_generica_option.dart';

class ClasificadoresPage extends StatefulWidget {
  final CategoriaGenericaOption categoria;

  const ClasificadoresPage({super.key, required this.categoria});

  @override
  State<ClasificadoresPage> createState() => _ClasificadoresPageState();
}

class _ClasificadoresPageState extends State<ClasificadoresPage> {
  bool _isDetailOpen = false;

  // ========================================================
  // MOSTRAR DETALLE
  // ========================================================

  Future<void> _showClasificadorDetail(
    ClasificadorCodigoData clasificador,
  ) async {
    if (_isDetailOpen || !mounted) {
      return;
    }

    _isDetailOpen = true;

    try {
      final selected = await showModalBottomSheet<ClasificadorCodigoData>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) {
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.78,
            minChildSize: 0.50,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Material(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                clipBehavior: Clip.antiAlias,
                child: ClasificadorDetailSheet(
                  clasificador: clasificador,
                  scrollController: scrollController,
                  onSelected: () {
                    // Cierra únicamente el bottom sheet y
                    // devuelve el clasificador seleccionado.
                    Navigator.of(sheetContext).pop(clasificador);
                  },
                ),
              );
            },
          );
        },
      );

      if (selected == null || !mounted) {
        return;
      }

      // Cierra el fullscreen dialog y devuelve el resultado
      // a la pantalla que abrió el selector.
      context.pop<ClasificadorCodigoData>(selected);
    } finally {
      _isDetailOpen = false;
    }
  }

  // ========================================================
  // CERRAR FULLSCREEN DIALOG
  // ========================================================

  void _close() {
    if (!mounted) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    if (context.canPop()) {
      // Cierra sin devolver un clasificador.
      context.pop<ClasificadorCodigoData>();
    }
  }

  // ========================================================
  // MOSTRAR ERROR
  // ========================================================

  void _showError(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  // ========================================================
  // BUILD
  // ========================================================
  @override
  Widget build(BuildContext context) {
    return BlocListener<ClasificadoresBloc, ClasificadoresState>(
      listenWhen: (previous, current) {
        return previous.clasificadorCodigoResponse !=
            current.clasificadorCodigoResponse;
      },
      listener: (context, state) {
        final response = state.clasificadorCodigoResponse;

        if (response is Success<ApiResponse<ClasificadorCodigoData>>) {
          final clasificador = response.data.data;

          if (clasificador != null) {
            _showClasificadorDetail(clasificador);
          }
        }

        if (response is ErrorData<ApiResponse<ClasificadorCodigoData>>) {
          _showError(response.fullMessage);
        }
      },
      child: PopScope<ClasificadorCodigoData?>(
        canPop: true,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              tooltip: 'Cerrar',
              onPressed: _close,
              icon: const Icon(Icons.close),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.categoria.nombre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Categoría ${widget.categoria.codigo}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          body: SafeArea(
            top: false,
            child: ClasificadoresContent(
              key: ValueKey(widget.categoria.id),
              categoriaGenericaId: widget.categoria.id,
            ),
          ),
        ),
      ),
    );
  }
}
