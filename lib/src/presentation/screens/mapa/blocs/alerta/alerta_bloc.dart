import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:sis_patrullaje_cusco/src/domain/use_cases/alerta/AlertUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/socket/SocketUseCases.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/alerta/alerta_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/alerta/alerta_state.dart';

class AlertBloc extends Bloc<AlertEvent, AlertState> {
  // final AlertUseCases alertUseCases;
  final SocketUseCases socketUseCases;

  AlertBloc(this.socketUseCases) : super(AlertState()) {
    on<SendAlertEvent>(_onSendAlert);
  }

  Future<void> _onSendAlert(
    SendAlertEvent event,
    Emitter<AlertState> emit,
  ) async {
    emit(state.copyWith(isSending: true, success: false, error: null));

    try {
      final socket = socketUseCases.getSocket.run();

      socket.emitWithAck(
        "alerta_sereno",
        {"mensaje": "Alerta desde app", "lat": event.lat, "lng": event.lng},
        ack: (response) {
          print("ACK: $response");
        },
      );

      emit(state.copyWith(isSending: false, success: true));
    } catch (e) {
      emit(state.copyWith(isSending: false, error: e.toString()));
    }
  }
}
