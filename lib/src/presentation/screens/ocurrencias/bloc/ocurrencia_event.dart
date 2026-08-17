import 'package:equatable/equatable.dart';
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_create_req.dart';
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_query_params.dart';

abstract class OcurrenciaEvent extends Equatable {
  const OcurrenciaEvent();

  @override
  List<Object?> get props => [];
}

// *********************************************************
// 1.- Crear ocurrencia
// *********************************************************
class CreateOcurrencia extends OcurrenciaEvent {
  final CreateOcurrenciaRequest request;

  const CreateOcurrencia({required this.request});

  @override
  List<Object?> get props => [request];
}

// *********************************************************
// 2.- Obtener ocurrencias paginadas
// *********************************************************
class GetOcurrenciasPaginado extends OcurrenciaEvent {
  final OcurrenciaQueryParams params;

  const GetOcurrenciasPaginado({required this.params});

  @override
  List<Object?> get props => [params];
}

// *********************************************************
// 3.- Obtener ocurrencia por ID
// *********************************************************
class GetOcurrenciaById extends OcurrenciaEvent {
  final int ocurrenciaId;

  const GetOcurrenciaById({required this.ocurrenciaId});

  @override
  List<Object?> get props => [ocurrenciaId];
}

// *********************************************************
// 4.- Obtener PDF
// *********************************************************
class GetOcurrenciaPdf extends OcurrenciaEvent {
  final int ocurrenciaId;

  const GetOcurrenciaPdf({required this.ocurrenciaId});

  @override
  List<Object?> get props => [ocurrenciaId];
}

// *********************************************************
// 5.- Limpiar respuesta de creación
// *********************************************************
class ClearOcurrenciaCreateResponse extends OcurrenciaEvent {
  const ClearOcurrenciaCreateResponse();
}

// *********************************************************
// 6.- Limpiar detalle
// *********************************************************
class ClearOcurrenciaDetailResponse extends OcurrenciaEvent {
  const ClearOcurrenciaDetailResponse();
}

// *********************************************************
// 7.- Limpiar PDF
// *********************************************************
class ClearOcurrenciaPdfResponse extends OcurrenciaEvent {
  const ClearOcurrenciaPdfResponse();
}

// *********************************************************
// 8.- Limpiar listado paginado
// *********************************************************
class ClearOcurrenciaPaginatedResponse extends OcurrenciaEvent {
  const ClearOcurrenciaPaginatedResponse();
}

// *********************************************************
// 9.- Restablecer BLoC
// *********************************************************
class ResetOcurrenciaState extends OcurrenciaEvent {
  const ResetOcurrenciaState();
}
