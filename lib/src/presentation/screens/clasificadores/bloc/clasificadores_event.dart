import 'package:sis_patrullaje_cusco/src/data/models/clasificadores/clasificador_query_params.dart';

abstract class ClasificadoresEvent {}

// *********************************************************
// 1.- Obtener árbol de clasificadores
// *********************************************************

class GetClasificadorArbol extends ClasificadoresEvent {
  GetClasificadorArbol();
}

// *********************************************************
// 2.- Obtener clasificador por código
// *********************************************************

class GetClasificadorByCodigo extends ClasificadoresEvent {
  final String codigo;

  GetClasificadorByCodigo({required this.codigo});
}

// *********************************************************
// 3.- Obtener clasificadores paginados
// *********************************************************

class GetClasificadoresPaginado extends ClasificadoresEvent {
  final ClasificadorQueryParams params;

  GetClasificadoresPaginado({required this.params});
}

// *********************************************************
// 4.- Limpiar clasificador seleccionado
// *********************************************************

class ClearClasificadorSeleccionado extends ClasificadoresEvent {
  ClearClasificadorSeleccionado();
}

// *********************************************************
// 5.- Limpiar listado paginado
// *********************************************************

class ClearClasificadoresPaginado extends ClasificadoresEvent {
  ClearClasificadoresPaginado();
}

// *********************************************************
// 6.- Limpiar respuestas
// *********************************************************

class ClearClasificadoresState extends ClasificadoresEvent {
  ClearClasificadoresState();
}
