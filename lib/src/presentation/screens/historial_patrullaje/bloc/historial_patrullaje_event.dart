import 'package:equatable/equatable.dart';
import 'package:sis_patrullaje_cusco/src/data/models/historial_patrullaje/historial_patrullaje_request.dart';

abstract class HistorialPatrullajeEvent extends Equatable {
  const HistorialPatrullajeEvent();

  @override
  List<Object?> get props => [];
}

// ======================================================
// 1. OBTENER HISTORIAL POR PATRULLAJE
// ======================================================
class LoadHistorialPatrullajeEvent extends HistorialPatrullajeEvent {
  final int patrullajeId;
  final bool refresh;

  const LoadHistorialPatrullajeEvent({
    required this.patrullajeId,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [
    patrullajeId,
    refresh,
  ];
}

// ======================================================
// 2. OBTENER DETALLE DE HISTORIAL
// ======================================================
class LoadHistorialDetalleEvent extends HistorialPatrullajeEvent {
  final int historialId;

  const LoadHistorialDetalleEvent({
    required this.historialId,
  });

  @override
  List<Object?> get props => [historialId];
}

// ======================================================
// 3. REGISTRAR HISTORIAL
// ======================================================
class RegisterHistorialEvent extends HistorialPatrullajeEvent {
  final HistorialPatrullajeRequest request;

  const RegisterHistorialEvent({
    required this.request,
  });

  @override
  List<Object?> get props => [request];
}

// ======================================================
// 4. ACTUALIZAR HISTORIAL
// ======================================================
class UpdateHistorialEvent extends HistorialPatrullajeEvent {
  final int historialId;
  final HistorialPatrullajeRequest request;

  const UpdateHistorialEvent({
    required this.historialId,
    required this.request,
  });

  @override
  List<Object?> get props => [
    historialId,
    request,
  ];
}

// ======================================================
// 5. ARCHIVAR HISTORIAL
// ======================================================
class ArchiveHistorialEvent extends HistorialPatrullajeEvent {
  final int historialId;

  const ArchiveHistorialEvent({
    required this.historialId,
  });

  @override
  List<Object?> get props => [historialId];
}

// ======================================================
// 6. LIMPIAR HISTORIAL SELECCIONADO
// ======================================================
class ClearHistorialSelectedEvent extends HistorialPatrullajeEvent {
  const ClearHistorialSelectedEvent();
}

// ======================================================
// 7. LIMPIAR RESULTADO DE ACCIÓN
// ======================================================
class ClearHistorialActionEvent extends HistorialPatrullajeEvent {
  const ClearHistorialActionEvent();
}