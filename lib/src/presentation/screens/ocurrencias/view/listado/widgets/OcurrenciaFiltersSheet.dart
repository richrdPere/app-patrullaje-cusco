import 'package:flutter/material.dart';
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_query_params.dart';

class OcurrenciaFiltersSheet extends StatefulWidget {
  final OcurrenciaQueryParams initialParams;

  const OcurrenciaFiltersSheet({required this.initialParams});

  @override
  State<OcurrenciaFiltersSheet> createState() =>
      OcurrenciaFiltersSheetState();
}

class OcurrenciaFiltersSheetState extends State<OcurrenciaFiltersSheet> {
  late final TextEditingController _codigoController;
  late final TextEditingController _serenoController;
  late final TextEditingController _zonaController;

  String? _turno;
  String? _estado;
  String? _estadoRemision;
  String? _fechaDesde;
  String? _fechaHasta;

  @override
  void initState() {
    super.initState();

    _codigoController = TextEditingController(
      text: widget.initialParams.codigo ?? '',
    );

    _serenoController = TextEditingController(
      text: widget.initialParams.serenoId?.toString() ?? '',
    );

    _zonaController = TextEditingController(
      text: widget.initialParams.zonaId?.toString() ?? '',
    );

    _turno = widget.initialParams.turno;
    _estado = widget.initialParams.estado;
    _estadoRemision = widget.initialParams.estadoRemision;
    _fechaDesde = widget.initialParams.fechaDesde;
    _fechaHasta = widget.initialParams.fechaHasta;
  }

  @override
  void dispose() {
    _codigoController.dispose();
    _serenoController.dispose();
    _zonaController.dispose();
    super.dispose();
  }

  Future<void> _selectFechaDesde() async {
    final selected = await _selectDate(context, _fechaDesde);

    if (selected == null) return;

    setState(() {
      _fechaDesde = selected;
    });
  }

  Future<void> _selectFechaHasta() async {
    final selected = await _selectDate(context, _fechaHasta);

    if (selected == null) return;

    setState(() {
      _fechaHasta = selected;
    });
  }

  void _clear() {
    setState(() {
      _codigoController.clear();
      _serenoController.clear();
      _zonaController.clear();
      _turno = null;
      _estado = null;
      _estadoRemision = null;
      _fechaDesde = null;
      _fechaHasta = null;
    });
  }

  void _apply() {
    Navigator.of(context).pop(
      OcurrenciaQueryParams(
        page: 1,
        limit: widget.initialParams.limit,
        codigo: _nullIfEmpty(_codigoController.text),
        serenoId: int.tryParse(_serenoController.text.trim()),
        zonaId: int.tryParse(_zonaController.text.trim()),
        turno: _turno,
        estado: _estado,
        estadoRemision: _estadoRemision,
        fechaDesde: _fechaDesde,
        fechaHasta: _fechaHasta,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomPadding),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Filtrar ocurrencias',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
                TextButton(onPressed: _clear, child: const Text('Limpiar')),
              ],
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _codigoController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Código del clasificador',
                hintText: 'Ejemplo: 030103',
                prefixIcon: Icon(Icons.tag_rounded),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _turno,
              decoration: const InputDecoration(
                labelText: 'Turno',
                prefixIcon: Icon(Icons.schedule_rounded),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'MAÑANA', child: Text('Mañana')),
                DropdownMenuItem(value: 'TARDE', child: Text('Tarde')),
                DropdownMenuItem(value: 'NOCHE', child: Text('Noche')),
              ],
              onChanged: (value) {
                setState(() {
                  _turno = value;
                });
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _estado,
              decoration: const InputDecoration(
                labelText: 'Estado',
                prefixIcon: Icon(Icons.fact_check_outlined),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'BORRADOR', child: Text('Borrador')),
                DropdownMenuItem(value: 'ENVIADO', child: Text('Enviado')),
                DropdownMenuItem(value: 'OBSERVADO', child: Text('Observado')),
                DropdownMenuItem(value: 'VALIDADO', child: Text('Validado')),
                DropdownMenuItem(value: 'ANULADO', child: Text('Anulado')),
              ],
              onChanged: (value) {
                setState(() {
                  _estado = value;
                });
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _estadoRemision,
              decoration: const InputDecoration(
                labelText: 'Estado de remisión',
                prefixIcon: Icon(Icons.send_outlined),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'NO_PREPARADA',
                  child: Text('No preparada'),
                ),
                DropdownMenuItem(value: 'PREPARADA', child: Text('Preparada')),
                DropdownMenuItem(value: 'REMITIDA', child: Text('Remitida')),
              ],
              onChanged: (value) {
                setState(() {
                  _estadoRemision = value;
                });
              },
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _DateFilterField(
                    label: 'Desde',
                    value: _fechaDesde,
                    onTap: _selectFechaDesde,
                    onClear: () {
                      setState(() {
                        _fechaDesde = null;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateFilterField(
                    label: 'Hasta',
                    value: _fechaHasta,
                    onTap: _selectFechaHasta,
                    onClear: () {
                      setState(() {
                        _fechaHasta = null;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _serenoController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'ID sereno',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _zonaController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'ID zona',
                      prefixIcon: Icon(Icons.map_outlined),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: _apply,
              icon: const Icon(Icons.check_rounded),
              label: const Text('Aplicar filtros'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateFilterField extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;
  final VoidCallback onClear;

  const _DateFilterField({
    required this.label,
    required this.value,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today_outlined),
          suffixIcon: value != null
              ? IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded),
                )
              : null,
          border: const OutlineInputBorder(),
        ),
        child: Text(
          value ?? 'Seleccionar',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

String? _nullIfEmpty(String? value) {
  final normalized = value?.trim();

  if (normalized == null || normalized.isEmpty) {
    return null;
  }

  return normalized;
}

Future<String?> _selectDate(BuildContext context, String? currentValue) async {
  final initialDate = DateTime.tryParse(currentValue ?? '') ?? DateTime.now();

  final selected = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: DateTime(2020),
    lastDate: DateTime.now().add(const Duration(days: 365)),
  );

  if (selected == null) return null;

  final month = selected.month.toString().padLeft(2, '0');
  final day = selected.day.toString().padLeft(2, '0');

  return '${selected.year}-$month-$day';
}
