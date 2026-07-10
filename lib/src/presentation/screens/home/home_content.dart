import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:sis_patrullaje_cusco/src/domain/entities/patrullaje_entity.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_state.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/widgets/custom_appbar.dart';

// import 'package:sis_patrullaje_cusco/src/presentation/widgets/custom_app_bar.dart';

class HomeContent extends StatelessWidget {
  final HomeState homeState;
  final TrackingState trackingState;

  const HomeContent({
    super.key,
    required this.homeState,
    required this.trackingState,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: const CustomAppBar(), body: _buildBody(context));
  }

  Widget _buildBody(BuildContext context) {
    final isEmpty =
        homeState.status == PatrullajeStatus.sinAsignacion ||
        homeState.patrullaje == null;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeBloc>().add(LoadPatrullajeActivo());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (isEmpty) ...[
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.30,
                child: const Center(child: _EmptyPatrullaje()),
              ),
            ] else ...[
              _PatrullajeHeader(homeState: homeState),
              const SizedBox(height: 20),

              _MainPatrullajeButton(homeState: homeState),
              const SizedBox(height: 20),

              _LocationCard(trackingState: trackingState),
              const SizedBox(height: 20),
            ],

            const _StatsSection(),
            const SizedBox(height: 30),

            const _QuickActions(),
          ],
        ),
      ),
    );
  }
}

class _PatrullajeHeader extends StatelessWidget {
  final HomeState homeState;

  const _PatrullajeHeader({required this.homeState});

  @override
  Widget build(BuildContext context) {
    final patrullaje = homeState.patrullaje;

    if (patrullaje == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Patrullaje asignado',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          Text(
            'Zona: ${patrullaje.zona.nombre}',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 5),

          if (patrullaje.descripcion.trim().isNotEmpty)
            Text(
              'Descripción: ${patrullaje.descripcion}',
              style: const TextStyle(color: Colors.white),
            ),

          const SizedBox(height: 8),

          Text(
            _getStatusText(homeState.status),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(PatrullajeStatus status) {
    switch (status) {
      case PatrullajeStatus.asignado:
        return '🟡 Asignado';

      case PatrullajeStatus.aceptando:
        return '🟠 Aceptando...';

      case PatrullajeStatus.enCurso:
        return '🟢 En patrullaje';

      case PatrullajeStatus.finalizado:
        return '🔴 Finalizado';

      case PatrullajeStatus.error:
        return '🔴 Error';

      case PatrullajeStatus.sinAsignacion:
        return '⚪ Sin asignación';
    }
  }
}

class _MainPatrullajeButton extends StatelessWidget {
  final HomeState homeState;

  const _MainPatrullajeButton({required this.homeState});

  @override
  Widget build(BuildContext context) {
    final patrullaje = homeState.patrullaje;

    if (patrullaje == null) {
      return const SizedBox.shrink();
    }

    switch (homeState.status) {
      case PatrullajeStatus.asignado:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              context.read<HomeBloc>().add(AceptarPatrullaje(patrullaje.id));
            },
            icon: const Icon(Icons.check),
            label: const Text('Aceptar patrullaje'),
          ),
        );

      case PatrullajeStatus.aceptando:
        return const Center(
          child: Column(
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text('Aceptando patrullaje...'),
            ],
          ),
        );

      case PatrullajeStatus.enCurso:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              _confirmarFinalizacion(context, patrullaje.id);
            },
            icon: const Icon(Icons.stop),
            label: const Text('Finalizar patrullaje'),
          ),
        );

      case PatrullajeStatus.sinAsignacion:
      case PatrullajeStatus.finalizado:
      case PatrullajeStatus.error:
        return const SizedBox.shrink();
    }
  }

  Future<void> _confirmarFinalizacion(
    BuildContext context,
    int patrullajeId,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Finalizar patrullaje'),
          content: const Text(
            '¿Está seguro de finalizar el patrullaje actual?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Finalizar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !context.mounted) return;

    context.read<HomeBloc>().add(FinalizarPatrullaje(patrullajeId));
  }
}

class _LocationCard extends StatelessWidget {
  final TrackingState trackingState;

  const _LocationCard({required this.trackingState});

  @override
  Widget build(BuildContext context) {
    final location = trackingState.lastLocation;

    if (location == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.my_location)),
        title: const Text('Ubicación actual'),
        subtitle: Text(
          '${location.latitud.toStringAsFixed(6)}, '
          '${location.longitud.toStringAsFixed(6)}',
        ),
      ),
    );
  }
}

class _EmptyPatrullaje extends StatelessWidget {
  const _EmptyPatrullaje();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.directions_walk, size: 80, color: Colors.grey),
        SizedBox(height: 20),
        Text(
          'Sin patrullaje asignado',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Text(
          'Espera una asignación desde la central.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Incidencias',
            value: '3',
            valueColor: Colors.red,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            title: 'Alertas',
            value: '2',
            valueColor: Colors.orange,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            title: 'Recorrido',
            value: '75%',
            valueColor: Colors.green,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        child: Column(
          children: [
            Text(title, textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                color: valueColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 30,
      runSpacing: 20,
      children: const [
        _QuickAction(icon: Icons.map, label: 'Ver mapa', routeName: 'mapa'),
        _QuickAction(
          icon: Icons.warning,
          label: 'Alerta',
          routeName: 'alertas',
        ),
        _QuickAction(
          icon: Icons.location_on,
          label: 'Ubicación',
          routeName: 'home',
        ),
        _QuickAction(
          icon: Icons.history,
          label: 'Historial',
          routeName: 'historial',
        ),
        _QuickAction(
          icon: Icons.video_collection_rounded,
          label: 'Tutoriales',
          routeName: 'tutorial',
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String routeName;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(35),
      onTap: () {
        context.pushNamed(routeName);
      },
      child: SizedBox(
        width: 75,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(radius: 25, child: Icon(icon)),
            const SizedBox(height: 6),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
