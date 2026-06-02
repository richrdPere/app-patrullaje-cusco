import 'package:bloc/bloc.dart';

import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/GeolocatorUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/historial_patrullaje/HistorialPatrullajeUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/IncidenteUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/multimedias/MultimediasUsesCases.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/bloc/incidente_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/bloc/incidente_state.dart';

// Handlers
import 'handlers/incidente_handlers.dart';
import 'handlers/location_handlers.dart';
import 'handlers/media_handlers.dart';
import 'handlers/ui_handlers.dart';
import 'handlers/context_handlers.dart';

class IncidenteBloc extends Bloc<IncidenteEvent, IncidenteState> {
  final IncidenteUseCases incidenteUseCases;
  final GeolocatorUseCases geolocatorUseCases;
  final MultimediasUseCases mediaUseCases;

  final HistorialPatrullajeUseCases historialUseCases;

  late final IncidenteHandlers _incidenteHandlers;
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
    // Incidente
    _incidenteHandlers = IncidenteHandlers(
      incidenteUseCases: incidenteUseCases,
      historialUseCases: historialUseCases,
    );

    // Location
    _locationHandlers = LocationHandlers(
      geolocatorUseCases: geolocatorUseCases,
    );

    // Media
    _mediaHandlers = MediaHandlers(mediaUseCases: mediaUseCases);

    // UI
    _uiHandlers = const UiHandlers();

    // Context
    _contextHandlers = const ContextHandlers();

    // INCIDENTE
    on<CrearIncidenteEvent>(
      (event, emit) => _incidenteHandlers.onCrearIncidente(event, emit, state),
    );
    on<ReporteRapidoEvent>(
      (event, emit) =>
          _incidenteHandlers.onReporteRapido(event, emit, state, add),
    );

    // LOCATION
    on<ObtenerUbicacionEvent>(
      (event, emit) => _locationHandlers.onObtenerUbicacion(event, emit, state),
    );

    // MEDIA
    on<TomarFotoEvent>(
      (event, emit) => _mediaHandlers.onTomarFoto(event, emit, state),
    );
    on<SeleccionarImagenEvent>(
      (event, emit) => _mediaHandlers.onSeleccionarImagen(event, emit, state),
    );
    on<SeleccionarVideoEvent>(
      (event, emit) => _mediaHandlers.onSeleccionarVideo(event, emit, state),
    );
    on<IniciarGrabacionVideoEvent>(
      (event, emit) =>
          _mediaHandlers.onIniciarGrabacionVideo(event, emit, state),
    );
    on<DetenerGrabacionVideoEvent>(
      (event, emit) =>
          _mediaHandlers.onDetenerGrabacionVideo(event, emit, state),
    );
    on<EliminarArchivoEvent>(
      (event, emit) => _mediaHandlers.onEliminarArchivo(event, emit, state),
    );
    on<LimpiarArchivosEvent>(
      (event, emit) => _mediaHandlers.onLimpiarArchivos(event, emit, state),
    );

    // UI
    on<ResetIncidenteEvent>(
      (event, emit) => _uiHandlers.onResetIncidente(event, emit),
    );

    on<LimpiarErrorEvent>(
      (event, emit) => _uiHandlers.onLimpiarError(event, emit, state),
    );

    on<CambiarTabEvent>(
      (event, emit) => _uiHandlers.onCambiarTab(event, emit, state),
    );

    on<ExpandirSheetEvent>(
      (event, emit) => _uiHandlers.onExpandirSheet(event, emit, state),
    );

    on<ContraerSheetEvent>(
      (event, emit) => _uiHandlers.onContraerSheet(event, emit, state),
    );

    // CONTEXT
    on<ObtenerIncidentesCercanosEvent>(
      (event, emit) =>
          _contextHandlers.onObtenerIncidentesCercanos(event, emit, state),
    );
  }
}
