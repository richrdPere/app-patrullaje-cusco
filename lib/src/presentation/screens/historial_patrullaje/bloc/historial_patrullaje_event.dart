import 'dart:io';

import 'package:equatable/equatable.dart';

import 'package:sis_patrullaje_cusco/src/data/models/models.dart';

abstract class HistorialPatrullajeEvent extends Equatable {
  const HistorialPatrullajeEvent();

  @override
  List<Object?> get props => const [];
}

// ==========================================================
// 1. OBTENER HISTORIAL POR PATRULLAJE
// ==========================================================
class LoadHistorialPatrullajeEvent extends HistorialPatrullajeEvent {
  final int patrullajeId;
  final bool refresh;

  const LoadHistorialPatrullajeEvent({
    required this.patrullajeId,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [patrullajeId, refresh];
}

// ==========================================================
// 2. OBTENER DETALLE DE HISTORIAL
// ==========================================================
class LoadHistorialDetalleEvent extends HistorialPatrullajeEvent {
  final int historialId;

  const LoadHistorialDetalleEvent({required this.historialId});

  @override
  List<Object?> get props => [historialId];
}

// ==========================================================
// 3. CREAR HISTORIAL
// ==========================================================
class CreateHistorialEvent extends HistorialPatrullajeEvent {
  final CreateHistorialRequest request;

  const CreateHistorialEvent({required this.request});

  @override
  List<Object?> get props => [request];
}

// ==========================================================
// 4. CREAR OBSERVACIÓN CON ARCHIVOS
// ==========================================================
class CreateObservacionConArchivosEvent extends HistorialPatrullajeEvent {
  final CreateHistorialRequest request;
  final List<File> archivos;

  CreateObservacionConArchivosEvent({
    required this.request,
    required List<File> archivos,
  }) : archivos = List<File>.unmodifiable(archivos);

  @override
  List<Object?> get props => [request, archivos];
}

// ==========================================================
// 5. OBTENER CONTEXTO OPERATIVO DE UNA ZONA
// ==========================================================
class LoadContextoZonaEvent extends HistorialPatrullajeEvent {
  final int zonaId;
  final ContextoZonaQueryParams params;
  final bool refresh;

  const LoadContextoZonaEvent({
    required this.zonaId,
    this.params = const ContextoZonaQueryParams(),
    this.refresh = false,
  });

  @override
  List<Object?> get props => [zonaId, params, refresh];
}

// ==========================================================
// 6. OBTENER INFORMACIÓN PARA EL SIGUIENTE TURNO
// ==========================================================
class LoadSiguienteTurnoEvent extends HistorialPatrullajeEvent {
  final SiguienteTurnoQueryParams params;
  final bool refresh;

  const LoadSiguienteTurnoEvent({
    this.params = const SiguienteTurnoQueryParams(),
    this.refresh = false,
  });

  @override
  List<Object?> get props => [params, refresh];
}

// ==========================================================
// 7. ACTUALIZAR HISTORIAL
// ==========================================================
class UpdateHistorialEvent extends HistorialPatrullajeEvent {
  final int historialId;
  final CreateHistorialRequest request;

  const UpdateHistorialEvent({
    required this.historialId,
    required this.request,
  });

  @override
  List<Object?> get props => [historialId, request];
}

// ==========================================================
// 8. ARCHIVAR HISTORIAL
// ==========================================================
class ArchiveHistorialEvent extends HistorialPatrullajeEvent {
  final int historialId;

  const ArchiveHistorialEvent({required this.historialId});

  @override
  List<Object?> get props => [historialId];
}

// ==========================================================
// 9. LIMPIAR HISTORIAL SELECCIONADO
// ==========================================================
class ClearHistorialSelectedEvent extends HistorialPatrullajeEvent {
  const ClearHistorialSelectedEvent();
}

// ==========================================================
// 10. LIMPIAR CONTEXTO DE ZONA
// ==========================================================
class ClearContextoZonaEvent extends HistorialPatrullajeEvent {
  const ClearContextoZonaEvent();
}

// ==========================================================
// 11. LIMPIAR INFORMACIÓN DEL TURNO ANTERIOR
// ==========================================================
class ClearSiguienteTurnoEvent extends HistorialPatrullajeEvent {
  const ClearSiguienteTurnoEvent();
}

// ==========================================================
// 12. LIMPIAR RESULTADO DE ACCIÓN
// ==========================================================
class ClearHistorialActionEvent extends HistorialPatrullajeEvent {
  const ClearHistorialActionEvent();
}
