import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'reporte_incidente_event.dart';
part 'reporte_incidente_state.dart';

class ReporteIncidenteBloc extends Bloc<ReporteIncidenteEvent, ReporteIncidenteState> {
  ReporteIncidenteBloc() : super(ReporteIncidenteInitial()) {
    on<ReporteIncidenteEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
