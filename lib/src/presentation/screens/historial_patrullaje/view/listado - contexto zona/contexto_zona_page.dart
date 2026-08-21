import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/data/models/historial_patrullaje/enum/historial_enum.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/bloc/historial_patrullaje_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/bloc/historial_patrullaje_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/bloc/historial_patrullaje_state.dart';

import 'contexto_zona_content.dart';

class ContextoZonaPage extends StatefulWidget {
  final int zonaId;

  const ContextoZonaPage({super.key, required this.zonaId});

  @override
  State<ContextoZonaPage> createState() => _ContextoZonaPageState();
}

class _ContextoZonaPageState extends State<ContextoZonaPage> {
  ContextoZonaQueryParams _params = const ContextoZonaQueryParams(
    page: 1,
    limit: 20,
    dias: 30,
  );

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _loadContexto();
    });
  }

  @override
  void didUpdateWidget(covariant ContextoZonaPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.zonaId != widget.zonaId) {
      _params = const ContextoZonaQueryParams(page: 1, limit: 20, dias: 30);

      context.read<HistorialPatrullajeBloc>().add(
        const ClearContextoZonaEvent(),
      );

      _loadContexto(refresh: true);
    }
  }

  void _loadContexto({bool refresh = false}) {
    if (widget.zonaId <= 0) {
      return;
    }

    context.read<HistorialPatrullajeBloc>().add(
      LoadContextoZonaEvent(
        zonaId: widget.zonaId,
        params: _params,
        refresh: refresh,
      ),
    );
  }

  Future<void> _onRefresh() async {
    _loadContexto(refresh: true);
  }

  void _goToPreviousPage() {
    if (_params.page <= 1) {
      return;
    }

    setState(() {
      _params = _params.copyWith(page: _params.page - 1);
    });

    _loadContexto(refresh: true);
  }

  void _goToNextPage() {
    final pagination = context
        .read<HistorialPatrullajeBloc>()
        .state
        .contextoZona
        ?.pagination;

    if (pagination == null || !pagination.hasNextPage) {
      return;
    }

    setState(() {
      _params = _params.copyWith(page: _params.page + 1);
    });

    _loadContexto(refresh: true);
  }

  Future<void> _showFilters() async {
    var selectedDays = _params.dias;

    var selectedTypes = List<HistorialTipo>.from(_params.tipos);

    var selectedPriorities = List<HistorialPrioridad>.from(_params.prioridades);

    final result = await showModalBottomSheet<ContextoZonaQueryParams>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (bottomSheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  4,
                  20,
                  20 + MediaQuery.viewInsetsOf(context).bottom,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filtrar contexto',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Selecciona el periodo y la información que deseas consultar.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 22),

                      Text(
                        'Periodo',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final dias in const [7, 15, 30, 60, 90])
                            ChoiceChip(
                              label: Text('$dias días'),
                              selected: selectedDays == dias,
                              onSelected: (_) {
                                setModalState(() {
                                  selectedDays = dias;
                                });
                              },
                            ),
                        ],
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
                                  const ContextoZonaQueryParams(
                                    page: 1,
                                    limit: 20,
                                    dias: 30,
                                  ),
                                );
                              },
                              child: const Text('RESTABLECER'),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(bottomSheetContext).pop(
                                  ContextoZonaQueryParams(
                                    page: 1,
                                    limit: _params.limit,
                                    dias: selectedDays,
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

    _loadContexto(refresh: true);
  }

  int get _activeFilters {
    return _params.tipos.length +
        _params.prioridades.length +
        (_params.dias != 30 ? 1 : 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contexto de zona'),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Filtrar contexto',
            onPressed: _showFilters,
            icon: Badge(
              isLabelVisible: _activeFilters > 0,
              label: Text('$_activeFilters'),
              child: const Icon(Icons.tune_rounded),
            ),
          ),

          BlocSelector<HistorialPatrullajeBloc, HistorialPatrullajeState, bool>(
            selector: (state) {
              return state.contextoZonaStatus ==
                  HistorialContextoZonaStatus.loading;
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
                  _loadContexto(refresh: true);
                },
                icon: const Icon(Icons.refresh_rounded),
              );
            },
          ),
        ],
      ),
      body: ContextoZonaContent(
        params: _params,
        onRefresh: _onRefresh,
        onRetry: () {
          _loadContexto(refresh: true);
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
