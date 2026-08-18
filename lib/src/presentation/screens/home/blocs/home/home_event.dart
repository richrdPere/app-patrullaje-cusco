import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_data.dart';
import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_sereno_query_params.dart';

abstract class HomeEvent {
  const HomeEvent();
}

// ==========================================================
// HTTP
// ==========================================================

/// Obtiene el patrullaje activo del sereno autenticado.
class LoadPatrullajeActivo extends HomeEvent {
  const LoadPatrullajeActivo();
}

/// Obtiene los patrullajes paginados del sereno autenticado.
///
/// Se utiliza para:
/// - carga inicial;
/// - aplicación de filtros;
/// - búsqueda;
/// - cambio de página;
/// - cambio del límite.
class LoadMisPatrullajes extends HomeEvent {
  final PatrullajeSerenoQueryParams params;

  const LoadMisPatrullajes({this.params = const PatrullajeSerenoQueryParams()});
}

/// Recarga la primera página conservando los filtros actuales.
///
/// Este evento es útil para RefreshIndicator.
class RefreshMisPatrullajes extends HomeEvent {
  const RefreshMisPatrullajes();
}

/// Limpia los filtros y vuelve a cargar la primera página.
class LimpiarFiltrosMisPatrullajes extends HomeEvent {
  const LimpiarFiltrosMisPatrullajes();
}

// ==========================================================
// SOCKET
// ==========================================================
class InitSocketListeners extends HomeEvent {
  const InitSocketListeners();
}

class NuevoPatrullajeRecibido extends HomeEvent {
  final PatrullajeData patrullaje;

  const NuevoPatrullajeRecibido(this.patrullaje);
}

class PatrullajeActualizadoRecibido extends HomeEvent {
  final PatrullajeData patrullaje;

  const PatrullajeActualizadoRecibido(this.patrullaje);
}

// ==========================================================
// USER
// ==========================================================
class AceptarPatrullaje extends HomeEvent {
  final int patrullajeId;

  const AceptarPatrullaje(this.patrullajeId);
}

class FinalizarPatrullaje extends HomeEvent {
  final int patrullajeId;
  final String? observacionFinal;

  const FinalizarPatrullaje({
    required this.patrullajeId,
    this.observacionFinal,
  });
}

class LimpiarPatrullajeFinalizado extends HomeEvent {
  const LimpiarPatrullajeFinalizado();
}
