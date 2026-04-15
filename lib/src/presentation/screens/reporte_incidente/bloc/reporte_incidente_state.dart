part of 'reporte_incidente_bloc.dart';

sealed class ReporteIncidenteState extends Equatable {
  const ReporteIncidenteState();
  
  @override
  List<Object> get props => [];
}

final class ReporteIncidenteInitial extends ReporteIncidenteState {}
