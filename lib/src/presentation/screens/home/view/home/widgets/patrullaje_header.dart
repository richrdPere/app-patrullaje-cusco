import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/enums/patrullaje_enum.dart';

class PatrullajeHeader extends StatelessWidget {
  final HomeState homeState;

  const PatrullajeHeader({super.key, required this.homeState});

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
        // color: Colors.blue,
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color.fromARGB(255, 12, 38, 145),
            Color.fromARGB(255, 34, 156, 249),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Patrullaje asignado',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 18),

          _InfoRow(
            icon: Icons.location_on_outlined,
            title: 'Zona',
            value: patrullaje.zona.nombre,
          ),

          const SizedBox(height: 10),

          if (patrullaje.unidad != null)
            _InfoRow(
              icon: Icons.directions_car_outlined,
              title: 'Unidad',
              value: patrullaje.unidad.codigo,
            ),

          if (patrullaje.unidad != null) const SizedBox(height: 10),

          // _InfoRow(
          //   icon: Icons.date_range,
          //   title: 'Fecha',
          //   value: _formatDate(patrullaje.fecha),
          // ),

          // const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.schedule_outlined,
            title: 'Horario',
            value:
                '${_formatHora(patrullaje.horaInicio)} - ${_formatHora(patrullaje.horaFin)}',
          ),

          const SizedBox(height: 10),

          _InfoRow(
            icon: Icons.flag_outlined,
            title: 'Estado',
            value: _getStatusText(homeState.status),
          ),

          if (patrullaje.descripcion.trim().isNotEmpty) ...[
            const SizedBox(height: 10),

            _InfoRow(
              icon: Icons.description_outlined,
              title: 'Descripción',
              value: patrullaje.descripcion,
            ),
          ],
        ],
      ),
    );
  }

  // static String _formatDate(DateTime? date) {
  //   if (date == null) return '-';

  //   return DateFormat('HH:mm').format(date);
  // }

  static String _formatHora(String? hora) {
    if (hora == null || hora.isEmpty) return '-';

    final partes = hora.split(':');

    if (partes.length < 2) return hora;

    return '${partes[0]}:${partes[1]}';
  }

  String _getStatusText(PatrullajeStatus status) {
    switch (status) {
      case PatrullajeStatus.asignado:
        return 'Asignado';

      case PatrullajeStatus.aceptando:
        return 'Aceptando...';

      case PatrullajeStatus.enCurso:
        return 'En patrullaje';

      case PatrullajeStatus.finalizado:
        return 'Finalizado';

      case PatrullajeStatus.error:
        return 'Error';

      case PatrullajeStatus.sinAsignacion:
        return 'Sin asignación';
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white, size: 20),

        const SizedBox(width: 10),

        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.white, fontSize: 15),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
