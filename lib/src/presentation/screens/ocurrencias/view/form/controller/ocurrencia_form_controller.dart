import 'package:flutter/material.dart';

import 'package:uuid/uuid.dart';

// Models
import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/view/form/models/ocurrencia_incidente_select.dart';

class OcurrenciaFormController extends ChangeNotifier {
  // ==========================================================
  // CONFIGURACIÓN
  // ==========================================================

  static const int maxDatosImportantes = 140;

  // ==========================================================
  // MODO DE REGISTRO E INCIDENCIA
  // ==========================================================

  ModoRegistroOcurrencia modoRegistro = ModoRegistroOcurrencia.manual;

  IncidenciaSelectorData? _incidenciaSeleccionada;

  IncidenciaSelectorData? get incidenciaSeleccionada => _incidenciaSeleccionada;

  int? get incidenciaId => _incidenciaSeleccionada?.id;

  bool get tieneIncidenciaSeleccionada => _incidenciaSeleccionada != null;

  // ==========================================================
  // CONTEXTO OPERATIVO
  // ==========================================================

  PatrullajeData? patrullajeActivo;

  int? patrullajeId;
  int? zonaId;
  int? unidadId;

  bool get tienePatrullajeActivo {
    return patrullajeActivo != null && patrullajeActivo!.id > 0;
  }

  // ==========================================================
  // STEP 1: CONTEXTO Y GENERALIDADES
  // ==========================================================

  final uuidController = TextEditingController(text: const Uuid().v4());

  final codigoController = TextEditingController();

  final origenOtroController = TextEditingController();

  final placaVehiculoController = TextEditingController();

  final tipoVehiculoOtroController = TextEditingController();

  final tipoPatrullajeOtroController = TextEditingController();

  String origen = 'PATRULLAJE';
  String modalidadPatrullaje = 'MUNICIPAL';
  String tipoPatrullaje = 'A_PIE';

  /// Debe coincidir con el enum del backend:
  /// MAÑANA, TARDE o NOCHE.
  String turno = 'MAÑANA';

  String? tipoVehiculo;

  bool get isMotorized {
    return tipoPatrullaje == 'MOTORIZADO';
  }

  // CLASIFICADOR DE OCURRENCIAS
  CategoriaGenericaModel? categoriaGenericaSeleccionada;
  CategoriaEspecificaModel? categoriaEspecificaSeleccionada;
  ModalidadClasificadorModel? modalidadSeleccionada;

  int? get modalidadId => modalidadSeleccionada?.id;

  String? get modalidadCodigo => modalidadSeleccionada?.codigo;

  String? get modalidadNombre => modalidadSeleccionada?.nombre;

  bool get tieneModalidadSeleccionada => modalidadSeleccionada != null;

  // ==========================================================
  // STEP 2: ATENCIÓN Y UBICACIÓN
  // ==========================================================

  final fechaOcurrenciaController = TextEditingController();

  final horaAlertaController = TextEditingController();

  final horaLlegadaController = TextEditingController();

  final horaRepliegueController = TextEditingController();

  final tipoLugarOtroController = TextEditingController();

  final direccionController = TextEditingController();

  final referenciaController = TextEditingController();

  final manzanaController = TextEditingController();

  final loteController = TextEditingController();

  final nombreZonaController = TextEditingController();

  final sectorPatrullajeController = TextEditingController();

  final ubigeoController = TextEditingController();

  final latitudController = TextEditingController();

  final longitudController = TextEditingController();

  final datosImportantesController = TextEditingController();

  String resultado = 'FRUSTRADO';
  String? relacionVictimaVictimario;

  String? tipoLugar;
  String? tipoVia;
  String? tipoZona;

  // ==========================================================
  // STEP 3: PERSONAS INVOLUCRADAS
  // ==========================================================

  final List<CreateOcurrenciaPersonaRequest> personas = [];

  // ==========================================================
  // STEP 4: INTERVENCIÓN
  // ==========================================================

  final List<CreateOcurrenciaConsecuenciaRequest> consecuencias = [];

  final List<CreateOcurrenciaMedioEmpleadoRequest> mediosEmpleados = [];

  final List<CreateOcurrenciaEfectivoPnpRequest> efectivosPnp = [];

  // ==========================================================
  // MODO DE REGISTRO
  // ==========================================================

  void cambiarModo(ModoRegistroOcurrencia value) {
    if (modoRegistro == value) return;

    modoRegistro = value;

    if (value == ModoRegistroOcurrencia.manual) {
      _limpiarIncidenciaInternamente();
      _restaurarRelacionesPatrullaje();
    }

    notifyListeners();
  }

  void seleccionarCategoriaGenerica(CategoriaGenericaModel? categoria) {
    if (categoriaGenericaSeleccionada?.id == categoria?.id) {
      return;
    }

    categoriaGenericaSeleccionada = categoria;

    /*
   * Si cambia el primer nivel, se limpian
   * todas las selecciones dependientes.
   */
    categoriaEspecificaSeleccionada = null;

    modalidadSeleccionada = null;

    notifyListeners();
  }

  void seleccionarCategoriaEspecifica(CategoriaEspecificaModel? categoria) {
    if (categoriaEspecificaSeleccionada?.id == categoria?.id) {
      return;
    }

    categoriaEspecificaSeleccionada = categoria;

    /*
   * Si cambia el segundo nivel, se limpia
   * la modalidad previamente elegida.
   */
    modalidadSeleccionada = null;

    notifyListeners();
  }

  // ==========================================================
  // CLASIFICADOR DE OCURRENCIAS
  // ==========================================================
  void seleccionarModalidad(ModalidadClasificadorModel? modalidad) {
    if (modalidadSeleccionada?.id == modalidad?.id) {
      return;
    }

    modalidadSeleccionada = modalidad;

    notifyListeners();
  }

  void limpiarClasificador() {
    final tieneSeleccion =
        categoriaGenericaSeleccionada != null ||
        categoriaEspecificaSeleccionada != null ||
        modalidadSeleccionada != null;

    if (!tieneSeleccion) return;

    categoriaGenericaSeleccionada = null;
    categoriaEspecificaSeleccionada = null;
    modalidadSeleccionada = null;

    notifyListeners();
  }

  // ==========================================================
  // INCIDENCIA SELECCIONADA
  // ==========================================================

  void seleccionarIncidencia(IncidenciaSelectorData incidencia) {
    modoRegistro = ModoRegistroOcurrencia.incidencia;

    _incidenciaSeleccionada = incidencia;

    /*
     * La incidencia tiene prioridad para patrullaje y zona.
     * La unidad continúa obteniéndose del patrullaje activo,
     * porque el selector no devuelve unidad_id.
     */
    patrullajeId = incidencia.patrullajeId ?? patrullajeActivo?.id;

    zonaId = incidencia.zonaId > 0 ? incidencia.zonaId : _zonaPatrullajeActivo;

    unidadId = patrullajeActivo?.unidad.id;

    latitudController.text = incidencia.latitud.toStringAsFixed(7);

    longitudController.text = incidencia.longitud.toStringAsFixed(7);

    datosImportantesController.text = _truncate(
      incidencia.descripcion,
      maxDatosImportantes,
    );

    /*
     * Si la fecha todavía no fue elegida, se utiliza
     * la fecha en la que ocurrió la incidencia.
     */
    if (fechaOcurrenciaController.text.trim().isEmpty) {
      fechaOcurrenciaController.text = _formatDate(
        incidencia.fechaHora.toLocal(),
      );
    }

    notifyListeners();
  }

  void limpiarIncidenciaSeleccionada() {
    if (_incidenciaSeleccionada == null) {
      return;
    }

    _limpiarIncidenciaInternamente();
    _restaurarRelacionesPatrullaje();

    notifyListeners();
  }

  void _limpiarIncidenciaInternamente() {
    _incidenciaSeleccionada = null;
  }

  // ==========================================================
  // CONTEXTO DEL PATRULLAJE
  // ==========================================================

  void cargarContextoPatrullaje(PatrullajeData? patrullaje) {
    if (patrullaje == null || patrullaje.id <= 0) {
      patrullajeActivo = null;

      /*
       * Si existe una incidencia seleccionada, conservamos
       * las relaciones que provienen de ella.
       */
      if (_incidenciaSeleccionada != null) {
        patrullajeId = _incidenciaSeleccionada!.patrullajeId;

        zonaId = _incidenciaSeleccionada!.zonaId > 0
            ? _incidenciaSeleccionada!.zonaId
            : null;
      } else {
        patrullajeId = null;
        zonaId = null;
      }

      unidadId = null;

      notifyListeners();
      return;
    }

    patrullajeActivo = patrullaje;

    _aplicarRelacionesOperativas();

    _autocompletarDatosPatrullaje(patrullaje);

    notifyListeners();
  }

  void _aplicarRelacionesOperativas() {
    final incidencia = _incidenciaSeleccionada;

    if (incidencia != null) {
      patrullajeId = incidencia.patrullajeId ?? patrullajeActivo?.id;

      zonaId = incidencia.zonaId > 0
          ? incidencia.zonaId
          : _zonaPatrullajeActivo;

      unidadId = patrullajeActivo?.unidad.id;

      return;
    }

    _restaurarRelacionesPatrullaje();
  }

  void _restaurarRelacionesPatrullaje() {
    final patrullaje = patrullajeActivo;

    if (patrullaje == null) {
      patrullajeId = null;
      zonaId = null;
      unidadId = null;
      return;
    }

    patrullajeId = patrullaje.id;
    zonaId = patrullaje.zona.id > 0 ? patrullaje.zona.id : null;
    unidadId = patrullaje.unidad.id;
  }

  int? get _zonaPatrullajeActivo {
    final zona = patrullajeActivo?.zona;

    if (zona == null || zona.id <= 0) {
      return null;
    }

    return zona.id;
  }

  void _autocompletarDatosPatrullaje(PatrullajeData patrullaje) {
    if (nombreZonaController.text.trim().isEmpty) {
      nombreZonaController.text = patrullaje.zona.nombre;
    }

    if (sectorPatrullajeController.text.trim().isEmpty) {
      sectorPatrullajeController.text = patrullaje.zona.nombre;
    }

    if (placaVehiculoController.text.trim().isEmpty) {
      placaVehiculoController.text = patrullaje.unidad.placa;
    }
  }

  // ==========================================================
  // SETTERS: STEP 1
  // ==========================================================

  void setOrigen(String value) {
    if (origen == value) return;

    origen = value;

    if (value != 'OTRO') {
      origenOtroController.clear();
    }

    notifyListeners();
  }

  void setModalidadPatrullaje(String value) {
    if (modalidadPatrullaje == value) {
      return;
    }

    modalidadPatrullaje = value;
    notifyListeners();
  }

  void setTipoPatrullaje(String value) {
    if (tipoPatrullaje == value) {
      return;
    }

    tipoPatrullaje = value;

    if (value != 'OTRO') {
      tipoPatrullajeOtroController.clear();
    }

    if (value != 'MOTORIZADO') {
      tipoVehiculo = null;
      placaVehiculoController.clear();
      tipoVehiculoOtroController.clear();
    }

    notifyListeners();
  }

  void setTurno(String value) {
    if (turno == value) return;

    turno = value;
    notifyListeners();
  }

  void setTipoVehiculo(String? value) {
    if (tipoVehiculo == value) return;

    tipoVehiculo = value;

    if (value != 'OTRO') {
      tipoVehiculoOtroController.clear();
    }

    notifyListeners();
  }

  // ==========================================================
  // SETTERS: STEP 2
  // ==========================================================

  void setResultado(String? value) {
    if (value == null || resultado == value) {
      return;
    }

    resultado = value;
    notifyListeners();
  }

  void setRelacionVictimaVictimario(String? value) {
    if (relacionVictimaVictimario == value) {
      return;
    }

    relacionVictimaVictimario = value;
    notifyListeners();
  }

  void setTipoLugar(String? value) {
    if (tipoLugar == value) return;

    tipoLugar = value;

    if (value != 'OTRO') {
      tipoLugarOtroController.clear();
    }

    notifyListeners();
  }

  void setTipoVia(String? value) {
    if (tipoVia == value) return;

    tipoVia = value;
    notifyListeners();
  }

  void setTipoZona(String? value) {
    if (tipoZona == value) return;

    tipoZona = value;

    if (value == 'SIN_DATO') {
      nombreZonaController.clear();
    }

    notifyListeners();
  }

  void setFechaOcurrencia(DateTime fecha) {
    fechaOcurrenciaController.text = _formatDate(fecha);

    notifyListeners();
  }

  void setHoraAlerta(TimeOfDay hora) {
    horaAlertaController.text = _formatTime(hora);

    notifyListeners();
  }

  void setHoraLlegada(TimeOfDay hora) {
    horaLlegadaController.text = _formatTime(hora);

    notifyListeners();
  }

  void setHoraRepliegue(TimeOfDay hora) {
    horaRepliegueController.text = _formatTime(hora);

    notifyListeners();
  }

  void setUbicacion({required double latitud, required double longitud}) {
    latitudController.text = latitud.toStringAsFixed(7);

    longitudController.text = longitud.toStringAsFixed(7);

    notifyListeners();
  }

  // ==========================================================
  // STEP 3: PERSONAS INVOLUCRADAS
  // ==========================================================

  void agregarPersona(CreateOcurrenciaPersonaRequest persona) {
    personas.add(_normalizarOrdenPersona(persona, personas.length + 1));

    notifyListeners();
  }

  void actualizarPersona(int index, CreateOcurrenciaPersonaRequest persona) {
    if (!_isValidIndex(personas, index)) {
      return;
    }

    personas[index] = _normalizarOrdenPersona(persona, index + 1);

    notifyListeners();
  }

  void eliminarPersona(int index) {
    if (!_isValidIndex(personas, index)) {
      return;
    }

    personas.removeAt(index);
    _reordenarPersonas();

    notifyListeners();
  }

  void limpiarPersonas() {
    if (personas.isEmpty) return;

    personas.clear();
    notifyListeners();
  }

  void moverPersonaArriba(int index) {
    if (index <= 0 || index >= personas.length) {
      return;
    }

    final persona = personas.removeAt(index);

    personas.insert(index - 1, persona);

    _reordenarPersonas();
    notifyListeners();
  }

  void moverPersonaAbajo(int index) {
    if (index < 0 || index >= personas.length - 1) {
      return;
    }

    final persona = personas.removeAt(index);

    personas.insert(index + 1, persona);

    _reordenarPersonas();
    notifyListeners();
  }

  void _reordenarPersonas() {
    for (var index = 0; index < personas.length; index++) {
      personas[index] = _normalizarOrdenPersona(personas[index], index + 1);
    }
  }

  CreateOcurrenciaPersonaRequest _normalizarOrdenPersona(
    CreateOcurrenciaPersonaRequest persona,
    int orden,
  ) {
    return CreateOcurrenciaPersonaRequest(
      orden: orden,
      tipoPersona: persona.tipoPersona,
      identificado: persona.identificado,
      documentoIdentidad: persona.documentoIdentidad,
      nombresApellidos: persona.nombresApellidos,
      genero: persona.genero,
      edad: persona.edad,
      edadEsAproximada: persona.edadEsAproximada,
      placa: persona.placa,
      caracteristicasFisicas: persona.caracteristicasFisicas,
      esComunidad: persona.esComunidad,
      fuenteDatos: persona.fuenteDatos,
      observacion: persona.observacion,
    );
  }

  // ==========================================================
  // STEP 4: CONSECUENCIAS
  // ==========================================================

  void agregarConsecuencia(CreateOcurrenciaConsecuenciaRequest consecuencia) {
    consecuencias.add(consecuencia);
    notifyListeners();
  }

  void actualizarConsecuencia(
    int index,
    CreateOcurrenciaConsecuenciaRequest consecuencia,
  ) {
    if (!_isValidIndex(consecuencias, index)) {
      return;
    }

    consecuencias[index] = consecuencia;

    notifyListeners();
  }

  void eliminarConsecuencia(int index) {
    if (!_isValidIndex(consecuencias, index)) {
      return;
    }

    consecuencias.removeAt(index);
    notifyListeners();
  }

  // ==========================================================
  // STEP 4: MEDIOS EMPLEADOS
  // ==========================================================

  void agregarMedioEmpleado(CreateOcurrenciaMedioEmpleadoRequest medio) {
    mediosEmpleados.add(medio);
    notifyListeners();
  }

  void actualizarMedioEmpleado(
    int index,
    CreateOcurrenciaMedioEmpleadoRequest medio,
  ) {
    if (!_isValidIndex(mediosEmpleados, index)) {
      return;
    }

    mediosEmpleados[index] = medio;
    notifyListeners();
  }

  void eliminarMedioEmpleado(int index) {
    if (!_isValidIndex(mediosEmpleados, index)) {
      return;
    }

    mediosEmpleados.removeAt(index);
    notifyListeners();
  }

  // ==========================================================
  // STEP 4: EFECTIVOS PNP
  // ==========================================================

  void agregarEfectivoPnp(CreateOcurrenciaEfectivoPnpRequest efectivo) {
    efectivosPnp.add(efectivo);
    notifyListeners();
  }

  void actualizarEfectivoPnp(
    int index,
    CreateOcurrenciaEfectivoPnpRequest efectivo,
  ) {
    if (!_isValidIndex(efectivosPnp, index)) {
      return;
    }

    efectivosPnp[index] = efectivo;
    notifyListeners();
  }

  void eliminarEfectivoPnp(int index) {
    if (!_isValidIndex(efectivosPnp, index)) {
      return;
    }

    efectivosPnp.removeAt(index);
    notifyListeners();
  }

  void limpiarDatosIntervencion() {
    final tieneDatos =
        consecuencias.isNotEmpty ||
        mediosEmpleados.isNotEmpty ||
        efectivosPnp.isNotEmpty;

    if (!tieneDatos) return;

    consecuencias.clear();
    mediosEmpleados.clear();
    efectivosPnp.clear();

    notifyListeners();
  }

  // ==========================================================
  // CONSTRUIR REQUEST
  // ==========================================================

  CreateOcurrenciaRequest buildRequest() {
    return CreateOcurrenciaRequest(
      uuidCliente: uuidController.text.trim(),
      codigoOcurrencia: codigoController.text.trim(),

      /*
       * Solo se envía la incidencia cuando el modo
       * de registro es desde incidencia.
       */
      incidenciaId: modoRegistro == ModoRegistroOcurrencia.incidencia
          ? incidenciaId
          : null,

      patrullajeId: patrullajeId,
      zonaId: zonaId,
      unidadId: unidadId,

      origen: origen,
      origenOtro: origen == 'OTRO'
          ? _nullableText(origenOtroController.text)
          : null,

      modalidadPatrullaje: modalidadPatrullaje,

      tipoPatrullaje: tipoPatrullaje,

      tipoPatrullajeOtro: tipoPatrullaje == 'OTRO'
          ? _nullableText(tipoPatrullajeOtroController.text)
          : null,

      turno: turno,

      placaVehiculo: isMotorized
          ? _nullableText(placaVehiculoController.text)
          : null,

      tipoVehiculo: isMotorized ? tipoVehiculo : null,

      tipoVehiculoOtro: isMotorized && tipoVehiculo == 'OTRO'
          ? _nullableText(tipoVehiculoOtroController.text)
          : null,

      fechaOcurrencia: _requiredText(fechaOcurrenciaController.text),

      horaAlerta: _nullableText(horaAlertaController.text),

      horaLlegada: _nullableText(horaLlegadaController.text),

      horaRepliegue: _nullableText(horaRepliegueController.text),

      resultado: resultado,

      relacionVictimaVictimario: relacionVictimaVictimario,

      tipoLugar: tipoLugar,

      tipoLugarOtro: tipoLugar == 'OTRO'
          ? _nullableText(tipoLugarOtroController.text)
          : null,

      tipoVia: tipoVia,

      direccion: _nullableText(direccionController.text),

      referencia: _nullableText(referenciaController.text),

      manzana: _nullableText(manzanaController.text),

      lote: _nullableText(loteController.text),

      tipoZona: tipoZona,

      nombreZona: tipoZona == 'SIN_DATO'
          ? null
          : _nullableText(nombreZonaController.text),

      sectorPatrullaje: _nullableText(sectorPatrullajeController.text),

      ubigeo: _nullableText(ubigeoController.text),

      latitud: _nullableDouble(latitudController.text),

      longitud: _nullableDouble(longitudController.text),

      datosImportantes: _nullableText(datosImportantesController.text),

      personas: List.unmodifiable(personas),

      consecuencias: List.unmodifiable(consecuencias),

      mediosEmpleados: List.unmodifiable(mediosEmpleados),

      efectivosPnp: List.unmodifiable(efectivosPnp),
    );
  }

  // ==========================================================
  // HELPERS
  // ==========================================================

  bool _isValidIndex<T>(List<T> items, int index) {
    return index >= 0 && index < items.length;
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');

    final month = date.month.toString().padLeft(2, '0');

    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');

    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute:00';
  }

  String _truncate(String value, int maxLength) {
    if (value.length <= maxLength) {
      return value;
    }

    return value.substring(0, maxLength);
  }

  String? _nullableText(String? value) {
    final normalized = value?.trim();

    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    return normalized;
  }

  String _requiredText(String value) {
    return value.trim();
  }

  double? _nullableDouble(String? value) {
    final normalized = value?.trim();

    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    return double.tryParse(normalized);
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    uuidController.dispose();
    codigoController.dispose();

    origenOtroController.dispose();
    placaVehiculoController.dispose();
    tipoVehiculoOtroController.dispose();
    tipoPatrullajeOtroController.dispose();

    fechaOcurrenciaController.dispose();
    horaAlertaController.dispose();
    horaLlegadaController.dispose();
    horaRepliegueController.dispose();

    tipoLugarOtroController.dispose();
    direccionController.dispose();
    referenciaController.dispose();
    manzanaController.dispose();
    loteController.dispose();
    nombreZonaController.dispose();
    sectorPatrullajeController.dispose();
    ubigeoController.dispose();
    latitudController.dispose();
    longitudController.dispose();
    datosImportantesController.dispose();

    super.dispose();
  }
}
