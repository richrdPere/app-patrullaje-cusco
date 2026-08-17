import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sis_patrullaje_cusco/src/data/models/common/api_response.dart';
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_detalle_data.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

// BloC
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/bloc/ocurrencia_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/bloc/ocurrencia_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/bloc/ocurrencia_state.dart';

class OcurrenciaDetalleContent extends StatelessWidget {
  final int ocurrenciaId;
  final VoidCallback onRetry;

  const OcurrenciaDetalleContent({
    super.key,
    required this.ocurrenciaId,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OcurrenciaBloc, OcurrenciaState>(
      buildWhen: (previous, current) {
        return previous.detailResponse != current.detailResponse;
      },
      builder: (context, state) {
        final response = state.detailResponse;

        if (response is Initial<ApiResponse<OcurrenciaDetalleData>> ||
            response is Loading<ApiResponse<OcurrenciaDetalleData>>) {
          return const _DetailLoading();
        }

        if (response is ErrorData<ApiResponse<OcurrenciaDetalleData>>) {
          return _DetailError(message: response.message, onRetry: onRetry);
        }

        if (response is Success<ApiResponse<OcurrenciaDetalleData>>) {
          final ocurrencia = response.data.data;

          if (ocurrencia == null) {
            return _DetailError(
              message: 'El servidor no devolvió los datos de la ocurrencia.',
              onRetry: onRetry,
            );
          }

          return _OcurrenciaDetailView(ocurrencia: ocurrencia);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

// ==========================================================
// VISTA DEL DETALLE
// ==========================================================

class _OcurrenciaDetailView extends StatelessWidget {
  final OcurrenciaDetalleData ocurrencia;

  const _OcurrenciaDetailView({required this.ocurrencia});

  @override
  Widget build(BuildContext context) {
    final modalidad = ocurrencia.modalidad;
    final categoriaEspecifica = modalidad?.categoriaEspecifica;
    final categoriaGenerica = categoriaEspecifica?.categoriaGenerica;
    final version = categoriaGenerica?.version;

    return RefreshIndicator(
      onRefresh: () async {
        context.read<OcurrenciaBloc>().add(
          GetOcurrenciaById(ocurrenciaId: ocurrencia.id),
        );

        await context.read<OcurrenciaBloc>().stream.firstWhere(
          (state) => state.detailResponse is! Loading,
        );
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        children: [
          _OcurrenciaHeader(ocurrencia: ocurrencia),
          const SizedBox(height: 16),

          // Clasificación
          _DetailSection(
            title: 'Clasificación de la ocurrencia',
            icon: Icons.account_tree_outlined,
            children: [
              _InfoRow(
                label: 'Código',
                value: modalidad?.codigo,
                highlight: true,
              ),
              _InfoRow(label: 'Modalidad', value: modalidad?.nombre),
              _InfoRow(
                label: 'Categoría específica',
                value: categoriaEspecifica == null
                    ? null
                    : '${categoriaEspecifica.codigo} - '
                          '${categoriaEspecifica.nombre}',
              ),
              _InfoRow(
                label: 'Categoría genérica',
                value: categoriaGenerica == null
                    ? null
                    : '${categoriaGenerica.codigo} - '
                          '${categoriaGenerica.nombre}',
              ),
              _InfoRow(label: 'Clasificador', value: version?.nombre),
              _InfoRow(label: 'Resolución', value: version?.resolucion),
              if (modalidad != null) ...[
                const SizedBox(height: 10),
                _RequirementsCard(modalidad: modalidad),
              ],
              if (modalidad?.reglas.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                Text(
                  'Reglas aplicadas',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                ...modalidad!.reglas.map((regla) => _RuleTile(regla: regla)),
              ],
            ],
          ),
          const SizedBox(height: 14),

          // Información operativa
          _DetailSection(
            title: 'Información operativa',
            icon: Icons.local_police_outlined,
            children: [
              _InfoRow(
                label: 'Sereno',
                value: ocurrencia.sereno?.persona?.nombreCompleto,
              ),
              _InfoRow(
                label: 'DNI',
                value: ocurrencia.sereno?.persona?.documentoIdentidad,
              ),
              _InfoRow(label: 'Origen', value: _formatEnum(ocurrencia.origen)),
              if (ocurrencia.origenOtro != null)
                _InfoRow(label: 'Otro origen', value: ocurrencia.origenOtro),
              _InfoRow(
                label: 'Modalidad de patrullaje',
                value: _formatEnum(ocurrencia.modalidadPatrullaje),
              ),
              _InfoRow(
                label: 'Tipo de patrullaje',
                value: _formatEnum(ocurrencia.tipoPatrullaje),
              ),
              _InfoRow(label: 'Turno', value: _formatEnum(ocurrencia.turno)),
              _InfoRow(label: 'Placa', value: ocurrencia.placaVehiculo),
              _InfoRow(
                label: 'Tipo de vehículo',
                value: ocurrencia.tipoVehiculo == null
                    ? null
                    : _formatEnum(ocurrencia.tipoVehiculo!),
              ),
              _InfoRow(
                label: 'Resultado',
                value: _formatEnum(ocurrencia.resultado),
              ),
              _InfoRow(
                label: 'Relación víctima-victimario',
                value: ocurrencia.relacionVictimaVictimario == null
                    ? null
                    : _formatEnum(ocurrencia.relacionVictimaVictimario!),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Tiempos
          _DetailSection(
            title: 'Fecha y tiempos de atención',
            icon: Icons.schedule_outlined,
            children: [
              _InfoRow(
                label: 'Fecha',
                value: _formatDate(ocurrencia.fechaOcurrencia),
              ),
              _InfoRow(
                label: 'Hora de alerta',
                value: _formatTime(ocurrencia.horaAlerta),
              ),
              _InfoRow(
                label: 'Hora de llegada',
                value: _formatTime(ocurrencia.horaLlegada),
              ),
              _InfoRow(
                label: 'Hora de repliegue',
                value: _formatTime(ocurrencia.horaRepliegue),
              ),
              if (_responseDuration(ocurrencia) != null)
                _InfoRow(
                  label: 'Tiempo de respuesta',
                  value: _responseDuration(ocurrencia),
                  highlight: true,
                ),
            ],
          ),
          const SizedBox(height: 14),

          // Ubicación
          _DetailSection(
            title: 'Ubicación',
            icon: Icons.location_on_outlined,
            children: [
              _InfoRow(
                label: 'Tipo de lugar',
                value: ocurrencia.tipoLugar == null
                    ? null
                    : _formatEnum(ocurrencia.tipoLugar!),
              ),
              _InfoRow(
                label: 'Tipo de vía',
                value: ocurrencia.tipoVia == null
                    ? null
                    : _formatEnum(ocurrencia.tipoVia!),
              ),
              _InfoRow(label: 'Dirección', value: ocurrencia.direccion),
              _InfoRow(label: 'Referencia', value: ocurrencia.referencia),
              _InfoRow(label: 'Manzana', value: ocurrencia.manzana),
              _InfoRow(label: 'Lote', value: ocurrencia.lote),
              _InfoRow(
                label: 'Tipo de zona',
                value: ocurrencia.tipoZona == null
                    ? null
                    : _formatEnum(ocurrencia.tipoZona!),
              ),
              _InfoRow(label: 'Nombre de zona', value: ocurrencia.nombreZona),
              _InfoRow(label: 'Sector', value: ocurrencia.sectorPatrullaje),
              _InfoRow(label: 'Ubigeo', value: ocurrencia.ubigeo),
              _InfoRow(
                label: 'Coordenadas',
                value: ocurrencia.latitud != null && ocurrencia.longitud != null
                    ? '${ocurrencia.latitud}, '
                          '${ocurrencia.longitud}'
                    : null,
              ),
            ],
          ),

          if (ocurrencia.datosImportantes?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 14),
            _DetailSection(
              title: 'Datos importantes',
              icon: Icons.notes_outlined,
              children: [
                Text(
                  ocurrencia.datosImportantes!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ],

          if (ocurrencia.incidencia != null) ...[
            const SizedBox(height: 14),
            _IncidenciaSection(incidencia: ocurrencia.incidencia!),
          ],

          if (ocurrencia.patrullaje != null) ...[
            const SizedBox(height: 14),
            _PatrullajeSection(patrullaje: ocurrencia.patrullaje!),
          ],

          const SizedBox(height: 14),
          _PersonasSection(personas: ocurrencia.personas),
          const SizedBox(height: 14),
          _ConsecuenciasSection(consecuencias: ocurrencia.consecuencias),
          const SizedBox(height: 14),
          _MediosSection(medios: ocurrencia.mediosEmpleados),
          const SizedBox(height: 14),
          _EfectivosPnpSection(efectivos: ocurrencia.efectivosPnp),
          const SizedBox(height: 14),
          _HistorialSection(historial: ocurrencia.historial),
        ],
      ),
    );
  }
}

class _OcurrenciaHeader extends StatelessWidget {
  final OcurrenciaDetalleData ocurrencia;

  const _OcurrenciaHeader({required this.ocurrencia});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final estadoColor = _statusColor(context, ocurrencia.estado);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.primaryContainer,
            colors.primaryContainer.withValues(alpha: 0.55),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 27,
                backgroundColor: colors.primary,
                child: Icon(Icons.assignment_outlined, color: colors.onPrimary),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ocurrencia.numeroOcurrencia,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colors.onPrimaryContainer,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ocurrencia.modalidad?.nombre ?? 'Sin clasificación',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onPrimaryContainer.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusBadge(
                label: _formatEnum(ocurrencia.estado),
                color: estadoColor,
              ),
              _StatusBadge(
                label: _formatEnum(ocurrencia.turno),
                color: colors.secondary,
                icon: Icons.schedule_outlined,
              ),
              _StatusBadge(
                label: _formatEnum(ocurrencia.estadoRemision),
                color: colors.tertiary,
                icon: Icons.send_outlined,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Registrado: ${_formatDateTime(ocurrencia.createdAt)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onPrimaryContainer.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _DetailSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.7)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, size: 21, color: colors.onPrimaryContainer),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String? value;
  final bool highlight;

  const _InfoRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = value?.trim();

    if (normalized == null || normalized.isEmpty) {
      return const SizedBox.shrink();
    }

    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final vertical = constraints.maxWidth < 390;

          if (vertical) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  normalized,
                  style: TextStyle(
                    color: highlight ? colors.primary : null,
                    fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 145,
                child: Text(
                  label,
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  normalized,
                  style: TextStyle(
                    color: highlight ? colors.primary : null,
                    fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const _StatusBadge({required this.label, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RequirementsCard extends StatelessWidget {
  final OcurrenciaModalidadData modalidad;

  const _RequirementsCard({required this.modalidad});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: [
        _RequirementChip(label: 'Autor', required: modalidad.requiereAutor),
        _RequirementChip(label: 'Víctima', required: modalidad.requiereVictima),
        _RequirementChip(
          label: 'Conductor',
          required: modalidad.requiereConductor,
        ),
        _RequirementChip(
          label: 'Datos PNP',
          required: modalidad.requiereDatosPnp,
        ),
        _RequirementChip(
          label: 'Descripción',
          required: modalidad.requiereDescripcion,
        ),
      ],
    );
  }
}

class _RequirementChip extends StatelessWidget {
  final String label;
  final bool required;

  const _RequirementChip({required this.label, required this.required});

  @override
  Widget build(BuildContext context) {
    final color = required ? Colors.orange : Colors.grey;

    return Chip(
      avatar: Icon(
        required ? Icons.check_circle_outline : Icons.remove_circle_outline,
        size: 17,
        color: color,
      ),
      label: Text(required ? '$label requerido' : '$label no requerido'),
      labelStyle: TextStyle(color: color, fontSize: 12),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide.none,
      visualDensity: VisualDensity.compact,
    );
  }
}

class _RuleTile extends StatelessWidget {
  final OcurrenciaReglaData regla;

  const _RuleTile({required this.regla});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: const CircleAvatar(
        radius: 17,
        child: Icon(Icons.rule_outlined, size: 18),
      ),
      title: Text(
        _formatEnum(regla.clave),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: regla.descripcion == null ? null : Text(regla.descripcion!),
    );
  }
}

class _IncidenciaSection extends StatelessWidget {
  final OcurrenciaIncidenciaData incidencia;

  const _IncidenciaSection({required this.incidencia});

  @override
  Widget build(BuildContext context) {
    return _DetailSection(
      title: 'Incidencia vinculada',
      icon: Icons.report_outlined,
      children: [
        _InfoRow(label: 'ID', value: incidencia.id.toString()),
        _InfoRow(label: 'Tipo', value: _formatEnum(incidencia.tipo)),
        _InfoRow(label: 'Estado', value: _formatEnum(incidencia.estado)),
        _InfoRow(label: 'Descripción', value: incidencia.descripcion),
        _InfoRow(label: 'Fecha', value: _formatDateTime(incidencia.fechaHora)),
        _InfoRow(label: 'Origen', value: _formatEnum(incidencia.origen)),
        _InfoRow(
          label: 'Evidencias',
          value: incidencia.totalEvidencias.toString(),
        ),
        if (incidencia.archivos.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            'Archivos adjuntos',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: incidencia.archivos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                return _EvidencePreview(archivo: incidencia.archivos[index]);
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _EvidencePreview extends StatelessWidget {
  final OcurrenciaArchivoData archivo;

  const _EvidencePreview({required this.archivo});

  @override
  Widget build(BuildContext context) {
    final isImage = archivo.tipoArchivo.toUpperCase() == 'IMAGEN';

    return Container(
      width: 110,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(13),
      ),
      child: isImage
          ? Image.network(
              archivo.urlArchivo,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return const Center(child: Icon(Icons.broken_image_outlined));
              },
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;

                return const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              },
            )
          : Center(child: Icon(_fileIcon(archivo.tipoArchivo), size: 36)),
    );
  }
}

class _PatrullajeSection extends StatelessWidget {
  final OcurrenciaPatrullajeData patrullaje;

  const _PatrullajeSection({required this.patrullaje});

  @override
  Widget build(BuildContext context) {
    return _DetailSection(
      title: 'Patrullaje vinculado',
      icon: Icons.route_outlined,
      children: [
        _InfoRow(label: 'ID', value: patrullaje.id.toString()),
        _InfoRow(label: 'Fecha', value: _formatDate(patrullaje.fecha)),
        _InfoRow(
          label: 'Horario',
          value:
              '${_formatTime(patrullaje.horaInicio)} - '
              '${_formatTime(patrullaje.horaFin)}',
        ),
        _InfoRow(label: 'Estado', value: _formatEnum(patrullaje.estado)),
        _InfoRow(label: 'Descripción', value: patrullaje.descripcion),
      ],
    );
  }
}

class _PersonasSection extends StatelessWidget {
  final List<OcurrenciaPersonaData> personas;

  const _PersonasSection({required this.personas});

  @override
  Widget build(BuildContext context) {
    return _DetailSection(
      title: 'Personas involucradas (${personas.length})',
      icon: Icons.groups_outlined,
      children: [
        if (personas.isEmpty)
          const _EmptyDetail(message: 'No hay personas registradas.')
        else
          ...personas.map(
            (persona) => _DetailListCard(
              icon: Icons.person_outline,
              title: persona.nombresApellidos ?? 'Persona no identificada',
              badge: _formatEnum(persona.tipoPersona),
              children: [
                _InfoRow(label: 'Documento', value: persona.documentoIdentidad),
                _InfoRow(
                  label: 'Género',
                  value: persona.genero == null
                      ? null
                      : _formatEnum(persona.genero!),
                ),
                _InfoRow(
                  label: 'Edad',
                  value: persona.edad == null
                      ? null
                      : '${persona.edad} años'
                            '${persona.edadEsAproximada ? " (aprox.)" : ""}',
                ),
                _InfoRow(label: 'Placa', value: persona.placa),
                _InfoRow(
                  label: 'Características',
                  value: persona.caracteristicasFisicas,
                ),
                _InfoRow(label: 'Observación', value: persona.observacion),
              ],
            ),
          ),
      ],
    );
  }
}

class _ConsecuenciasSection extends StatelessWidget {
  final List<OcurrenciaConsecuenciaData> consecuencias;

  const _ConsecuenciasSection({required this.consecuencias});

  @override
  Widget build(BuildContext context) {
    return _DetailSection(
      title: 'Consecuencias (${consecuencias.length})',
      icon: Icons.warning_amber_outlined,
      children: [
        if (consecuencias.isEmpty)
          const _EmptyDetail(message: 'No hay consecuencias registradas.')
        else
          ...consecuencias.map(
            (item) => _DetailListCard(
              icon: Icons.warning_amber_outlined,
              title: _formatEnum(item.tipo),
              children: [
                _InfoRow(label: 'Descripción', value: item.descripcion),
              ],
            ),
          ),
      ],
    );
  }
}

class _MediosSection extends StatelessWidget {
  final List<OcurrenciaMedioEmpleadoData> medios;

  const _MediosSection({required this.medios});

  @override
  Widget build(BuildContext context) {
    return _DetailSection(
      title: 'Medios empleados (${medios.length})',
      icon: Icons.build_outlined,
      children: [
        if (medios.isEmpty)
          const _EmptyDetail(message: 'No hay medios empleados registrados.')
        else
          ...medios.map(
            (item) => _DetailListCard(
              icon: Icons.build_outlined,
              title: _formatEnum(item.tipo),
              children: [
                _InfoRow(label: 'Descripción', value: item.descripcion),
              ],
            ),
          ),
      ],
    );
  }
}

class _EfectivosPnpSection extends StatelessWidget {
  final List<OcurrenciaEfectivoPnpData> efectivos;

  const _EfectivosPnpSection({required this.efectivos});

  @override
  Widget build(BuildContext context) {
    return _DetailSection(
      title: 'Efectivos PNP (${efectivos.length})',
      icon: Icons.local_police_outlined,
      children: [
        if (efectivos.isEmpty)
          const _EmptyDetail(message: 'No hay efectivos PNP registrados.')
        else
          ...efectivos.map(
            (efectivo) => _DetailListCard(
              icon: Icons.local_police_outlined,
              title: efectivo.nombreCompleto.isNotEmpty
                  ? efectivo.nombreCompleto
                  : 'Efectivo PNP #${efectivo.policiaId ?? efectivo.id}',
              badge: _formatEnum(efectivo.tipoParticipacion),
              children: [
                _InfoRow(label: 'Grado', value: efectivo.grado),
                _InfoRow(label: 'Comisaría', value: efectivo.comisaria),
                _InfoRow(
                  label: 'Código institucional',
                  value: efectivo.codigoInstitucional,
                ),
                _InfoRow(
                  label: 'Fuente',
                  value: _formatEnum(efectivo.fuenteRegistro),
                ),
                _InfoRow(label: 'Observación', value: efectivo.observacion),
              ],
            ),
          ),
      ],
    );
  }
}

class _HistorialSection extends StatelessWidget {
  final List<OcurrenciaHistorialData> historial;

  const _HistorialSection({required this.historial});

  @override
  Widget build(BuildContext context) {
    return _DetailSection(
      title: 'Historial (${historial.length})',
      icon: Icons.history_rounded,
      children: [
        if (historial.isEmpty)
          const _EmptyDetail(message: 'No hay movimientos en el historial.')
        else
          ...historial.map(
            (item) =>
                _HistoryItem(historial: item, isLast: item == historial.last),
          ),
      ],
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final OcurrenciaHistorialData historial;
  final bool isLast;

  const _HistoryItem({required this.historial, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 34,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: colors.primaryContainer,
                  child: Icon(Icons.circle, size: 9, color: colors.primary),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(width: 2, color: colors.outlineVariant),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatEnum(historial.accion),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (historial.comentario != null) ...[
                    const SizedBox(height: 4),
                    Text(historial.comentario!),
                  ],
                  const SizedBox(height: 5),
                  Text(
                    _formatDateTime(historial.createdAt),
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                  if (historial.estadoAnterior != null ||
                      historial.estadoNuevo != null) ...[
                    const SizedBox(height: 7),
                    Text(
                      '${historial.estadoAnterior == null ? "Sin estado" : _formatEnum(historial.estadoAnterior!)} '
                      '→ '
                      '${historial.estadoNuevo == null ? "Sin estado" : _formatEnum(historial.estadoNuevo!)}',
                      style: TextStyle(
                        color: colors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailListCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? badge;
  final List<Widget> children;

  const _DetailListCard({
    required this.icon,
    required this.title,
    required this.children,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: colors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              if (badge != null)
                _StatusBadge(label: badge!, color: colors.secondary),
            ],
          ),
          if (children.isNotEmpty) ...[const SizedBox(height: 9), ...children],
        ],
      ),
    );
  }
}

class _EmptyDetail extends StatelessWidget {
  final String message;

  const _EmptyDetail({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _DetailLoading extends StatelessWidget {
  const _DetailLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        SizedBox(height: 160),
        Center(child: CircularProgressIndicator()),
        SizedBox(height: 16),
        Center(child: Text('Cargando ocurrencia...')),
      ],
    );
  }
}

class _DetailError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DetailError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Icon(Icons.error_outline_rounded, size: 72, color: colors.error),
            const SizedBox(height: 18),
            Text(
              'No se pudo cargar la ocurrencia',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

Color _statusColor(BuildContext context, String status) {
  switch (status.toUpperCase()) {
    case 'BORRADOR':
      return Colors.orange;

    case 'ENVIADO':
      return Colors.blue;

    case 'OBSERVADO':
      return Colors.deepOrange;

    case 'VALIDADO':
      return Colors.green;

    case 'ANULADO':
      return Theme.of(context).colorScheme.error;

    default:
      return Theme.of(context).colorScheme.primary;
  }
}

String _formatEnum(String value) {
  if (value.trim().isEmpty) return 'No registrado';

  return value
      .toLowerCase()
      .split('_')
      .where((word) => word.isNotEmpty)
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}

String _formatDate(String? value) {
  if (value == null || value.isEmpty) {
    return 'No registrada';
  }

  final date = DateTime.tryParse(value);

  if (date == null) return value;

  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');

  return '$day/$month/${date.year}';
}

String _formatTime(String? value) {
  if (value == null || value.isEmpty) {
    return 'No registrada';
  }

  final parts = value.split(':');

  if (parts.length < 2) return value;

  return '${parts[0]}:${parts[1]}';
}

String _formatDateTime(String value) {
  final date = DateTime.tryParse(value)?.toLocal();

  if (date == null) return value;

  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');

  return '$day/$month/${date.year} $hour:$minute';
}

String? _responseDuration(OcurrenciaDetalleData ocurrencia) {
  final alert = _timeToMinutes(ocurrencia.horaAlerta);
  final arrival = _timeToMinutes(ocurrencia.horaLlegada);

  if (alert == null || arrival == null) return null;

  var difference = arrival - alert;

  if (difference < 0) {
    difference += 24 * 60;
  }

  if (difference < 60) {
    return '$difference minutos';
  }

  final hours = difference ~/ 60;
  final minutes = difference % 60;

  return '$hours h $minutes min';
}

int? _timeToMinutes(String? value) {
  if (value == null) return null;

  final parts = value.split(':');

  if (parts.length < 2) return null;

  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);

  if (hour == null || minute == null) return null;

  return (hour * 60) + minute;
}

IconData _fileIcon(String type) {
  switch (type.toUpperCase()) {
    case 'VIDEO':
      return Icons.video_file_outlined;

    case 'PDF':
      return Icons.picture_as_pdf_outlined;

    case 'IMAGEN':
      return Icons.image_outlined;

    default:
      return Icons.insert_drive_file_outlined;
  }
}
