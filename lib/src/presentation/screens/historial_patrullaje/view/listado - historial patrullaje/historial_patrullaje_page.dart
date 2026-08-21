import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Bloc
import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/bloc/historial_patrullaje_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/bloc/historial_patrullaje_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/bloc/historial_patrullaje_state.dart';

// Content
import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/view/listado%20-%20historial%20patrullaje/historial_patrullaje_content.dart';

class HistorialPatrullajePage extends StatefulWidget {
  final int patrullajeId;

  const HistorialPatrullajePage({super.key, required this.patrullajeId});

  @override
  State<HistorialPatrullajePage> createState() =>
      _HistorialPatrullajePageState();
}

class _HistorialPatrullajePageState extends State<HistorialPatrullajePage> {
  // ========================================================
  // CICLO DE VIDA
  // ========================================================
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _initializePage();
    });
  }

  @override
  void didUpdateWidget(covariant HistorialPatrullajePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.patrullajeId != widget.patrullajeId) {
      _onPatrullajeChanged();
    }
  }

  // ========================================================
  // INICIALIZAR PÁGINA
  // ========================================================
  void _initializePage() {
    final bloc = context.read<HistorialPatrullajeBloc>();

    /*
     * Evita mostrar un detalle seleccionado de
     * una navegación anterior.
     */
    bloc.add(const ClearHistorialSelectedEvent());

    /*
     * Limpia mensajes antiguos de crear,
     * actualizar o archivar.
     */
    bloc.add(const ClearHistorialActionEvent());

    _loadHistorial();
  }

  // ========================================================
  // CAMBIO DE PATRULLAJE
  // ========================================================
  void _onPatrullajeChanged() {
    final bloc = context.read<HistorialPatrullajeBloc>();

    bloc.add(const ClearHistorialSelectedEvent());

    _loadHistorial(refresh: true);
  }

  // ========================================================
  // CARGAR HISTORIAL
  // ========================================================
  void _loadHistorial({bool refresh = false}) {
    if (widget.patrullajeId <= 0) {
      return;
    }

    context.read<HistorialPatrullajeBloc>().add(
      LoadHistorialPatrullajeEvent(
        patrullajeId: widget.patrullajeId,

        refresh: refresh,
      ),
    );
  }

  // ========================================================
  // MOSTRAR MENSAJE
  // ========================================================
  void _showMessage({required String message, required bool isError}) {
    final color = isError ? Colors.red.shade700 : Colors.green.shade700;

    final icon = isError
        ? Icons.error_outline_rounded
        : Icons.check_circle_outline_rounded;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white),

              const SizedBox(width: 12),

              Expanded(child: Text(message)),
            ],
          ),

          behavior: SnackBarBehavior.floating,

          backgroundColor: color,
        ),
      );
  }

  // ========================================================
  // LISTENER DE ACCIONES
  // ========================================================
  void _onBlocStateChanged(
    BuildContext context,
    HistorialPatrullajeState state,
  ) {
    if (state.actionStatus == HistorialActionStatus.success) {
      _showMessage(
        message: state.actionMessage ?? 'Operación realizada correctamente.',

        isError: false,
      );

      context.read<HistorialPatrullajeBloc>().add(
        const ClearHistorialActionEvent(),
      );

      return;
    }

    if (state.actionStatus == HistorialActionStatus.error) {
      _showMessage(
        message: state.errorMessage ?? 'No se pudo realizar la operación.',

        isError: true,
      );

      context.read<HistorialPatrullajeBloc>().add(
        const ClearHistorialActionEvent(),
      );
    }
  }

  // ========================================================
  // BUILD
  // ========================================================
  @override
  Widget build(BuildContext context) {
    return BlocListener<HistorialPatrullajeBloc, HistorialPatrullajeState>(
      listenWhen: (previous, current) {
        /*
         * Solo escucha cuando una acción alcanza
         * success o error.
         *
         * No vuelve a ejecutar el listener al
         * limpiar el estado hacia initial.
         */
        final actionChanged = previous.actionStatus != current.actionStatus;

        final isFinalStatus =
            current.actionStatus == HistorialActionStatus.success ||
            current.actionStatus == HistorialActionStatus.error;

        return actionChanged && isFinalStatus;
      },

      listener: _onBlocStateChanged,

      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        // appBar: AppBar(
        //   title: const Text('Historial de patrullaje'),

        //   centerTitle: false,

        //   elevation: 0,

        //   actions: [
        //     BlocSelector<
        //       HistorialPatrullajeBloc,
        //       HistorialPatrullajeState,
        //       bool
        //     >(
        //       selector: (state) {
        //         return state.listStatus == HistorialListStatus.loading;
        //       },

        //       builder: (context, isLoading) {
        //         if (isLoading) {
        //           return const Padding(
        //             padding: EdgeInsets.symmetric(horizontal: 18),

        //             child: Center(
        //               child: SizedBox(
        //                 width: 20,
        //                 height: 20,
        //                 child: CircularProgressIndicator(strokeWidth: 2),
        //               ),
        //             ),
        //           );
        //         }

        //         return IconButton(
        //           tooltip: 'Actualizar historial',

        //           onPressed: () {
        //             _loadHistorial(refresh: true);
        //           },

        //           icon: const Icon(Icons.refresh_rounded),
        //         );
        //       },
        //     ),
        //   ],
        // ),

        body: HistorialPatrullajeContent(patrullajeId: widget.patrullajeId),
      ),
    );
  }
}
