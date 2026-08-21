import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/data/models/historial_patrullaje/enum/historial_enum.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/bloc/historial_patrullaje_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/bloc/historial_patrullaje_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/bloc/historial_patrullaje_state.dart';

import 'siguiente_turno_content.dart';

class SiguienteTurnoPage extends StatefulWidget {
  const SiguienteTurnoPage({super.key});

  @override
  State<SiguienteTurnoPage> createState() => _SiguienteTurnoPageState();
}

class _SiguienteTurnoPageState extends State<SiguienteTurnoPage> {
  SiguienteTurnoQueryParams _params = const SiguienteTurnoQueryParams(
    page: 1,
    limit: 20,
  );

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _loadSiguienteTurno();
    });
  }

  void _loadSiguienteTurno({bool refresh = false}) {
    context.read<HistorialPatrullajeBloc>().add(
      LoadSiguienteTurnoEvent(params: _params, refresh: refresh),
    );
  }

  Future<void> _onRefresh() async {
    _loadSiguienteTurno(refresh: true);

    await context.read<HistorialPatrullajeBloc>().stream.firstWhere(
      (state) =>
          state.siguienteTurnoStatus != HistorialSiguienteTurnoStatus.loading,
    );
  }

  void _goToPreviousPage() {
    if (_params.page <= 1) {
      return;
    }

    setState(() {
      _params = _params.copyWith(page: _params.page - 1);
    });

    _loadSiguienteTurno(refresh: true);
  }

  void _goToNextPage() {
    final pagination = context
        .read<HistorialPatrullajeBloc>()
        .state
        .siguienteTurno
        ?.pagination;

    if (pagination == null || !pagination.hasNextPage) {
      return;
    }

    setState(() {
      _params = _params.copyWith(page: _params.page + 1);
    });

    _loadSiguienteTurno(refresh: true);
  }

  Future<void> _showFilters() async {
    var selectedTypes = List<HistorialTipo>.from(_params.tipos);

    var selectedPriorities = List<HistorialPrioridad>.from(_params.prioridades);

    final result = await showModalBottomSheet<SiguienteTurnoQueryParams>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filtrar turno anterior',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Selecciona los registros que deseas revisar.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 22),

                      Text(
                        'Tipos de registro',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: HistorialTipo.values.map((tipo) {
                          final selected = selectedTypes.contains(tipo);

                          return FilterChip(
                            label: Text(_tipoLabel(tipo)),
                            selected: selected,
                            onSelected: (value) {
                              setModalState(() {
                                if (value) {
                                  selectedTypes.add(tipo);
                                } else {
                                  selectedTypes.remove(tipo);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 22),

                      Text(
                        'Prioridades',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: HistorialPrioridad.values.map((prioridad) {
                          final selected = selectedPriorities.contains(
                            prioridad,
                          );

                          return FilterChip(
                            label: Text(_prioridadLabel(prioridad)),
                            selected: selected,
                            onSelected: (value) {
                              setModalState(() {
                                if (value) {
                                  selectedPriorities.add(prioridad);
                                } else {
                                  selectedPriorities.remove(prioridad);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 26),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.of(bottomSheetContext).pop(
                                  const SiguienteTurnoQueryParams(
                                    page: 1,
                                    limit: 20,
                                  ),
                                );
                              },
                              child: const Text('RESTABLECER'),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: FilledButton(
                              onPressed: () {
                                Navigator.of(bottomSheetContext).pop(
                                  SiguienteTurnoQueryParams(
                                    page: 1,
                                    limit: _params.limit,
                                    tipos: selectedTypes,
                                    prioridades: selectedPriorities,
                                  ),
                                );
                              },
                              child: const Text('APLICAR'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    if (result == null || !mounted) {
      return;
    }

    setState(() {
      _params = result;
    });

    _loadSiguienteTurno(refresh: true);
  }

  int get _activeFilters {
    return _params.tipos.length + _params.prioridades.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,

        leading: IconButton(
          tooltip: 'Cerrar',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
              return;
            }

            /*
       * Fallback si se ingresó mediante go/goNamed
       * y no existe una página anterior.
       */
            context.go('/home');
          },
          icon: const Icon(Icons.close_rounded),
        ),
        title: const Text('Turno anterior'),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Filtrar información',
            onPressed: _showFilters,
            icon: Badge(
              isLabelVisible: _activeFilters > 0,
              label: Text('$_activeFilters'),
              child: const Icon(Icons.tune_rounded),
            ),
          ),

          BlocSelector<HistorialPatrullajeBloc, HistorialPatrullajeState, bool>(
            selector: (state) {
              return state.siguienteTurnoStatus ==
                  HistorialSiguienteTurnoStatus.loading;
            },
            builder: (context, isLoading) {
              if (isLoading) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }

              return IconButton(
                tooltip: 'Actualizar',
                onPressed: () {
                  _loadSiguienteTurno(refresh: true);
                },
                icon: const Icon(Icons.refresh_rounded),
              );
            },
          ),
        ],
      ),
      body: SiguienteTurnoContent(
        onRefresh: _onRefresh,
        onRetry: () {
          _loadSiguienteTurno(refresh: true);
        },
        onPreviousPage: _goToPreviousPage,
        onNextPage: _goToNextPage,
      ),
    );
  }

  String _tipoLabel(HistorialTipo tipo) {
    switch (tipo) {
      case HistorialTipo.observacion:
        return 'Observación';
      case HistorialTipo.novedad:
        return 'Novedad';
      case HistorialTipo.alerta:
        return 'Alerta';
      case HistorialTipo.recomendacion:
        return 'Recomendación';
      case HistorialTipo.puntoCritico:
        return 'Punto crítico';
      case HistorialTipo.cambioTurno:
        return 'Cambio de turno';
    }
  }

  String _prioridadLabel(HistorialPrioridad prioridad) {
    switch (prioridad) {
      case HistorialPrioridad.baja:
        return 'Baja';
      case HistorialPrioridad.media:
        return 'Media';
      case HistorialPrioridad.alta:
        return 'Alta';
      case HistorialPrioridad.critica:
        return 'Crítica';
    }
  }
}
