import 'package:equatable/equatable.dart';

// Models
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_create_req.dart';
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_query_params.dart';

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

  const GetOcurrenciasPaginado({required this.params});

  @override
  List<Object?> get props => [params];
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

// ============================================================
// LIMPIEZA DE RESPUESTAS
// ============================================================

// *********************************************************
// 5. LIMPIAR RESPUESTA DE CREACIÓN
// *********************************************************

class ClearOcurrenciaCreateResponse extends OcurrenciaEvent {
  const ClearOcurrenciaCreateResponse();
}

// *********************************************************
// 6. LIMPIAR DETALLE
// *********************************************************

class ClearOcurrenciaDetailResponse extends OcurrenciaEvent {
  const ClearOcurrenciaDetailResponse();
}

// *********************************************************
// 7. LIMPIAR PDF
// *********************************************************

class ClearOcurrenciaPdfResponse extends OcurrenciaEvent {
  const ClearOcurrenciaPdfResponse();
}

// *********************************************************
// 8. LIMPIAR LISTADO PAGINADO
// *********************************************************

class ClearOcurrenciaPaginatedResponse extends OcurrenciaEvent {
  const ClearOcurrenciaPaginatedResponse();
}

// ============================================================
// NAVEGACIÓN DEL FORMULARIO
// ============================================================

// *********************************************************
// 9. INICIALIZAR STEPS
// *********************************************************

class InitializeOcurrenciaForm extends OcurrenciaEvent {
  const InitializeOcurrenciaForm();
}

// *********************************************************
// 10. IR A UN STEP
// *********************************************************

class GoToOcurrenciaFormStep extends OcurrenciaEvent {
  final int step;

  const GoToOcurrenciaFormStep({required this.step});

  @override
  List<Object?> get props => [step];
}

// *********************************************************
// 11. SIGUIENTE STEP
// *********************************************************

class NextOcurrenciaFormStep extends OcurrenciaEvent {
  const NextOcurrenciaFormStep();
}

// *********************************************************
// 12. STEP ANTERIOR
// *********************************************************

class PreviousOcurrenciaFormStep extends OcurrenciaEvent {
  const PreviousOcurrenciaFormStep();
}

// *********************************************************
// 13. MARCAR STEP COMO COMPLETADO
// *********************************************************

class CompleteOcurrenciaFormStep extends OcurrenciaEvent {
  final int step;

  const CompleteOcurrenciaFormStep({required this.step});

  @override
  List<Object?> get props => [step];
}

// *********************************************************
// 14. REINICIAR NAVEGACIÓN DEL FORMULARIO
// *********************************************************

class ResetOcurrenciaForm extends OcurrenciaEvent {
  const ResetOcurrenciaForm();
}

// *********************************************************
// 15. RESTABLECER EL BLOC
// *********************************************************

class ResetOcurrenciaState extends OcurrenciaEvent {
  const ResetOcurrenciaState();
}
