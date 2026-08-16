class ClasificadorQueryParams {
  final int page;
  final int limit;

  final String search;
  final String codigo;

  final int? categoriaGenericaId;
  final int? categoriaEspecificaId;
  final int? versionId;

  final bool? estado;
  final bool incluirReglas;

  const ClasificadorQueryParams({
    this.page = 1,
    this.limit = 20,
    this.search = '',
    this.codigo = '',
    this.categoriaGenericaId,
    this.categoriaEspecificaId,
    this.versionId,
    this.estado = true,
    this.incluirReglas = true,
  });

  Map<String, String> toQueryParameters() {
    final normalizedSearch = search.trim();
    final normalizedCodigo = codigo.trim();

    return {
      'page': page.toString(),
      'limit': limit.toString(),

      if (normalizedSearch.isNotEmpty) 'search': normalizedSearch,

      if (normalizedCodigo.isNotEmpty) 'codigo': normalizedCodigo,

      if (categoriaGenericaId != null)
        'categoriaGenericaId': categoriaGenericaId.toString(),

      if (categoriaEspecificaId != null)
        'categoriaEspecificaId': categoriaEspecificaId.toString(),

      if (versionId != null) 'versionId': versionId.toString(),

      if (estado != null) 'estado': estado.toString(),

      'incluirReglas': incluirReglas.toString(),
    };
  }

  ClasificadorQueryParams copyWith({
    int? page,
    int? limit,
    String? search,
    String? codigo,
    int? categoriaGenericaId,
    int? categoriaEspecificaId,
    int? versionId,
    bool? estado,
    bool? incluirReglas,
    bool clearCategoriaGenericaId = false,
    bool clearCategoriaEspecificaId = false,
    bool clearVersionId = false,
    bool clearEstado = false,
  }) {
    return ClasificadorQueryParams(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      search: search ?? this.search,
      codigo: codigo ?? this.codigo,
      categoriaGenericaId: clearCategoriaGenericaId
          ? null
          : categoriaGenericaId ?? this.categoriaGenericaId,
      categoriaEspecificaId: clearCategoriaEspecificaId
          ? null
          : categoriaEspecificaId ?? this.categoriaEspecificaId,
      versionId: clearVersionId ? null : versionId ?? this.versionId,
      estado: clearEstado ? null : estado ?? this.estado,
      incluirReglas: incluirReglas ?? this.incluirReglas,
    );
  }

  ClasificadorQueryParams nextPage() {
    return copyWith(page: page + 1);
  }

  ClasificadorQueryParams previousPage() {
    return copyWith(page: page > 1 ? page - 1 : 1);
  }

  ClasificadorQueryParams resetPage() {
    return copyWith(page: 1);
  }
}
