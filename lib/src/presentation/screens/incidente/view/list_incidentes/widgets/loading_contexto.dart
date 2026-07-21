import 'package:flutter/material.dart';

class LoadingContexto extends StatelessWidget {
  const LoadingContexto({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Obteniendo incidencias de la zona...',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class EmptyContexto extends StatelessWidget {
  final VoidCallback onRefresh;

  const EmptyContexto({super.key, 
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 70),
          Icon(
            Icons.fact_check_outlined,
            size: 72,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 18),
          const Text(
            'Sin incidencias registradas',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No existen incidencias asociadas al patrullaje activo '
            'o a la zona asignada.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar'),
            ),
          ),
        ],
      ),
    );
  }
}

class ErrorContexto extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorContexto({super.key, 
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off,
              size: 65,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'No se pudieron cargar las incidencias',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class SinPatrullajeActivo extends StatelessWidget {
  const SinPatrullajeActivo({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.route_outlined,
              size: 68,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No existe un patrullaje activo',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Las incidencias de contexto estarán disponibles cuando '
              'tengas un patrullaje y una zona asignados.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}