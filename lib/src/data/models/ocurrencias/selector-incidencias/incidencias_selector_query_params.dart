import 'package:equatable/equatable.dart';

class IncidenciasSelectorQueryParams extends Equatable {
  final int page;
  final int limit;
  final String? search;
  final String? tipo;
  final String? estado;
  final int? patrullajeId;

  const IncidenciasSelectorQueryParams({
    this.page = 1,
    this.limit = 20,
    this.search,
    this.tipo,
    this.estado,
    this.patrullajeId,
  });

  IncidenciasSelectorQueryParams copyWith({
    int? page,
    int? limit,
    String? search,
    String? tipo,
    String? estado,
    int? patrullajeId,
    bool clearSearch = false,
    bool clearTipo = false,
    bool clearEstado = false,
    bool clearPatrullajeId = false,
  }) {
    return IncidenciasSelectorQueryParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      search: clearSearch ? null : search ?? this.search,
      tipo: clearTipo ? null : tipo ?? this.tipo,
      estado: clearEstado ? null : estado ?? this.estado,
      patrullajeId: clearPatrullajeId
          ? null
          : patrullajeId ?? this.patrullajeId,
    );
  }

  Map<String, String> toQueryParameters() {
    final query = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    final searchValue = search?.trim();
    final tipoValue = tipo?.trim();
    final estadoValue = estado?.trim();

    if (searchValue != null && searchValue.isNotEmpty) {
      query['search'] = searchValue;
    }

    if (tipoValue != null && tipoValue.isNotEmpty) {
      query['tipo'] = tipoValue;
    }

    if (estadoValue != null && estadoValue.isNotEmpty) {
      query['estado'] = estadoValue;
    }

    if (patrullajeId != null) {
      query['patrullaje_id'] = patrullajeId.toString();
    }

    return query;
  }

  @override
  List<Object?> get props => [page, limit, search, tipo, estado, patrullajeId];
}
