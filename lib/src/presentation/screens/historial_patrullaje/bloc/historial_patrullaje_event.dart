import 'package:equatable/equatable.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/historial_patrullaje_model.dart';

abstract class HistorialPatrullajeEvent extends Equatable {
  const HistorialPatrullajeEvent();

  @override
  List<Object?> get props => [];
}

// ======================================================
// OBTENER HISTORIAL POR PATRULLAJE
// ======================================================
class LoadHistorialPatrullajeEvent extends HistorialPatrullajeEvent {
  final int patrullajeId;

  const LoadHistorialPatrullajeEvent(this.patrullajeId);

  @override
  List<Object?> get props => [patrullajeId];
}

// ======================================================
// OBTENER DETALLE
// ======================================================
class LoadHistorialDetalleEvent extends HistorialPatrullajeEvent {
  final int historialId;

  const LoadHistorialDetalleEvent(this.historialId);

  @override
  List<Object?> get props => [historialId];
}

// ======================================================
// REGISTRAR
// ======================================================
class RegisterHistorialEvent extends HistorialPatrullajeEvent {
  final HistorialPatrullajeModel historial;

  const RegisterHistorialEvent(this.historial);

  @override
  List<Object?> get props => [historial];
}

// ======================================================
// EDITAR
// ======================================================
class UpdateHistorialEvent extends HistorialPatrullajeEvent {
  final HistorialPatrullajeModel historial;

  const UpdateHistorialEvent(this.historial);

  @override
  List<Object?> get props => [historial];
}

// ======================================================
// ARCHIVAR
// ======================================================
class ArchiveHistorialEvent extends HistorialPatrullajeEvent {
  final int historialId;

  const ArchiveHistorialEvent(this.historialId);

  @override
  List<Object?> get props => [historialId];
}
