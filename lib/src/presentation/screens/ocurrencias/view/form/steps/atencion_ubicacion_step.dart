import 'package:flutter/material.dart';

// Controller
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/view/form/controller/ocurrencia_form_controller.dart';

class AtencionUbicacionStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final OcurrenciaFormController controller;

  /// Esta función debe obtener la ubicación desde el Page
  /// o desde un servicio de geolocalización.
  final Future<OcurrenciaLocation?> Function()? onObtenerUbicacionActual;

  const AtencionUbicacionStep({
    super.key,
    required this.formKey,
    required this.controller,
    this.onObtenerUbicacionActual,
  });

  static const List<_SelectOption> _resultados = [
    _SelectOption(
      value: 'CONSUMADO',
      label: 'Consumado',
      icon: Icons.check_circle_outline_rounded,
    ),
    _SelectOption(
      value: 'FRUSTRADO',
      label: 'Frustrado',
      icon: Icons.block_rounded,
    ),
  ];

  static const List<_SelectOption> _tiposLugar = [
    _SelectOption(
      value: 'VIA_PUBLICA',
      label: 'Vía pública',
      icon: Icons.route_outlined,
    ),
    _SelectOption(
      value: 'INMUEBLE_PARTICULAR',
      label: 'Inmueble particular',
      icon: Icons.home_outlined,
    ),
    _SelectOption(
      value: 'CENTRO_COMERCIAL',
      label: 'Centro comercial',
      icon: Icons.storefront_outlined,
    ),
    _SelectOption(
      value: 'DEPOSITO',
      label: 'Deposito',
      icon: Icons.storefront_outlined,
    ),
    _SelectOption(
      value: 'DEPENDENCIA_ESTATAL',
      label: 'Dependencia Estatal',
      icon: Icons.school_outlined,
    ),
    // _SelectOption(
    //   value: 'INSTITUCION_EDUCATIVA',
    //   label: 'Institución educativa',
    //   icon: Icons.school_outlined,
    // ),
    // _SelectOption(
    //   value: 'PARQUE',
    //   label: 'Parque o área recreativa',
    //   icon: Icons.park_outlined,
    // ),
    // _SelectOption(
    //   value: 'MERCADO',
    //   label: 'Mercado',
    //   icon: Icons.store_outlined,
    // ),
    // _SelectOption(
    //   value: 'TERMINAL',
    //   label: 'Terminal',
    //   icon: Icons.directions_bus_outlined,
    // ),
    _SelectOption(value: 'FABRICA', label: 'Fabrica', icon: Icons.factory),
    _SelectOption(
      value: 'ENTIDAD_FINANCIERA',
      label: 'Entidad Financiera',
      icon: Icons.attach_money_sharp,
    ),
    _SelectOption(value: 'OTRO', label: 'Otro', icon: Icons.more_horiz_rounded),
  ];

  static const List<_SelectOption> _tiposVia = [
    _SelectOption(value: 'AVENIDA', label: 'Avenida'),
    _SelectOption(value: 'CALLE', label: 'Calle'),
    _SelectOption(value: 'JIRON', label: 'Jirón'),
    _SelectOption(value: 'PASAJE', label: 'Pasaje'),
    _SelectOption(value: 'CARRETERA', label: 'Carretera'),
    _SelectOption(value: 'CAMINO', label: 'Camino'),
    _SelectOption(value: 'OTRO', label: 'Otro'),
  ];

  static const List<_SelectOption> _tiposZona = [
    _SelectOption(value: 'ASOCIACION_VIVIENDA', label: 'Asociacion vivienda'),
    _SelectOption(value: 'BARRIO', label: 'Barrio'),
    _SelectOption(
      value: 'CONJUNTO_HABITACIONAL',
      label: 'Conjunto habitacional',
    ),
    _SelectOption(value: 'COOPERATIVA_VIVIENDA', label: 'Cooperativa vivienda'),
    _SelectOption(value: 'PUEBLO_JOVEN', label: 'Pueblo joven'),
    _SelectOption(value: 'UPIS', label: 'Upis'),
    _SelectOption(value: 'URBANIZACION', label: 'Urbanización'),
    _SelectOption(value: 'SIN_DATO', label: 'Sin dato'),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              const _StepIntroduction(
                icon: Icons.location_on_outlined,
                title: 'Atención y ubicación',
                description:
                    'Registra los tiempos de respuesta, el resultado de la '
                    'atención y la ubicación donde ocurrió el hecho.',
              ),
              const SizedBox(height: 16),

              // ==================================================
              // FECHA Y HORAS
              // ==================================================
              _SectionCard(
                title: 'Tiempos de atención',
                subtitle:
                    'La fecha y los horarios permiten medir el tiempo de '
                    'respuesta del patrullaje.',
                icon: Icons.schedule_rounded,
                child: Column(
                  children: [
                    _DateField(
                      controller: controller.fechaOcurrenciaController,
                      label: 'Fecha de la ocurrencia',
                      requiredField: true,
                      onSelected: controller.setFechaOcurrencia,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _TimeField(
                            controller: controller.horaAlertaController,
                            label: 'Hora de alerta',
                            onSelected: controller.setHoraAlerta,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _TimeField(
                            controller: controller.horaLlegadaController,
                            label: 'Hora de llegada',
                            onSelected: controller.setHoraLlegada,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _TimeField(
                      controller: controller.horaRepliegueController,
                      label: 'Hora de repliegue',
                      helperText:
                          'Puede dejarse vacío si la atención continúa.',
                      onSelected: controller.setHoraRepliegue,
                    ),
                    const SizedBox(height: 10),
                    _AtencionTimeSummary(controller: controller),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ==================================================
              // RESULTADO
              // ==================================================
              _SectionCard(
                title: 'Resultado de la ocurrencia',
                subtitle:
                    'Indica si el hecho llegó a consumarse o fue frustrado.',
                icon: Icons.fact_check_outlined,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: controller.resultado,
                      decoration: const InputDecoration(
                        labelText: 'Resultado *',
                        prefixIcon: Icon(Icons.task_alt_rounded),
                        border: OutlineInputBorder(),
                      ),
                      items: _resultados
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item.value,
                              child: Row(
                                children: [
                                  Icon(item.icon, size: 20),
                                  const SizedBox(width: 10),
                                  Text(item.label),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: controller.setResultado,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Seleccione el resultado de la ocurrencia.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller:
                          controller.relacionVictimaVictimarioController,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Relación víctima-victimario',
                        hintText:
                            'Ejemplo: familiar, vecino, desconocido, pareja...',
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.people_outline_rounded),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ==================================================
              // LUGAR
              // ==================================================
              _SectionCard(
                title: 'Lugar de la ocurrencia',
                subtitle:
                    'Describe el lugar y la vía donde se produjo el hecho.',
                icon: Icons.place_outlined,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      key: ValueKey('tipo-lugar-${controller.tipoLugar}'),
                      initialValue: controller.tipoLugar,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de lugar',
                        prefixIcon: Icon(Icons.apartment_rounded),
                        border: OutlineInputBorder(),
                      ),
                      items: _tiposLugar
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item.value,
                              child: Text(
                                item.label,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: controller.setTipoLugar,
                    ),
                    if (controller.tipoLugar == 'OTRO') ...[
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: controller.tipoLugarOtroController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          labelText: 'Especifique el tipo de lugar *',
                          prefixIcon: Icon(Icons.edit_location_alt_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (controller.tipoLugar == 'OTRO' &&
                              (value == null || value.trim().isEmpty)) {
                            return 'Especifique el tipo de lugar.';
                          }

                          return null;
                        },
                      ),
                    ],
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      key: ValueKey('tipo-via-${controller.tipoVia}'),
                      initialValue: controller.tipoVia,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de vía',
                        prefixIcon: Icon(Icons.add_road_rounded),
                        border: OutlineInputBorder(),
                      ),
                      items: _tiposVia
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item.value,
                              child: Text(item.label),
                            ),
                          )
                          .toList(),
                      onChanged: controller.setTipoVia,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: controller.direccionController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Dirección',
                        hintText: 'Ejemplo: Av. La Cultura 1250',
                        prefixIcon: Icon(Icons.signpost_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: controller.referenciaController,
                      textCapitalization: TextCapitalization.sentences,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Referencia',
                        hintText: 'Lugar cercano que facilite la ubicación',
                        alignLabelWithHint: true,
                        prefixIcon: Icon(Icons.near_me_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: controller.manzanaController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: const InputDecoration(
                              labelText: 'Manzana',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: controller.loteController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: const InputDecoration(
                              labelText: 'Lote',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ==================================================
              // ZONA
              // ==================================================
              _SectionCard(
                title: 'Zona y sector',
                subtitle:
                    'Completa la clasificación territorial de la ocurrencia.',
                icon: Icons.map_outlined,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      key: ValueKey('tipo-zona-${controller.tipoZona}'),
                      initialValue: controller.tipoZona,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de zona',
                        prefixIcon: Icon(Icons.landscape_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: _tiposZona
                          .map(
                            (item) => DropdownMenuItem<String>(
                              value: item.value,
                              child: Text(item.label),
                            ),
                          )
                          .toList(),
                      onChanged: controller.setTipoZona,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: controller.nombreZonaController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la zona',
                        hintText: 'Urbanización, comunidad o sector',
                        prefixIcon: Icon(Icons.location_city_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: controller.sectorPatrullajeController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Sector de patrullaje',
                        prefixIcon: Icon(Icons.grid_view_rounded),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: controller.ubigeoController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        labelText: 'Ubigeo',
                        hintText: 'Código de 6 dígitos',
                        prefixIcon: Icon(Icons.pin_drop_outlined),
                        border: OutlineInputBorder(),
                        counterText: '',
                      ),
                      validator: (value) {
                        final normalized = value?.trim() ?? '';

                        if (normalized.isNotEmpty &&
                            !RegExp(r'^\d{6}$').hasMatch(normalized)) {
                          return 'El ubigeo debe tener 6 dígitos.';
                        }

                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ==================================================
              // COORDENADAS
              // ==================================================
              _SectionCard(
                title: 'Coordenadas geográficas',
                subtitle:
                    'Puede utilizar la ubicación actual o ingresar las '
                    'coordenadas manualmente.',
                icon: Icons.gps_fixed_rounded,
                child: Column(
                  children: [
                    if (onObtenerUbicacionActual != null) ...[
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _obtenerUbicacion(context),
                          icon: const Icon(Icons.my_location_rounded),
                          label: const Text('Usar mi ubicación actual'),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: controller.latitudController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Latitud',
                              hintText: '-13.53195000',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => _validateCoordinate(
                              value,
                              minimum: -90,
                              maximum: 90,
                              fieldName: 'latitud',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: controller.longitudController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Longitud',
                              hintText: '-71.96746000',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => _validateCoordinate(
                              value,
                              minimum: -180,
                              maximum: 180,
                              fieldName: 'longitud',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const _InformationBox(
                      message:
                          'Si la ocurrencia fue seleccionada desde un '
                          'incidente, las coordenadas pueden aparecer '
                          'completadas automáticamente.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _obtenerUbicacion(BuildContext context) async {
    final callback = onObtenerUbicacionActual;

    if (callback == null) return;

    try {
      final location = await callback();

      if (location == null) return;

      controller.setUbicacion(
        latitud: location.latitud,
        longitud: location.longitud,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text('Ubicación obtenida correctamente.'),
          ),
        );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
            content: const Text('No se pudo obtener la ubicación actual.'),
          ),
        );
    }
  }

  String? _validateCoordinate(
    String? value, {
    required double minimum,
    required double maximum,
    required String fieldName,
  }) {
    final normalized = value?.trim() ?? '';

    if (normalized.isEmpty) {
      return null;
    }

    final coordinate = double.tryParse(normalized.replaceAll(',', '.'));

    if (coordinate == null) {
      return 'Ingrese una $fieldName válida.';
    }

    if (coordinate < minimum || coordinate > maximum) {
      return 'La $fieldName está fuera del rango válido.';
    }

    return null;
  }
}

// ============================================================
// RESULTADO DE UBICACIÓN
// ============================================================

class OcurrenciaLocation {
  final double latitud;
  final double longitud;

  const OcurrenciaLocation({required this.latitud, required this.longitud});
}

// ============================================================
// DATE FIELD
// ============================================================

class _DateField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool requiredField;
  final ValueChanged<DateTime> onSelected;

  const _DateField({
    required this.controller,
    required this.label,
    required this.onSelected,
    this.requiredField = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: requiredField ? '$label *' : label,
        prefixIcon: const Icon(Icons.calendar_month_outlined),
        suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
        border: const OutlineInputBorder(),
      ),
      onTap: () async {
        FocusScope.of(context).unfocus();

        final initialDate =
            DateTime.tryParse(controller.text.trim()) ?? DateTime.now();

        final selectedDate = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          helpText: 'Seleccione la fecha de ocurrencia',
          cancelText: 'CANCELAR',
          confirmText: 'ACEPTAR',
        );

        if (selectedDate != null) {
          onSelected(selectedDate);
        }
      },
      validator: requiredField
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Seleccione la fecha de la ocurrencia.';
              }

              return null;
            }
          : null,
    );
  }
}

// ============================================================
// TIME FIELD
// ============================================================

class _TimeField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? helperText;
  final ValueChanged<TimeOfDay> onSelected;

  const _TimeField({
    required this.controller,
    required this.label,
    required this.onSelected,
    this.helperText,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        prefixIcon: const Icon(Icons.access_time_rounded),
        suffixIcon: controller.text.trim().isEmpty
            ? const Icon(Icons.arrow_drop_down_rounded)
            : IconButton(
                tooltip: 'Limpiar',
                onPressed: controller.clear,
                icon: const Icon(Icons.close_rounded),
              ),
        border: const OutlineInputBorder(),
      ),
      onTap: () async {
        FocusScope.of(context).unfocus();

        final selectedTime = await showTimePicker(
          context: context,
          initialTime: _parseTime(controller.text) ?? TimeOfDay.now(),
          helpText: 'Seleccione la hora',
          cancelText: 'CANCELAR',
          confirmText: 'ACEPTAR',
        );

        if (selectedTime != null) {
          onSelected(selectedTime);
        }
      },
    );
  }

  TimeOfDay? _parseTime(String rawValue) {
    final parts = rawValue.trim().split(':');

    if (parts.length < 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;

    return TimeOfDay(hour: hour, minute: minute);
  }
}

// ============================================================
// RESUMEN DE TIEMPOS
// ============================================================

class _AtencionTimeSummary extends StatelessWidget {
  final OcurrenciaFormController controller;

  const _AtencionTimeSummary({required this.controller});

  @override
  Widget build(BuildContext context) {
    final alerta = _parseTime(controller.horaAlertaController.text);
    final llegada = _parseTime(controller.horaLlegadaController.text);
    final repliegue = _parseTime(controller.horaRepliegueController.text);

    final tiempoRespuesta = _differenceInMinutes(alerta, llegada);
    final tiempoAtencion = _differenceInMinutes(llegada, repliegue);

    if (tiempoRespuesta == null && tiempoAtencion == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withAlpha(100),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        children: [
          if (tiempoRespuesta != null)
            _TimeValue(
              label: 'Tiempo de respuesta',
              value: _formatMinutes(tiempoRespuesta),
            ),
          if (tiempoAtencion != null)
            _TimeValue(
              label: 'Tiempo de atención',
              value: _formatMinutes(tiempoAtencion),
            ),
        ],
      ),
    );
  }

  int? _parseTime(String rawValue) {
    final parts = rawValue.trim().split(':');

    if (parts.length < 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) return null;

    return (hour * 60) + minute;
  }

  int? _differenceInMinutes(int? start, int? end) {
    if (start == null || end == null) return null;

    var difference = end - start;

    // Permite una atención que cruza la medianoche.
    if (difference < 0) {
      difference += 24 * 60;
    }

    return difference;
  }

  String _formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours == 0) {
      return '$remainingMinutes min';
    }

    return '${hours} h ${remainingMinutes} min';
  }
}

class _TimeValue extends StatelessWidget {
  final String label;
  final String value;

  const _TimeValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.timer_outlined,
          size: 18,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 6),
        Text('$label: '),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

// ============================================================
// COMPONENTES GENERALES
// ============================================================

class _SelectOption {
  final String value;
  final String label;
  final IconData? icon;

  const _SelectOption({required this.value, required this.label, this.icon});
}

class _StepIntroduction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _StepIntroduction({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withAlpha(120),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            child: Icon(icon),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(description),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 10),
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
            if (subtitle != null) ...[
              const SizedBox(height: 6),
              Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class _InformationBox extends StatelessWidget {
  final String message;

  const _InformationBox({required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withAlpha(100),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: colorScheme.secondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
