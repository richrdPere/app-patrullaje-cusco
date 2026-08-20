import 'package:flutter/material.dart';

import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_sereno_query_params.dart';

class FiltersSection extends StatelessWidget {
  final TextEditingController searchController;
  final PatrullajeSerenoQueryParams params;

  final VoidCallback onSearch;
  final ValueChanged<DateTime> onDiaChanged;
  final VoidCallback onClearDia;
  final VoidCallback onClearFilters;

  const FiltersSection({
    super.key,
    required this.searchController,
    required this.params,
    required this.onSearch,
    required this.onDiaChanged,
    required this.onClearDia,
    required this.onClearFilters,
  });

  bool get hasFilters {
    final search = params.search?.trim();

    return params.dia != null || (search != null && search.isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ==============================================
            // BUSCADOR
            // ==============================================
            Expanded(
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: searchController,
                builder: (context, value, child) {
                  final hasText = value.text.trim().isNotEmpty;

                  return TextField(
                    controller: searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => onSearch(),
                    decoration: InputDecoration(
                      hintText: 'Buscar patrullaje...',
                      prefixIcon: const Icon(Icons.search_rounded),

                      // El botón aparece mientras exista texto.
                      suffixIcon: hasText
                          ? IconButton(
                              tooltip: 'Limpiar búsqueda',
                              onPressed: searchController.clear,
                              icon: const Icon(Icons.close_rounded),
                            )
                          : null,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(width: 10),

            // ==============================================
            // SELECTOR DE FECHA
            // ==============================================
            _DateSelector(
              selectedDay: params.dia,
              onPressed: () {
                _selectDate(context);
              },
              onClear: onClearDia,
            ),
          ],
        ),

        // ================================================
        // LIMPIAR TODOS LOS FILTROS
        // ================================================
        // if (hasFilters) ...[
        //   const SizedBox(height: 8),

        //   Align(
        //     alignment: Alignment.centerRight,
        //     child: TextButton.icon(
        //       onPressed: onClearFilters,
        //       icon: const Icon(
        //         Icons.filter_alt_off_outlined,
        //       ),
        //       label: const Text('Limpiar filtros'),
        //     ),
        //   ),
        // ],
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateUtils.dateOnly(DateTime.now());

    final firstDate = DateTime(now.year - 5, 1, 1);

    final lastDate = DateTime(now.year + 1, 12, 31);

    final selectedDay = params.dia;

    final initialDate =
        selectedDay == null ||
            selectedDay.isBefore(firstDate) ||
            selectedDay.isAfter(lastDate)
        ? now
        : selectedDay;

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Seleccionar día',
      cancelText: 'Cancelar',
      confirmText: 'Seleccionar',
      fieldLabelText: 'Fecha del patrullaje',
      fieldHintText: 'DD/MM/AAAA',
    );

    if (pickedDate == null) {
      return;
    }

    onDiaChanged(DateUtils.dateOnly(pickedDate));
  }
}

class _DateSelector extends StatelessWidget {
  final DateTime? selectedDay;
  final VoidCallback onPressed;
  final VoidCallback onClear;

  const _DateSelector({
    required this.selectedDay,
    required this.onPressed,
    required this.onClear,
  });

  bool get hasSelectedDay => selectedDay != null;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final backgroundColor = hasSelectedDay
        ? colors.primaryContainer
        : colors.surface;

    final foregroundColor = hasSelectedDay
        ? colors.onPrimaryContainer
        : colors.primary;

    final borderColor = hasSelectedDay ? colors.primary : colors.outlineVariant;

    return Tooltip(
      message: hasSelectedDay
          ? 'Fecha: ${_formatDate(selectedDay!)}'
          : 'Seleccionar fecha',
      child: SizedBox(
        width: 58,
        height: 58,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Material(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  onTap: onPressed,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: borderColor,
                        width: hasSelectedDay ? 1.5 : 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: hasSelectedDay
                        ? _SelectedDateIcon(
                            selectedDay: selectedDay!,
                            color: foregroundColor,
                          )
                        : Icon(
                            Icons.calendar_month_outlined,
                            size: 26,
                            color: foregroundColor,
                          ),
                  ),
                ),
              ),
            ),

            // Botón pequeño para quitar la fecha.
            if (hasSelectedDay)
              Positioned(
                top: -5,
                right: -5,
                child: Tooltip(
                  message: 'Quitar fecha',
                  child: Material(
                    color: colors.error,
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: InkWell(
                      onTap: onClear,
                      customBorder: const CircleBorder(),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: colors.onError,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}

class _SelectedDateIcon extends StatelessWidget {
  final DateTime selectedDay;
  final Color color;

  const _SelectedDateIcon({required this.selectedDay, required this.color});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(Icons.calendar_today_rounded, size: 29, color: color),

        Positioned(
          top: 10,
          child: Text(
            selectedDay.day.toString(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontSize: 10,
              height: 1,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
