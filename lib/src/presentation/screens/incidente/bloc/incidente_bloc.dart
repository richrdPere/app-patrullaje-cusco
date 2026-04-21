import 'package:bloc/bloc.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/IncidenteUseCases.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/bloc/incidente_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/bloc/incidente_state.dart';

class IncidenteBloc extends Bloc<IncidenteEvent, IncidenteState> {
  final IncidenteUseCases incidenteUseCases;

  IncidenteBloc(this.incidenteUseCases) : super(IncidenteState()) {
    on<CrearIncidenteEvent>(_onCrearIncidente);
  }

  // ==============================
  // CREAR INCIDENCIA
  // ==============================
  Future<void> _onCrearIncidente(
    CrearIncidenteEvent event,
    Emitter<IncidenteState> emit,
  ) async {
    // LOADING
    emit(state.copyWith(isLoading: true, error: null, success: false));

    try {
      final incidencia = await incidenteUseCases.createIncidente.run(
        event.params,
      );

      // SUCCESS
      emit(
        state.copyWith(isLoading: false, success: true, incidencia: incidencia),
      );
    } catch (e) {
      // ERROR
      emit(
        state.copyWith(isLoading: false, success: false, error: e.toString()),
      );
    }
  }
}
