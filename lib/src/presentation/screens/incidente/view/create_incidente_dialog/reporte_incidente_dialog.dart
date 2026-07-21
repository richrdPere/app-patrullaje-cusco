import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/enums/incidente_tab_enum.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/view/create_incidente_dialog/screens/emergencia_screen.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/view/create_incidente_dialog/screens/evidencia_screen.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/view/screens/historial_incidentes_screen.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/view/create_incidente_dialog/screens/incident_form_screen.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/view/create_incidente_dialog/screens/observacion_screen.dart';

class ReporteIncidenteDialog extends StatelessWidget {
  const ReporteIncidenteDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IncidenteBloc, IncidenteState>(
      builder: (context, state) {
        final header = _getHeader(state.currentTab);

        return Scaffold(
          backgroundColor: Colors.white,

          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,

            leadingWidth: 60,

            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Color.fromARGB(255, 12, 38, 145),
                      Color.fromARGB(255, 34, 156, 249),
                    ],
                  ),
                ),

                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 22),

                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),

            titleSpacing: 18,

            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  header.title,
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  header.subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          body: SafeArea(
            top: false,
            child: Column(
              children: [
                Expanded(
                  child: switch (state.currentTab) {
                    IncidenteTabEnum.incidente => const IncidenteFormScreen(),

                    IncidenteTabEnum.evidencia => const EvidenciaScreen(),

                    IncidenteTabEnum.observacion => const ObservacionScreen(),

                    // IncidenteTabEnum.historial =>
                    //   const HistorialIncidentesScreen(),

                    IncidenteTabEnum.emergencia => const EmergenciaScreen(),
                  },
                ),

                const Padding(
                  padding: EdgeInsets.only(bottom: 16, left: 16, right: 16),

                  child: Center(child: _IncidenteBottomTabs()),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class IncidenteHeaderInfo {
  final String title;
  final String subtitle;

  const IncidenteHeaderInfo({required this.title, required this.subtitle});
}

IncidenteHeaderInfo _getHeader(IncidenteTabEnum tab) {
  switch (tab) {
    case IncidenteTabEnum.incidente:
      return const IncidenteHeaderInfo(
        title: 'Nuevo incidente',
        subtitle: 'Registra una ocurrencia durante el patrullaje',
      );

    case IncidenteTabEnum.evidencia:
      return const IncidenteHeaderInfo(
        title: 'Evidencias',
        subtitle: 'Agrega fotografías y videos al reporte',
      );

    case IncidenteTabEnum.observacion:
      return const IncidenteHeaderInfo(
        title: 'Observación',
        subtitle: 'Registra novedades para el patrullaje',
      );

    // case IncidenteTabEnum.historial:
    //   return const IncidenteHeaderInfo(
    //     title: 'Mis incidencias',
    //     subtitle: 'Consulta los reportes registrados',
    //   );

    case IncidenteTabEnum.emergencia:
      return const IncidenteHeaderInfo(
        title: 'Emergencia SOS',
        subtitle: 'Solicita apoyo inmediato a la central',
      );
  }
}

class _IncidenteBottomTabs extends StatefulWidget {
  const _IncidenteBottomTabs();

  @override
  State<_IncidenteBottomTabs> createState() => _IncidenteBottomTabsState();
}

class _IncidenteBottomTabsState extends State<_IncidenteBottomTabs> {
  final ScrollController _scrollController = ScrollController();

  final tabs = const [
    ('Incidente', IncidenteTabEnum.incidente),
    ('Evidencia', IncidenteTabEnum.evidencia),
    ('Observación', IncidenteTabEnum.observacion),
    // ('Historial', IncidenteTabEnum.historial),
    ('SOS', IncidenteTabEnum.emergencia),
  ];

  late final List<GlobalKey> _tabKeys;

  @override
  void initState() {
    super.initState();

    _tabKeys = List.generate(tabs.length, (_) => GlobalKey());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _centerTab(int index) {
    if (!_scrollController.hasClients) return;

    final tabContext = _tabKeys[index].currentContext;

    if (tabContext == null) return;

    final RenderBox box = tabContext.findRenderObject() as RenderBox;

    final Offset position = box.localToGlobal(Offset.zero);

    final double tabWidth = box.size.width;

    final double screenWidth = MediaQuery.of(context).size.width;

    final double currentOffset = _scrollController.offset;

    final double targetOffset =
        currentOffset + position.dx - (screenWidth / 2) + (tabWidth / 2);

    _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IncidenteBloc, IncidenteState>(
      builder: (context, state) {
        final selectedIndex = tabs.indexWhere((e) => e.$2 == state.currentTab);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _centerTab(selectedIndex);
        });

        return SizedBox(
          height: 60,

          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,

            physics: const BouncingScrollPhysics(),

            child: Row(
              children: [
                SizedBox(width: MediaQuery.of(context).size.width / 2),

                ...tabs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final tab = entry.value;

                  final selected = state.currentTab == tab.$2;

                  return Padding(
                    key: _tabKeys[index],

                    padding: const EdgeInsets.symmetric(horizontal: 6),

                    child: GestureDetector(
                      onTap: () {
                        context.read<IncidenteBloc>().add(
                          CambiarTabIncidenteEvent(tab.$2),
                        );
                      },

                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 250),

                        curve: Curves.easeOut,

                        scale: selected ? 1.08 : 1,

                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),

                          curve: Curves.easeOut,

                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 10,
                          ),

                          decoration: BoxDecoration(
                            gradient: selected
                                ? const LinearGradient(
                                    begin: Alignment.topRight,
                                    end: Alignment.bottomLeft,
                                    colors: [
                                      Color.fromARGB(255, 12, 38, 145),
                                      Color.fromARGB(255, 34, 156, 249),
                                    ],
                                  )
                                : null,
                            color: selected ? null : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(25),
                          ),

                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 250),

                            style: TextStyle(
                              fontSize: 15,

                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w500,

                              color: selected ? Colors.white : Colors.black87,
                            ),

                            child: Text(tab.$1),
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                SizedBox(width: MediaQuery.of(context).size.width / 2),
              ],
            ),
          ),
        );
      },
    );
  }
}
