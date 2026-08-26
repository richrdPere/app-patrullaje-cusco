import 'package:equatable/equatable.dart';

// Models
import 'package:sis_patrullaje_cusco/src/data/models/models.dart';

// Resource
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class OcurrenciaState extends Equatable {
  // ==========================================================
  // RESPUESTAS DEL BACKEND
  // ==========================================================

  /// Respuesta al crear una ocurrencia.
  final Resource<ApiResponse<OcurrenciaDetalleData>> createResponse;

  /// Respuesta del listado paginado.
  final Resource<ApiResponse<OcurrenciaPaginated>> paginatedResponse;

  /// Respuesta del detalle por ID.
  final Resource<ApiResponse<OcurrenciaDetalleData>> detailResponse;

  /// Respuesta del PDF.
  final Resource<OcurrenciaPdfData> pdfResponse;

  /// Respuesta del selector de incidencias disponibles.
  final Resource<ApiResponse<IncidenciasSelectorPaginated>>
  incidenciasSelectorResponse;

  // ==========================================================
  // SELECTOR DE INCIDENCIAS
  // ==========================================================

  /// Listado acumulado de incidencias disponibles.
  ///
  /// Es independiente de [incidenciasSelectorResponse] porque
  /// permite acumular los elementos al cargar más páginas.
  final List<IncidenciaSelectorData> incidenciasSelector;

  /// Parámetros utilizados en la última consulta.
  final IncidenciasSelectorQueryParams? incidenciasSelectorParams;

  /// Página actualmente cargada.
  final int incidenciasSelectorPage;

  /// Cantidad de elementos solicitados por página.
  final int incidenciasSelectorLimit;

  /// Cantidad total de incidencias disponibles.
  final int incidenciasSelectorTotalItems;

  /// Cantidad total de páginas.
  final int incidenciasSelectorTotalPages;

  /// Indica si existe una siguiente página.
  final bool incidenciasSelectorHasMore;

  /// Indica si se está cargando una página adicional.
  final bool isLoadingMoreIncidenciasSelector;

  /// Incidencia seleccionada en el step de generalidades.
  final IncidenciaSelectorData? selectedIncidencia;

  // ==========================================================
  // FORMULARIO POR STEPS
  // ==========================================================

  /// Índice del paso actual.
  ///
  /// 0: Contexto y generalidades
  /// 1: Atención y ubicación
  /// 2: Personas involucradas
  /// 3: Intervención
  /// 4: Revisión
  final int currentFormStep;

  /// Cantidad total de pasos.
  final int totalFormSteps;

  /// Pasos que ya fueron validados.
  final List<int> completedFormSteps;

  const OcurrenciaState({
    required this.createResponse,
    required this.paginatedResponse,
    required this.detailResponse,
    required this.pdfResponse,
    required this.incidenciasSelectorResponse,
    this.incidenciasSelector = const [],
    this.incidenciasSelectorParams,
    this.incidenciasSelectorPage = 1,
    this.incidenciasSelectorLimit = 20,
    this.incidenciasSelectorTotalItems = 0,
    this.incidenciasSelectorTotalPages = 0,
    this.incidenciasSelectorHasMore = true,
    this.isLoadingMoreIncidenciasSelector = false,
    this.selectedIncidencia,
    this.currentFormStep = 0,
    this.totalFormSteps = 5,
    this.completedFormSteps = const [],
  });

  // ==========================================================
  // ESTADO INICIAL
  // ==========================================================

  factory OcurrenciaState.initial() {
    return OcurrenciaState(
      createResponse: Initial<ApiResponse<OcurrenciaDetalleData>>(),
      paginatedResponse: Initial<ApiResponse<OcurrenciaPaginated>>(),
      detailResponse: Initial<ApiResponse<OcurrenciaDetalleData>>(),
      pdfResponse: Initial<OcurrenciaPdfData>(),
      incidenciasSelectorResponse:
          Initial<ApiResponse<IncidenciasSelectorPaginated>>(),
      incidenciasSelector: const [],
      incidenciasSelectorParams: null,
      incidenciasSelectorPage: 1,
      incidenciasSelectorLimit: 20,
      incidenciasSelectorTotalItems: 0,
      incidenciasSelectorTotalPages: 0,
      incidenciasSelectorHasMore: true,
      isLoadingMoreIncidenciasSelector: false,
      selectedIncidencia: null,
      currentFormStep: 0,
      totalFormSteps: 5,
      completedFormSteps: const [],
    );
  }

  // ==========================================================
  // COPY WITH
  // ==========================================================

  OcurrenciaState copyWith({
    Resource<ApiResponse<OcurrenciaDetalleData>>? createResponse,
    Resource<ApiResponse<OcurrenciaPaginated>>? paginatedResponse,
    Resource<ApiResponse<OcurrenciaDetalleData>>? detailResponse,
    Resource<OcurrenciaPdfData>? pdfResponse,
    Resource<ApiResponse<IncidenciasSelectorPaginated>>?
    incidenciasSelectorResponse,
    List<IncidenciaSelectorData>? incidenciasSelector,
    IncidenciasSelectorQueryParams? incidenciasSelectorParams,
    int? incidenciasSelectorPage,
    int? incidenciasSelectorLimit,
    int? incidenciasSelectorTotalItems,
    int? incidenciasSelectorTotalPages,
    bool? incidenciasSelectorHasMore,
    bool? isLoadingMoreIncidenciasSelector,
    IncidenciaSelectorData? selectedIncidencia,
    int? currentFormStep,
    int? totalFormSteps,
    List<int>? completedFormSteps,

    // Limpiezas explícitas
    bool clearIncidenciasSelectorParams = false,
    bool clearSelectedIncidencia = false,
    bool clearCompletedFormSteps = false,
  }) {
    return OcurrenciaState(
      createResponse: createResponse ?? this.createResponse,
      paginatedResponse: paginatedResponse ?? this.paginatedResponse,
      detailResponse: detailResponse ?? this.detailResponse,
      pdfResponse: pdfResponse ?? this.pdfResponse,
      incidenciasSelectorResponse:
          incidenciasSelectorResponse ?? this.incidenciasSelectorResponse,
      incidenciasSelector: incidenciasSelector ?? this.incidenciasSelector,
      incidenciasSelectorParams: clearIncidenciasSelectorParams
          ? null
          : incidenciasSelectorParams ?? this.incidenciasSelectorParams,
      incidenciasSelectorPage:
          incidenciasSelectorPage ?? this.incidenciasSelectorPage,
      incidenciasSelectorLimit:
          incidenciasSelectorLimit ?? this.incidenciasSelectorLimit,
      incidenciasSelectorTotalItems:
          incidenciasSelectorTotalItems ?? this.incidenciasSelectorTotalItems,
      incidenciasSelectorTotalPages:
          incidenciasSelectorTotalPages ?? this.incidenciasSelectorTotalPages,
      incidenciasSelectorHasMore:
          incidenciasSelectorHasMore ?? this.incidenciasSelectorHasMore,
      isLoadingMoreIncidenciasSelector:
          isLoadingMoreIncidenciasSelector ??
          this.isLoadingMoreIncidenciasSelector,
      selectedIncidencia: clearSelectedIncidencia
          ? null
          : selectedIncidencia ?? this.selectedIncidencia,
      currentFormStep: currentFormStep ?? this.currentFormStep,
      totalFormSteps: totalFormSteps ?? this.totalFormSteps,
      completedFormSteps: clearCompletedFormSteps
          ? const []
          : completedFormSteps ?? this.completedFormSteps,
    );
  }

  // ==========================================================
  // GETTERS DE CARGA
  // ==========================================================

  bool get isCreating {
    return createResponse is Loading;
  }

  bool get isLoadingPaginated {
    return paginatedResponse is Loading;
  }

  bool get isLoadingDetail {
    return detailResponse is Loading;
  }

  bool get isLoadingPdf {
    return pdfResponse is Loading;
  }

  /// Carga inicial o refresh del selector.
  bool get isLoadingIncidenciasSelector {
    return incidenciasSelectorResponse
        is Loading<ApiResponse<IncidenciasSelectorPaginated>>;
  }

  bool get hasAnyLoading {
    return isCreating ||
        isLoadingPaginated ||
        isLoadingDetail ||
        isLoadingPdf ||
        isLoadingIncidenciasSelector ||
        isLoadingMoreIncidenciasSelector;
  }

  // ==========================================================
  // GETTERS DEL SELECTOR DE INCIDENCIAS
  // ==========================================================

  /// Indica si existen incidencias disponibles.
  bool get hasIncidenciasSelector {
    return incidenciasSelector.isNotEmpty;
  }

  /// Indica si el selector no tiene resultados.
  bool get isIncidenciasSelectorEmpty {
    return !isLoadingIncidenciasSelector && incidenciasSelector.isEmpty;
  }

  /// Indica si existe una incidencia seleccionada.
  bool get hasSelectedIncidencia {
    return selectedIncidencia != null;
  }

  /// ID que debe enviarse en CreateOcurrenciaRequest.
  int? get selectedIncidenciaId {
    return selectedIncidencia?.id;
  }

  /// Indica si se puede cargar la siguiente página.
  bool get canLoadMoreIncidenciasSelector {
    return incidenciasSelectorHasMore &&
        !isLoadingIncidenciasSelector &&
        !isLoadingMoreIncidenciasSelector;
  }

  /// Indica si se está cargando el selector y todavía
  /// no existen resultados visibles.
  bool get showIncidenciasSelectorLoading {
    return isLoadingIncidenciasSelector && incidenciasSelector.isEmpty;
  }

  /// Indica si ocurrió un error y no existen datos previos.
  bool get showIncidenciasSelectorError {
    return incidenciasSelectorError != null && incidenciasSelector.isEmpty;
  }

  // ==========================================================
  // GETTERS DEL FORMULARIO
  // ==========================================================

  bool get isFirstFormStep {
    return currentFormStep == 0;
  }

  bool get isLastFormStep {
    return currentFormStep == totalFormSteps - 1;
  }

  bool get canGoPreviousFormStep {
    return currentFormStep > 0 && !isCreating;
  }

  bool get canGoNextFormStep {
    return currentFormStep < totalFormSteps - 1 && !isCreating;
  }

  /// Progreso entre 0.0 y 1.0.
  double get formProgress {
    if (totalFormSteps <= 0) {
      return 0;
    }

    return (currentFormStep + 1) / totalFormSteps;
  }

  /// Número visible para el usuario, empezando en 1.
  int get currentFormStepNumber {
    return currentFormStep + 1;
  }

  bool isFormStepCompleted(int step) {
    return completedFormSteps.contains(step);
  }

  bool isValidFormStep(int step) {
    return step >= 0 && step < totalFormSteps;
  }

  /// Permite volver al paso actual o a uno anterior.
  bool canOpenFormStep(int step) {
    return isValidFormStep(step) && step <= currentFormStep && !isCreating;
  }

  String get currentFormStepTitle {
    switch (currentFormStep) {
      case 0:
        return 'Contexto y generalidades';

      case 1:
        return 'Atención y ubicación';

      case 2:
        return 'Personas involucradas';

      case 3:
        return 'Intervención';

      case 4:
        return 'Revisión';

      default:
        return 'Formulario de ocurrencia';
    }
  }

  String get currentFormStepDescription {
    switch (currentFormStep) {
      case 0:
        return 'Selecciona el origen y registra el contexto operativo.';

      case 1:
        return 'Registra los tiempos, el lugar y la ubicación.';

      case 2:
        return 'Registra las personas relacionadas con el hecho.';

      case 3:
        return 'Registra consecuencias, medios y efectivos PNP.';

      case 4:
        return 'Verifica la información antes de guardar.';

      default:
        return '';
    }
  }

  // ==========================================================
  // DATOS EXITOSOS: CREACIÓN
  // ==========================================================

  ApiResponse<OcurrenciaDetalleData>? get createdOcurrencia {
    final resource = createResponse;

    if (resource is Success<ApiResponse<OcurrenciaDetalleData>>) {
      return resource.data;
    }

    return null;
  }

  OcurrenciaDetalleData? get createdOcurrenciaData {
    return createdOcurrencia?.data;
  }

  bool get createSuccess {
    return createResponse is Success<ApiResponse<OcurrenciaDetalleData>> &&
        createdOcurrenciaData != null;
  }

  // ==========================================================
  // DATOS EXITOSOS: LISTADO
  // ==========================================================

  ApiResponse<OcurrenciaPaginated>? get paginatedOcurrencias {
    final resource = paginatedResponse;

    if (resource is Success<ApiResponse<OcurrenciaPaginated>>) {
      return resource.data;
    }

    return null;
  }

  OcurrenciaPaginated? get paginatedOcurrenciasData {
    return paginatedOcurrencias?.data;
  }

  // ==========================================================
  // DATOS EXITOSOS: DETALLE
  // ==========================================================

  ApiResponse<OcurrenciaDetalleData>? get ocurrenciaDetail {
    final resource = detailResponse;

    if (resource is Success<ApiResponse<OcurrenciaDetalleData>>) {
      return resource.data;
    }

    return null;
  }

  OcurrenciaDetalleData? get ocurrenciaDetailData {
    return ocurrenciaDetail?.data;
  }

  // ==========================================================
  // DATOS EXITOSOS: PDF
  // ==========================================================

  OcurrenciaPdfData? get ocurrenciaPdf {
    final resource = pdfResponse;

    if (resource is Success<OcurrenciaPdfData>) {
      return resource.data;
    }

    return null;
  }

  // ==========================================================
  // DATOS EXITOSOS: SELECTOR DE INCIDENCIAS
  // ==========================================================

  ApiResponse<IncidenciasSelectorPaginated>?
  get incidenciasSelectorApiResponse {
    final resource = incidenciasSelectorResponse;

    if (resource is Success<ApiResponse<IncidenciasSelectorPaginated>>) {
      return resource.data;
    }

    return null;
  }

  /// Contenido paginado de la última petición.
  ///
  /// Para mostrar el listado en pantalla se debe utilizar
  /// [incidenciasSelector], porque contiene las páginas
  /// acumuladas.
  IncidenciasSelectorPaginated? get incidenciasSelectorPaginatedData {
    return incidenciasSelectorApiResponse?.data;
  }

  bool get incidenciasSelectorSuccess {
    return incidenciasSelectorResponse
        is Success<ApiResponse<IncidenciasSelectorPaginated>>;
  }

  // ==========================================================
  // ERRORES
  // ==========================================================

  String? get createError {
    final resource = createResponse;

    if (resource is ErrorData<ApiResponse<OcurrenciaDetalleData>>) {
      return resource.message;
    }

    return null;
  }

  String? get paginatedError {
    final resource = paginatedResponse;

    if (resource is ErrorData<ApiResponse<OcurrenciaPaginated>>) {
      return resource.message;
    }

    return null;
  }

  String? get detailError {
    final resource = detailResponse;

    if (resource is ErrorData<ApiResponse<OcurrenciaDetalleData>>) {
      return resource.message;
    }

    return null;
  }

  String? get pdfError {
    final resource = pdfResponse;

    if (resource is ErrorData<OcurrenciaPdfData>) {
      return resource.message;
    }

    return null;
  }

  String? get incidenciasSelectorError {
    final resource = incidenciasSelectorResponse;

    if (resource is ErrorData<ApiResponse<IncidenciasSelectorPaginated>>) {
      return resource.message;
    }

    return null;
  }

  // ==========================================================
  // EQUATABLE
  // ==========================================================

  @override
  List<Object?> get props => [
    createResponse,
    paginatedResponse,
    detailResponse,
    pdfResponse,
    incidenciasSelectorResponse,
    incidenciasSelector,
    incidenciasSelectorParams,
    incidenciasSelectorPage,
    incidenciasSelectorLimit,
    incidenciasSelectorTotalItems,
    incidenciasSelectorTotalPages,
    incidenciasSelectorHasMore,
    isLoadingMoreIncidenciasSelector,
    selectedIncidencia,
    currentFormStep,
    totalFormSteps,
    completedFormSteps,
  ];
}
