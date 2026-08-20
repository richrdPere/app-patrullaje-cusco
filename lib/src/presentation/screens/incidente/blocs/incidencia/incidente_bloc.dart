import 'package:bloc/bloc.dart';

import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/GeolocatorUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/historial_patrullaje/HistorialPatrullajeUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/IncidenteUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/multimedias/MultimediasUsesCases.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_state.dart';

// Handlers
import 'handlers/archivo_handlers.dart';
import 'handlers/context_handlers.dart';
import 'handlers/incidente_handlers.dart';
import 'handlers/location_handlers.dart';
import 'handlers/media_handlers.dart';
import 'handlers/ui_handlers.dart';

class IncidenteBloc extends Bloc<IncidenteEvent, IncidenteState> {
  final IncidenteUseCases incidenteUseCases;
  final GeolocatorUseCases geolocatorUseCases;
  final MultimediasUseCases mediaUseCases;
  final HistorialPatrullajeUseCases historialUseCases;

  late final IncidenteHandlers _incidenteHandlers;
  late final ArchivoHandlers _archivoHandlers;
  late final LocationHandlers _locationHandlers;
  late final MediaHandlers _mediaHandlers;
  late final UiHandlers _uiHandlers;
  late final ContextHandlers _contextHandlers;

  IncidenteBloc(
    this.incidenteUseCases,
    this.geolocatorUseCases,
    this.mediaUseCases,
    this.historialUseCases,
  ) : super(const IncidenteState()) {
    // ======================================================
    // INICIALIZACIÓN DE HANDLERS
    // ======================================================
    _incidenteHandlers = IncidenteHandlers(
      incidenteUseCases: incidenteUseCases,
      // historialUseCases: historialUseCases,
    );

    _archivoHandlers = ArchivoHandlers(incidenteUseCases: incidenteUseCases);

    _locationHandlers = LocationHandlers(
      geolocatorUseCases: geolocatorUseCases,
    );

    _mediaHandlers = MediaHandlers(mediaUseCases: mediaUseCases);

    _uiHandlers = const UiHandlers();

    _contextHandlers = ContextHandlers(incidenteUseCases: incidenteUseCases);

    // ======================================================
    // INCIDENCIAS
    // ======================================================
    on<CrearIncidenteEvent>((event, emit) {
      return _incidenteHandlers.onCrearIncidente(event, emit, state);
    });

    // on<ReporteRapidoEvent>((event, emit) {
    //   return _incidenteHandlers.onReporteRapido(event, emit, state, add);
    // });

    on<ObtenerMisIncidenciasEvent>((event, emit) {
      return _incidenteHandlers.onObtenerMisIncidencias(event, emit, state);
    });

    on<CargarMasMisIncidenciasEvent>((event, emit) {
      return _incidenteHandlers.onCargarMasMisIncidencias(event, emit, state);
    });

    on<ObtenerIncidenciaPorIdEvent>((event, emit) {
      return _incidenteHandlers.onObtenerIncidenciaPorId(event, emit, state);
    });

    on<LimpiarIncidenciaSeleccionadaEvent>((event, emit) {
      return _incidenteHandlers.onLimpiarIncidenciaSeleccionada(
        event,
        emit,
        state,
      );
    });

    // on<ObtenerIncidenciasContextoEvent>((event, emit) {
    //   return _incidenteHandlers.onObtenerIncidenciasContexto(
    //     event,
    //     emit,
    //     state,
    //   );
    // });

    // ======================================================
    // ARCHIVOS REMOTOS
    // ======================================================
    on<ObtenerArchivosIncidenciaEvent>((event, emit) {
      return _archivoHandlers.onObtenerArchivosIncidencia(event, emit, state);
    });

    on<AgregarArchivosIncidenciaEvent>((event, emit) {
      return _archivoHandlers.onAgregarArchivosIncidencia(event, emit, state);
    });

    on<EliminarArchivoIncidenciaEvent>((event, emit) {
      return _archivoHandlers.onEliminarArchivoIncidencia(event, emit, state);
    });

    on<LimpiarArchivosIncidenciaEvent>((event, emit) {
      return _archivoHandlers.onLimpiarArchivosIncidencia(event, emit, state);
    });

    // ======================================================
    // UBICACIÓN
    // ======================================================
    on<ObtenerUbicacionEvent>((event, emit) {
      return _locationHandlers.onObtenerUbicacion(event, emit, state);
    });

    // ======================================================
    // MEDIA LOCAL
    // ======================================================
    on<TomarFotoEvent>((event, emit) {
      return _mediaHandlers.onTomarFoto(event, emit, state);
    });

    on<SeleccionarImagenEvent>((event, emit) {
      return _mediaHandlers.onSeleccionarImagen(event, emit, state);
    });

    on<SeleccionarVideoEvent>((event, emit) {
      return _mediaHandlers.onSeleccionarVideo(event, emit, state);
    });

    on<IniciarGrabacionVideoEvent>((event, emit) {
      return _mediaHandlers.onIniciarGrabacionVideo(event, emit, state);
    });

    on<DetenerGrabacionVideoEvent>((event, emit) {
      return _mediaHandlers.onDetenerGrabacionVideo(event, emit, state);
    });

    on<IniciarGrabacionAudioEvent>((event, emit) {
      return _mediaHandlers.onIniciarGrabacionAudio(event, emit, state);
    });

    on<DetenerGrabacionAudioEvent>((event, emit) {
      return _mediaHandlers.onDetenerGrabacionAudio(event, emit, state);
    });

    on<EliminarArchivoLocalEvent>((event, emit) {
      return _mediaHandlers.onEliminarArchivoLocal(event, emit, state);
    });

    on<LimpiarArchivosLocalesEvent>((event, emit) {
      return _mediaHandlers.onLimpiarArchivosLocales(event, emit, state);
    });

    // ======================================================
    // UI
    // ======================================================
    on<ResetIncidenteEvent>((event, emit) {
      return _uiHandlers.onResetIncidente(event, emit);
    });

    on<LimpiarAccionIncidenteEvent>((event, emit) {
      return _uiHandlers.onLimpiarAccionIncidente(event, emit, state);
    });

    on<CambiarTabIncidenteEvent>((event, emit) {
      return _uiHandlers.onCambiarTab(event, emit, state);
    });

    on<ExpandirSheetIncidenteEvent>((event, emit) {
      return _uiHandlers.onExpandirSheet(event, emit, state);
    });

    on<ContraerSheetIncidenteEvent>((event, emit) {
      return _uiHandlers.onContraerSheet(event, emit, state);
    });

    // ======================================================
    // CONTEXTO / INCIDENTES CERCANOS
    // ======================================================
    on<ObtenerIncidentesCercanosEvent>((event, emit) {
      return _contextHandlers.onObtenerIncidentesCercanos(event, emit, state);
    });

    on<LimpiarIncidentesCercanosEvent>((event, emit) {
      return _contextHandlers.onLimpiarIncidentesCercanos(event, emit, state);
    });
  }
}
