import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_state.dart';

class IncidenciaDetalleContent extends StatelessWidget {
  final int incidenciaId;
  final VoidCallback onRefresh;

  const IncidenciaDetalleContent({
    super.key,
    required this.incidenciaId,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IncidenteBloc, IncidenteState>(
      buildWhen: (previous, current) =>
          previous.detalleResponse != current.detalleResponse ||
          previous.incidenciaSeleccionada != current.incidenciaSeleccionada,
      builder: (context, state) {
        final response = state.detalleResponse;
        final incidencia = state.incidenciaSeleccionada;

        if (response is Loading<IncidenteModel> && incidencia == null) {
          return const _DetalleLoading();
        }

        if (response is ErrorData<IncidenteModel> && incidencia == null) {
          return _DetalleError(message: response.message, onRetry: onRefresh);
        }

        if (incidencia == null) {
          return _DetalleEmpty(onRetry: onRefresh);
        }

        return _IncidenciaDetalleView(
          incidencia: incidencia,
          isRefreshing: response is Loading<IncidenteModel>,
          onRefresh: onRefresh,
        );
      },
    );
  }
}

class _IncidenciaDetalleView extends StatelessWidget {
  final IncidenteModel incidencia;
  final bool isRefreshing;
  final VoidCallback onRefresh;

  const _IncidenciaDetalleView({
    required this.incidencia,
    required this.isRefreshing,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isRefreshing) const LinearProgressIndicator(minHeight: 2),

        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              onRefresh();
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _DetalleHeader(incidencia: incidencia),

                const SizedBox(height: 16),

                _InformacionSection(incidencia: incidencia),

                const SizedBox(height: 16),

                _UbicacionSection(incidencia: incidencia),

                const SizedBox(height: 16),

                _EvidenciasSection(incidencia: incidencia),

                const SizedBox(height: 16),

                _InformacionRegistroSection(incidencia: incidencia),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DetalleHeader extends StatelessWidget {
  final IncidenteModel incidencia;

  const _DetalleHeader({required this.incidencia});

  @override
  Widget build(BuildContext context) {
    final tipo = incidencia.tipo.toUpperCase();
    final estado = incidencia.estado;

    final tipoConfig = _getTipoConfig(tipo);
    final estadoConfig = _getEstadoConfig(estado!);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: tipoConfig.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(tipoConfig.icon, size: 30, color: tipoConfig.color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatTipo(tipo),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Incidencia N.° ${incidencia.id ?? '-'}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: estadoConfig.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  estadoConfig.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: estadoConfig.color,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InformacionSection extends StatelessWidget {
  final IncidenteModel incidencia;

  const _InformacionSection({required this.incidencia});

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
      title: 'Información de la incidencia',
      icon: Icons.description_outlined,
      child: Column(
        children: [
          _DetailRow(
            label: 'Tipo',
            value: _formatTipo(incidencia.tipo.toUpperCase()),
          ),
          const Divider(height: 24),
          _DetailRow(label: 'Estado', value: _formatEstado(incidencia.estado!)),
          const Divider(height: 24),
          _DetailRow(label: 'Origen', value: _formatValue(incidencia.origen)),
          const Divider(height: 24),
          _DescriptionRow(
            label: 'Descripción',
            value: incidencia.descripcion.trim().isEmpty
                ? 'Sin descripción registrada.'
                : incidencia.descripcion.trim(),
          ),
        ],
      ),
    );
  }
}

class _UbicacionSection extends StatelessWidget {
  final IncidenteModel incidencia;

  const _UbicacionSection({required this.incidencia});

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
      title: 'Ubicación',
      icon: Icons.location_on_outlined,
      child: Column(
        children: [
          _DetailRow(label: 'Latitud', value: incidencia.latitud.toString()),
          const Divider(height: 24),
          _DetailRow(label: 'Longitud', value: incidencia.longitud.toString()),
          const Divider(height: 24),

          // _DetailRow(
          //   label: 'Zona',
          //   value: incidencia.zona?.nombre ?? 'Sin zona registrada',
          // ),
          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                /*
                       * Aquí puedes navegar a tu mapa.
                       *
                       * context.pushNamed(
                       *   'mapa_incident',
                       *   extra: IncidentData(...),
                       * );
                       */
              },
              icon: const Icon(Icons.map_outlined),
              label: const Text('Ver ubicación en el mapa'),
            ),
          ),
        ],
      ),
    );
  }
}

class _EvidenciasSection extends StatelessWidget {
  final IncidenteModel incidencia;

  const _EvidenciasSection({required this.incidencia});

  @override
  Widget build(BuildContext context) {
    final archivos = incidencia.archivos ?? [];

    return _SectionContainer(
      title: 'Evidencias',
      icon: Icons.attach_file_rounded,
      child: archivos.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.image_not_supported_outlined,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'No existen evidencias registradas.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: archivos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final archivo = archivos[index];

                return _ArchivoPreview(url: archivo.path, tipo: archivo.path);
              },
            ),
    );
  }
}

class _ArchivoPreview extends StatelessWidget {
  final String url;
  final String tipo;

  const _ArchivoPreview({required this.url, required this.tipo});

  @override
  Widget build(BuildContext context) {
    final tipoNormalizado = tipo.toUpperCase();

    if (tipoNormalizado == 'IMAGEN') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return _buildPlaceholder(Icons.broken_image_outlined);
          },
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;

            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          },
        ),
      );
    }

    final icon = tipoNormalizado == 'VIDEO'
        ? Icons.play_circle_outline
        : Icons.picture_as_pdf_outlined;

    return _buildPlaceholder(icon);
  }

  Widget _buildPlaceholder(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Icon(icon, size: 34, color: Colors.grey.shade600),
    );
  }
}

class _InformacionRegistroSection extends StatelessWidget {
  final IncidenteModel incidencia;

  const _InformacionRegistroSection({required this.incidencia});

  @override
  Widget build(BuildContext context) {
    return _SectionContainer(
      title: 'Información de registro',
      icon: Icons.info_outline_rounded,
      child: Column(
        children: [
          _DetailRow(
            label: 'Fecha y hora',
            value: incidencia.fechaHora == null
                ? 'No disponible'
                : _formatDateTime(incidencia.fechaHora!),
          ),
          const Divider(height: 24),
          // _DetailRow(
          //   label: 'Reportado por',
          //   value: _getNombreUsuario(incidencia),
          // ),
          const Divider(height: 24),
          _DetailRow(
            label: 'Total evidencias',
            value: incidencia.totalEvidencias.toString(),
          ),
        ],
      ),
    );
  }

  // String _getNombreUsuario(IncidenteModel incidencia) {
  //   final usuario = incidencia.usuario;

  //   if (usuario == null) {
  //     return 'Usuario no disponible';
  //   }

  //   final persona = usuario.persona;

  //   if (persona != null) {
  //     final nombreCompleto = [
  //       persona.nombres,
  //       persona.apellidoPaterno,
  //       persona.apellidoMaterno,
  //     ].where((value) => value!.trim().isNotEmpty).join(' ');

  //     if (nombreCompleto.isNotEmpty) {
  //       return nombreCompleto;
  //     }
  //   }

  //   return usuario.username;
  // }
}

class _SectionContainer extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionContainer({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 21,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 115,
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _DescriptionRow extends StatelessWidget {
  final String label;
  final String value;

  const _DescriptionRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            height: 1.45,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _DetalleLoading extends StatelessWidget {
  const _DetalleLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Obteniendo detalle de la incidencia...'),
        ],
      ),
    );
  }
}

class _DetalleError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DetalleError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 68, color: Colors.red.shade300),
            const SizedBox(height: 16),
            const Text(
              'No se pudo obtener la incidencia',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
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

class _DetalleEmpty extends StatelessWidget {
  final VoidCallback onRetry;

  const _DetalleEmpty({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.find_in_page_outlined,
              size: 68,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Incidencia no disponible',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TipoConfig {
  final IconData icon;
  final Color color;

  const _TipoConfig({required this.icon, required this.color});
}

class _EstadoConfig {
  final String label;
  final Color color;

  const _EstadoConfig({required this.label, required this.color});
}

_TipoConfig _getTipoConfig(String tipo) {
  switch (tipo) {
    case 'ROBO':
      return const _TipoConfig(icon: Icons.security, color: Colors.red);

    case 'ACCIDENTE':
      return const _TipoConfig(icon: Icons.car_crash, color: Colors.orange);

    case 'INCENDIO':
      return const _TipoConfig(
        icon: Icons.local_fire_department,
        color: Colors.deepOrange,
      );

    case 'VIOLENCIA':
      return const _TipoConfig(
        icon: Icons.warning_amber_rounded,
        color: Colors.purple,
      );

    case 'SOSPECHOSO':
      return const _TipoConfig(
        icon: Icons.visibility_outlined,
        color: Colors.amber,
      );

    default:
      return const _TipoConfig(
        icon: Icons.report_problem_outlined,
        color: Colors.blueGrey,
      );
  }
}

_EstadoConfig _getEstadoConfig(String estado) {
  switch (estado) {
    case 'REPORTADO':
      return const _EstadoConfig(label: 'Reportado', color: Colors.red);

    case 'EN_PROCESO':
      return const _EstadoConfig(label: 'En proceso', color: Colors.orange);

    case 'ATENDIDO':
      return const _EstadoConfig(label: 'Atendido', color: Colors.green);

    case 'CERRADO':
      return const _EstadoConfig(label: 'Cerrado', color: Colors.blueGrey);

    default:
      return _EstadoConfig(label: estado, color: Colors.grey);
  }
}

String _formatTipo(String tipo) {
  switch (tipo) {
    case 'ROBO':
      return 'Robo';
    case 'ACCIDENTE':
      return 'Accidente';
    case 'INCENDIO':
      return 'Incendio';
    case 'VIOLENCIA':
      return 'Violencia';
    case 'SOSPECHOSO':
      return 'Persona sospechosa';
    case 'OTRO':
      return 'Otro';
    default:
      return tipo;
  }
}

String _formatEstado(String estado) {
  switch (estado) {
    case 'REPORTADO':
      return 'Reportado';
    case 'EN_PROCESO':
      return 'En proceso';
    case 'ATENDIDO':
      return 'Atendido';
    case 'CERRADO':
      return 'Cerrado';
    case 'ELIMINADO':
      return 'Eliminado';
    default:
      return estado;
  }
}

String _formatValue(dynamic value) {
  if (value == null) return 'No disponible';

  final text = value.toString().trim();

  return text.isEmpty ? 'No disponible' : text;
}

String _formatDateTime(DateTime fecha) {
  String twoDigits(int value) => value.toString().padLeft(2, '0');

  final day = twoDigits(fecha.day);
  final month = twoDigits(fecha.month);
  final hour = twoDigits(fecha.hour);
  final minute = twoDigits(fecha.minute);

  return '$day/$month/${fecha.year} $hour:$minute';
}
