import 'dart:io';

import 'package:equatable/equatable.dart';
// import 'package:sis_patrullaje_cusco/src/domain/entities/incidencia_entity.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';

class IncidenteState extends Equatable {
  final bool isLoading;
  final bool success;
  final String? error;
  final IncidenteModel? incidencia;

  final List<File> archivos;
  final double? latitud;
  final double? longitud;
  final String? direccion;

  const IncidenteState({
    this.isLoading = false,
    this.success = false,
    this.error,
    this.incidencia,
    this.archivos = const [],
    this.latitud,
    this.longitud,
    this.direccion,
  });

  IncidenteState copyWith({
    bool? isLoading,
    bool? success,
    String? error,
    IncidenteModel? incidencia,
    List<File>? archivos,
    double? latitud,
    double? longitud,
    String? direccion,
  }) {
    return IncidenteState(
      isLoading: isLoading ?? this.isLoading,
      success: success ?? this.success,
      error: error,
      incidencia: incidencia ?? this.incidencia,
      archivos: archivos ?? this.archivos,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      direccion: direccion ?? this.direccion,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    success,
    error,
    incidencia,
    archivos,
    latitud,
    longitud,
    direccion,
  ];
}
