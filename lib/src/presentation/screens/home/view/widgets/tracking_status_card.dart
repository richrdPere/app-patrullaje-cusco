import 'package:flutter/material.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/socket/socket_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/enums/socket_connection_status.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/enums/tracking_transmission_status.dart';

class TrackingStatusCard extends StatelessWidget {
  final SocketState socketState;
  final TrackingState trackingState;

  const TrackingStatusCard({
    super.key,
    required this.socketState,
    required this.trackingState,
  });

  @override
  Widget build(BuildContext context) {
    final serverInfo = _getServerStatus();
    final transmissionInfo = _getTransmissionStatus();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =================================================
          // TÍTULO
          // =================================================
          Row(
            children: [
              Icon(Icons.sensors_rounded, color: Colors.blue.shade700),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Estado de comunicación',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // =================================================
          // CONEXIÓN CON EL SERVIDOR
          // =================================================
          _StatusRow(
            icon: Icons.cloud_outlined,
            title: 'Servidor',
            message: serverInfo.message,
            color: serverInfo.color,
            isLoading: serverInfo.isLoading,
          ),

          // Mensaje adicional del socket.
          if (_hasSocketMessage) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 54),
              child: Text(
                socketState.message!,
                style: TextStyle(color: serverInfo.color, fontSize: 12),
              ),
            ),
          ],

          // Error detallado del socket.
          if (_hasSocketError) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 54),
              child: Text(
                socketState.error!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),

          // =================================================
          // TRANSMISIÓN GPS
          // =================================================
          _StatusRow(
            icon: Icons.location_on_outlined,
            title: 'Ubicación',
            message: transmissionInfo.message,
            color: transmissionInfo.color,
            isLoading: transmissionInfo.isLoading,
          ),

          // =================================================
          // ÚLTIMA CONFIRMACIÓN DE UBICACIÓN
          // =================================================
          if (trackingState.lastTransmissionAt != null) ...[
            const SizedBox(height: 14),
            _InformationContainer(
              icon: Icons.schedule_rounded,
              text:
                  'Última confirmación: '
                  '${_formatDateTime(trackingState.lastTransmissionAt!)}',
            ),
          ],

          // =================================================
          // ÚLTIMA CONEXIÓN CON EL SERVIDOR
          // =================================================
          if (socketState.lastConnectedAt != null) ...[
            const SizedBox(height: 10),
            _InformationContainer(
              icon: Icons.cloud_done_outlined,
              text:
                  'Última conexión: '
                  '${_formatDateTime(socketState.lastConnectedAt!)}',
            ),
          ],

          // =================================================
          // MENSAJE DEL BACKEND
          // =================================================
          if (_hasTransmissionMessage) ...[
            const SizedBox(height: 10),
            Text(
              trackingState.transmissionMessage!,
              style: TextStyle(color: transmissionInfo.color, fontSize: 12),
            ),
          ],

          // =================================================
          // FALLOS CONSECUTIVOS
          // =================================================
          if (trackingState.consecutiveFailures > 0) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 18,
                  color: Colors.red,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${trackingState.consecutiveFailures} '
                    'intento(s) de transmisión fallido(s).',
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // =====================================================
  // VALIDACIONES
  // =====================================================
  bool get _hasTransmissionMessage {
    final message = trackingState.transmissionMessage;

    return message != null && message.trim().isNotEmpty;
  }

  bool get _hasSocketMessage {
    final message = socketState.message;

    return message != null && message.trim().isNotEmpty;
  }

  bool get _hasSocketError {
    final error = socketState.error;

    return error != null && error.trim().isNotEmpty;
  }

  // =====================================================
  // ESTADO DEL SERVIDOR
  // =====================================================
  _StatusInfo _getServerStatus() {
    switch (socketState.status) {
      case SocketConnectionStatus.disconnected:
        return const _StatusInfo(message: 'Desconectado', color: Colors.red);

      case SocketConnectionStatus.connecting:
        return const _StatusInfo(
          message: 'Conectando con el servidor...',
          color: Colors.orange,
          isLoading: true,
        );

      case SocketConnectionStatus.connected:
        return const _StatusInfo(message: 'Conectado', color: Colors.green);

      case SocketConnectionStatus.reconnecting:
        return const _StatusInfo(
          message: 'Reconectando con el servidor...',
          color: Colors.orange,
          isLoading: true,
        );

      case SocketConnectionStatus.error:
        return const _StatusInfo(
          message: 'Error de conexión',
          color: Colors.red,
        );
    }
  }

  // =====================================================
  // ESTADO DE TRANSMISIÓN
  // =====================================================
  _StatusInfo _getTransmissionStatus() {
    if (!socketState.isConnected) {
      if (socketState.isConnecting || socketState.isReconnecting) {
        return const _StatusInfo(
          message: 'Esperando conexión con el servidor...',
          color: Colors.orange,
          isLoading: true,
        );
      }

      return const _StatusInfo(message: 'Sin transmisión', color: Colors.red);
    }

    if (!trackingState.isTracking) {
      return const _StatusInfo(
        message: 'Seguimiento inactivo',
        color: Colors.grey,
      );
    }

    switch (trackingState.transmissionStatus) {
      case TrackingTransmissionStatus.idle:
        return const _StatusInfo(
          message: 'Transmisión pendiente',
          color: Colors.grey,
        );

      case TrackingTransmissionStatus.waitingLocation:
        return const _StatusInfo(
          message: 'Esperando ubicación GPS...',
          color: Colors.orange,
          isLoading: true,
        );

      case TrackingTransmissionStatus.sending:
        return const _StatusInfo(
          message: 'Transmitiendo ubicación...',
          color: Colors.blue,
          isLoading: true,
        );

      case TrackingTransmissionStatus.transmitted:
        return const _StatusInfo(
          message: 'Transmitiendo correctamente',
          color: Colors.green,
        );

      case TrackingTransmissionStatus.omitted:
        return const _StatusInfo(
          message: 'Conectado, sin desplazamiento significativo',
          color: Colors.green,
        );

      case TrackingTransmissionStatus.failed:
        return const _StatusInfo(
          message: 'Error al transmitir ubicación',
          color: Colors.red,
        );
      case TrackingTransmissionStatus.storedOffline:
        // TODO: Handle this case.
        throw UnimplementedError();
      case TrackingTransmissionStatus.synchronizing:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
  }

  // =====================================================
  // FORMATEAR FECHA
  // =====================================================
  String _formatDateTime(DateTime dateTime) {
    final localDate = dateTime.toLocal();

    final day = localDate.day.toString().padLeft(2, '0');

    final month = localDate.month.toString().padLeft(2, '0');

    final year = localDate.year.toString();

    final hour = localDate.hour.toString().padLeft(2, '0');

    final minute = localDate.minute.toString().padLeft(2, '0');

    final second = localDate.second.toString().padLeft(2, '0');

    return '$day/$month/$year '
        '$hour:$minute:$second';
  }
}

// =====================================================
// FILA DE ESTADO
// =====================================================
class _StatusRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Color color;
  final bool isLoading;

  const _StatusRow({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                message,
                style: TextStyle(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: color),
          )
        else
          Icon(_getStatusIcon(), color: color, size: 21),
      ],
    );
  }

  IconData _getStatusIcon() {
    if (color == Colors.green) {
      return Icons.check_circle_rounded;
    }

    if (color == Colors.red) {
      return Icons.cancel_rounded;
    }

    if (color == Colors.orange) {
      return Icons.pending_rounded;
    }

    if (color == Colors.blue) {
      return Icons.sync_rounded;
    }

    return Icons.info_rounded;
  }
}

// =====================================================
// CONTENEDOR DE INFORMACIÓN
// =====================================================
class _InformationContainer extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InformationContainer({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// INFORMACIÓN INTERNA
// =====================================================
class _StatusInfo {
  final String message;
  final Color color;
  final bool isLoading;

  const _StatusInfo({
    required this.message,
    required this.color,
    this.isLoading = false,
  });
}
