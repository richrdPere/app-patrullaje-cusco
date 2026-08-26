import 'package:equatable/equatable.dart';

// Models
import 'package:sis_patrullaje_cusco/src/data/models/models.dart';

abstract class OcurrenciaEvent extends Equatable {
  const OcurrenciaEvent();

  @override
  List<Object?> get props => [];
}

// ============================================================
// OPERACIONES DEL BACKEND
// ============================================================

// *********************************************************
// 1. CREAR OCURRENCIA
// *********************************************************

class CreateOcurrencia extends OcurrenciaEvent {
  final CreateOcurrenciaRequest request;

  const CreateOcurrencia({required this.request});

  @override
  List<Object?> get props => [request];
}

// *********************************************************
// 2. OBTENER OCURRENCIAS PAGINADAS
// *********************************************************

class GetOcurrenciasPaginado extends OcurrenciaEvent {
  final OcurrenciaQueryParams params;
  final bool refresh;

  const GetOcurrenciasPaginado({required this.params, this.refresh = false});

  @override
  List<Object?> get props => [params, refresh];
}

// *********************************************************
// 3. OBTENER OCURRENCIA POR ID
// *********************************************************

class GetOcurrenciaById extends OcurrenciaEvent {
  final int ocurrenciaId;

  const GetOcurrenciaById({required this.ocurrenciaId});

  @override
  List<Object?> get props => [ocurrenciaId];
}

// *********************************************************
// 4. OBTENER PDF
// *********************************************************

class GetOcurrenciaPdf extends OcurrenciaEvent {
  final int ocurrenciaId;

  const GetOcurrenciaPdf({required this.ocurrenciaId});

  @override
  List<Object?> get props => [ocurrenciaId];
}

// *********************************************************
// 5. OBTENER INCIDENCIAS DISPONIBLES PARA EL SELECTOR
// *********************************************************

class GetIncidenciasSelector extends OcurrenciaEvent {
  final IncidenciasSelectorQueryParams params;
  final bool refresh;

  const GetIncidenciasSelector({required this.params, this.refresh = false});

  @override
  List<Object?> get props => [params, refresh];
}

// *********************************************************
// 6. CARGAR MÁS INCIDENCIAS DEL SELECTOR
// *********************************************************

class LoadMoreIncidenciasSelector extends OcurrenciaEvent {
  const LoadMoreIncidenciasSelector();
}

// ============================================================
// SELECCIÓN DE INCIDENCIA
// ============================================================

// *********************************************************
// 7. SELECCIONAR INCIDENCIA
// *********************************************************

class SelectIncidenciaOcurrencia extends OcurrenciaEvent {
  final IncidenciaSelectorData incidencia;

  const SelectIncidenciaOcurrencia({required this.incidencia});

  @override
  List<Object?> get props => [incidencia];
}

// *********************************************************
// 8. LIMPIAR INCIDENCIA SELECCIONADA
// *********************************************************

class ClearSelectedIncidenciaOcurrencia extends OcurrenciaEvent {
  const ClearSelectedIncidenciaOcurrencia();
}

// *********************************************************
// 9. REMOVER INCIDENCIA DEL SELECTOR
// *********************************************************

/// Remueve localmente una incidencia después de que haya sido
/// asociada correctamente a una ocurrencia.
///
/// El backend continuará siendo la fuente oficial y volverá a
/// excluirla cuando el selector sea consultado nuevamente.
class RemoveIncidenciaFromSelector extends OcurrenciaEvent {
  final int incidenciaId;

  const RemoveIncidenciaFromSelector({required this.incidenciaId});

  @override
  List<Object?> get props => [incidenciaId];
}

// ============================================================
// LIMPIEZA DE RESPUESTAS
// ============================================================

// *********************************************************
// 10. LIMPIAR RESPUESTA DE CREACIÓN
// *********************************************************

class ClearOcurrenciaCreateResponse extends OcurrenciaEvent {
  const ClearOcurrenciaCreateResponse();
}

// *********************************************************
// 11. LIMPIAR DETALLE
// *********************************************************

class ClearOcurrenciaDetailResponse extends OcurrenciaEvent {
  const ClearOcurrenciaDetailResponse();
}

// *********************************************************
// 12. LIMPIAR PDF
// *********************************************************

class ClearOcurrenciaPdfResponse extends OcurrenciaEvent {
  const ClearOcurrenciaPdfResponse();
}

// *********************************************************
// 13. LIMPIAR LISTADO PAGINADO
// *********************************************************

class ClearOcurrenciaPaginatedResponse extends OcurrenciaEvent {
  const ClearOcurrenciaPaginatedResponse();
}

// *********************************************************
// 14. LIMPIAR SELECTOR DE INCIDENCIAS
// *********************************************************

/// Limpia la respuesta, el listado, los parámetros y la
/// incidencia seleccionada.
class ClearIncidenciasSelector extends OcurrenciaEvent {
  const ClearIncidenciasSelector();
}

// *********************************************************
// 15. LIMPIAR SOLO EL ERROR DEL SELECTOR
// *********************************************************

/// Conserva el listado previamente cargado y elimina únicamente
/// la respuesta de error del selector.
class ClearIncidenciasSelectorError extends OcurrenciaEvent {
  const ClearIncidenciasSelectorError();
}

// ============================================================
// NAVEGACIÓN DEL FORMULARIO
// ============================================================

// *********************************************************
// 16. INICIALIZAR STEPS
// *********************************************************

class InitializeOcurrenciaForm extends OcurrenciaEvent {
  const InitializeOcurrenciaForm();
}

// *********************************************************
// 17. IR A UN STEP
// *********************************************************

class GoToOcurrenciaFormStep extends OcurrenciaEvent {
  final int step;

  const GoToOcurrenciaFormStep({required this.step});

  @override
  List<Object?> get props => [step];
}

// *********************************************************
// 18. SIGUIENTE STEP
// *********************************************************

class NextOcurrenciaFormStep extends OcurrenciaEvent {
  const NextOcurrenciaFormStep();
}

// *********************************************************
// 19. STEP ANTERIOR
// *********************************************************

class PreviousOcurrenciaFormStep extends OcurrenciaEvent {
  const PreviousOcurrenciaFormStep();
}

// *********************************************************
// 20. MARCAR STEP COMO COMPLETADO
// *********************************************************

class CompleteOcurrenciaFormStep extends OcurrenciaEvent {
  final int step;

  const CompleteOcurrenciaFormStep({required this.step});

  @override
  List<Object?> get props => [step];
}

// *********************************************************
// 21. REINICIAR NAVEGACIÓN DEL FORMULARIO
// *********************************************************

class ResetOcurrenciaForm extends OcurrenciaEvent {
  const ResetOcurrenciaForm();
}

// *********************************************************
// 22. RESTABLECER EL BLOC
// *********************************************************

class ResetOcurrenciaState extends OcurrenciaEvent {
  const ResetOcurrenciaState();
}

// *********************************************************
// 23. LOCATION
// *********************************************************
class GetOcurrenciaCurrentLocation extends OcurrenciaEvent {
  const GetOcurrenciaCurrentLocation();
}

class ClearOcurrenciaLocation extends OcurrenciaEvent {
  const ClearOcurrenciaLocation();
}

class OpenOcurrenciaLocationSettings extends OcurrenciaEvent {
  const OpenOcurrenciaLocationSettings();
}

class OpenOcurrenciaAppSettings extends OcurrenciaEvent {
  const OpenOcurrenciaAppSettings();
}
