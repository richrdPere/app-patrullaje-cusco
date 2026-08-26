import 'package:flutter/material.dart';
import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_data.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/view/form/models/ocurrencia_incidente_select.dart';
import 'package:uuid/uuid.dart';

import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_create_req.dart';

class OcurrenciaFormController extends ChangeNotifier {
  // ==========================================================
  // MODO DE REGISTRO
  // ==========================================================
  ModoRegistroOcurrencia modoRegistro = ModoRegistroOcurrencia.manual;

  OcurrenciaIncidenteSeleccionado? incidenteSeleccionado;

  // ==========================================================
  // CONTROLADORES
  // ==========================================================

  // ==========================================================
  // CONTEXTO DEL PATRULLAJE
  // ==========================================================

  PatrullajeData? patrullajeActivo;

  bool get tienePatrullajeActivo {
    return patrullajeActivo != null && patrullajeActivo!.id > 0;
  }

  final uuidController = TextEditingController(text: const Uuid().v4());

  final codigoController = TextEditingController();

  final origenOtroController = TextEditingController();

  final placaVehiculoController = TextEditingController();

  final tipoVehiculoOtroController = TextEditingController();

  final fechaController = TextEditingController();

  // ============================================================
  // STEP 2: ATENCIÓN Y UBICACIÓN
  // ============================================================

  final TextEditingController fechaOcurrenciaController =
      TextEditingController();

  final TextEditingController horaAlertaController = TextEditingController();

  final TextEditingController horaLlegadaController = TextEditingController();

  final TextEditingController horaRepliegueController = TextEditingController();

  final TextEditingController relacionVictimaVictimarioController =
      TextEditingController();

  final TextEditingController tipoLugarOtroController = TextEditingController();

  final TextEditingController direccionController = TextEditingController();

  final TextEditingController referenciaController = TextEditingController();

  final TextEditingController manzanaController = TextEditingController();

  final TextEditingController loteController = TextEditingController();

  final TextEditingController nombreZonaController = TextEditingController();

  final TextEditingController sectorPatrullajeController =
      TextEditingController();

  final TextEditingController ubigeoController = TextEditingController();

  final TextEditingController latitudController = TextEditingController();

  final TextEditingController longitudController = TextEditingController();

  final sectorController = TextEditingController();

  final datosImportantesController = TextEditingController();

  final tipoPatrullajeOtroController = TextEditingController();

  // ==========================================================
  // RELACIONES DEL SISTEMA
  // ==========================================================

  int? patrullajeId;
  int? zonaId;
  int? unidadId;

  // ==========================================================
  // SELECCIONES
  // ==========================================================

  String origen = 'PATRULLAJE';
  String modalidadPatrullaje = 'MUNICIPAL';
  String tipoPatrullaje = 'A_PIE';
  String turno = 'MAÑANA';

  String? tipoVehiculo;

  String resultado = 'FRUSTRADO';
  String? relacionVictimaVictimario;

  String? tipoLugar;
  String? tipoLugarOtro;
  String? tipoVia;
  String? tipoZona;

  // ==========================================================
  // LISTAS
  // ==========================================================

  final List<CreateOcurrenciaPersonaRequest> personas = [];

  final List<CreateOcurrenciaConsecuenciaRequest> consecuencias = [];

  final List<CreateOcurrenciaMedioEmpleadoRequest> mediosEmpleados = [];

  final List<CreateOcurrenciaEfectivoPnpRequest> efectivosPnp = [];

  bool get isMotorized {
    return tipoPatrullaje == 'MOTORIZADO';
  }

  // ==========================================================
  // CAMBIAR MODO
  // ==========================================================

  void cambiarModo(ModoRegistroOcurrencia value) {
    if (modoRegistro == value) return;

    modoRegistro = value;

    if (value == ModoRegistroOcurrencia.manual) {
      limpiarIncidente();
    }

    notifyListeners();
  }

  // ==========================================================
  // SELECCIONAR INCIDENCIA
  // ==========================================================

  void seleccionarIncidente(OcurrenciaIncidenteSeleccionado incidente) {
    modoRegistro = ModoRegistroOcurrencia.incidencia;

    incidenteSeleccionado = incidente;

    patrullajeId = incidente.patrullajeId ?? patrullajeActivo?.id;

    zonaId =
        incidente.zonaId ??
        (patrullajeActivo != null && patrullajeActivo!.zona.id > 0
            ? patrullajeActivo!.zona.id
            : null);

    unidadId = incidente.unidadId ?? patrullajeActivo?.unidad.id;

    direccionController.text = incidente.direccion ?? '';

    latitudController.text = incidente.latitud?.toString() ?? '';

    longitudController.text = incidente.longitud?.toString() ?? '';

    if (incidente.descripcion != null) {
      datosImportantesController.text = _truncate(incidente.descripcion!, 140);
    }

    notifyListeners();
  }

  void limpiarIncidente() {
    incidenteSeleccionado = null;

    final patrullaje = patrullajeActivo;

    if (patrullaje != null) {
      patrullajeId = patrullaje.id;
      zonaId = patrullaje.zona.id > 0 ? patrullaje.zona.id : null;
      unidadId = patrullaje.unidad.id;
    } else {
      patrullajeId = null;
      zonaId = null;
      unidadId = null;
    }

    notifyListeners();
  }

  // ==========================================================
  // SETTERS
  // ==========================================================

  void setOrigen(String value) {
    origen = value;

    if (value != 'OTRO') {
      origenOtroController.clear();
    }

    notifyListeners();
  }

  void setModalidadPatrullaje(String value) {
    modalidadPatrullaje = value;
    notifyListeners();
  }

  void setTipoPatrullaje(String value) {
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
    turno = value;
    notifyListeners();
  }

  void setTipoVehiculo(String? value) {
    tipoVehiculo = value;

    if (value != 'OTRO') {
      tipoVehiculoOtroController.clear();
    }

    notifyListeners();
  }

  void setResultado(String? value) {
    resultado = value ?? '';
    notifyListeners();
  }

  void setRelacionVictimaVictimario(String? value) {
    relacionVictimaVictimario = value;
    notifyListeners();
  }

  void setTipoLugar(String? value) {
    tipoLugar = value;
    notifyListeners();
  }

  void setTipoVia(String? value) {
    tipoVia = value;
    notifyListeners();
  }

  void setTipoZona(String? value) {
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
    latitudController.text = latitud.toStringAsFixed(8);
    longitudController.text = longitud.toStringAsFixed(8);
    notifyListeners();
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

    // Formato compatible con el request: HH:mm:ss
    return '$hour:$minute:00';
  }

  // ==========================================================
  // STEP 1: CARGAR CONTEXTO
  // ==========================================================
  void cargarContextoPatrullaje(PatrullajeData? patrullaje) {
    if (patrullaje == null || patrullaje.id <= 0) {
      patrullajeActivo = null;
      patrullajeId = null;
      zonaId = null;
      unidadId = null;

      notifyListeners();
      return;
    }

    patrullajeActivo = patrullaje;

    patrullajeId = patrullaje.id;

    zonaId = patrullaje.zona.id > 0 ? patrullaje.zona.id : null;

    unidadId = patrullaje.unidad.id;

    // Se completan algunos datos territoriales.
    if (nombreZonaController.text.trim().isEmpty) {
      nombreZonaController.text = patrullaje.zona.nombre;
    }

    if (sectorPatrullajeController.text.trim().isEmpty) {
      sectorPatrullajeController.text = patrullaje.zona.nombre;
    }

    // Si el patrullaje es vehicular, se puede copiar la placa.
    if (placaVehiculoController.text.trim().isEmpty) {
      placaVehiculoController.text = patrullaje.unidad.placa;
    }

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
    if (index < 0 || index >= personas.length) {
      return;
    }

    personas[index] = _normalizarOrdenPersona(persona, index + 1);

    notifyListeners();
  }

  void eliminarPersona(int index) {
    if (index < 0 || index >= personas.length) {
      return;
    }

    personas.removeAt(index);
    _reordenarPersonas();

    notifyListeners();
  }

  void limpiarPersonas() {
    if (personas.isEmpty) {
      return;
    }

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

  // ==========================================================
  // STEP 4: INTERVENCIÓN
  // ==========================================================

  // ----------------------------------------------------------
  // CONSECUENCIAS
  // ----------------------------------------------------------

  void agregarConsecuencia(CreateOcurrenciaConsecuenciaRequest consecuencia) {
    consecuencias.add(consecuencia);
    notifyListeners();
  }

  void actualizarConsecuencia(
    int index,
    CreateOcurrenciaConsecuenciaRequest consecuencia,
  ) {
    if (index < 0 || index >= consecuencias.length) return;

    consecuencias[index] = consecuencia;
    notifyListeners();
  }

  void eliminarConsecuencia(int index) {
    if (index < 0 || index >= consecuencias.length) return;

    consecuencias.removeAt(index);
    notifyListeners();
  }

  // ----------------------------------------------------------
  // MEDIOS EMPLEADOS
  // ----------------------------------------------------------

  void agregarMedioEmpleado(CreateOcurrenciaMedioEmpleadoRequest medio) {
    mediosEmpleados.add(medio);
    notifyListeners();
  }

  void actualizarMedioEmpleado(
    int index,
    CreateOcurrenciaMedioEmpleadoRequest medio,
  ) {
    if (index < 0 || index >= mediosEmpleados.length) return;

    mediosEmpleados[index] = medio;
    notifyListeners();
  }

  void eliminarMedioEmpleado(int index) {
    if (index < 0 || index >= mediosEmpleados.length) return;

    mediosEmpleados.removeAt(index);
    notifyListeners();
  }

  // ----------------------------------------------------------
  // EFECTIVOS PNP
  // ----------------------------------------------------------

  void agregarEfectivoPnp(CreateOcurrenciaEfectivoPnpRequest efectivo) {
    efectivosPnp.add(efectivo);
    notifyListeners();
  }

  void actualizarEfectivoPnp(
    int index,
    CreateOcurrenciaEfectivoPnpRequest efectivo,
  ) {
    if (index < 0 || index >= efectivosPnp.length) return;

    efectivosPnp[index] = efectivo;
    notifyListeners();
  }

  void eliminarEfectivoPnp(int index) {
    if (index < 0 || index >= efectivosPnp.length) return;

    efectivosPnp.removeAt(index);
    notifyListeners();
  }

  // ----------------------------------------------------------
  // LIMPIAR INTERVENCIÓN
  // ----------------------------------------------------------

  void limpiarDatosIntervencion() {
    consecuencias.clear();
    mediosEmpleados.clear();
    efectivosPnp.clear();

    notifyListeners();
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
  // REQUEST
  // ==========================================================
  CreateOcurrenciaRequest buildRequest() {
    return CreateOcurrenciaRequest(
      uuidCliente: uuidController.text,
      codigoOcurrencia: codigoController.text,
      incidenciaId: incidenteSeleccionado?.id,
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
      fechaOcurrencia: fechaController.text,
      horaAlerta: _nullableText(horaAlertaController.text),
      horaLlegada: _nullableText(horaLlegadaController.text),
      horaRepliegue: _nullableText(horaRepliegueController.text),
      resultado: resultado,
      relacionVictimaVictimario: relacionVictimaVictimario,
      tipoLugar: tipoLugar,
      tipoLugarOtro: tipoLugar == 'OTRO' ? _nullableText(tipoLugarOtro) : null,
      tipoVia: tipoVia,
      direccion: _nullableText(direccionController.text),
      referencia: _nullableText(referenciaController.text),
      manzana: _nullableText(manzanaController.text),
      lote: _nullableText(loteController.text),
      tipoZona: tipoZona,
      nombreZona: tipoZona == 'SIN_DATO'
          ? null
          : _nullableText(nombreZonaController.text),
      sectorPatrullaje: _nullableText(sectorController.text),
      ubigeo: _nullableText(ubigeoController.text),
      latitud: double.tryParse(latitudController.text.trim()),
      longitud: double.tryParse(longitudController.text.trim()),
      datosImportantes: _nullableText(datosImportantesController.text),
      personas: List.unmodifiable(personas),
      consecuencias: List.unmodifiable(consecuencias),
      mediosEmpleados: List.unmodifiable(mediosEmpleados),
      efectivosPnp: List.unmodifiable(efectivosPnp),
    );
  }

  @override
  void dispose() {
    uuidController.dispose();
    codigoController.dispose();
    origenOtroController.dispose();
    placaVehiculoController.dispose();
    tipoVehiculoOtroController.dispose();

    fechaController.dispose();
    fechaOcurrenciaController.dispose();
    horaAlertaController.dispose();
    horaLlegadaController.dispose();
    horaRepliegueController.dispose();

    direccionController.dispose();
    referenciaController.dispose();
    manzanaController.dispose();
    loteController.dispose();
    nombreZonaController.dispose();
    sectorController.dispose();
    ubigeoController.dispose();
    latitudController.dispose();
    longitudController.dispose();
    datosImportantesController.dispose();
    tipoPatrullajeOtroController.dispose();
    relacionVictimaVictimarioController.dispose();
    tipoLugarOtroController.dispose();
    sectorPatrullajeController.dispose();

    super.dispose();
  }

  String _truncate(String value, int maxLength) {
    if (value.length <= maxLength) {
      return value;
    }

    return value.substring(0, maxLength);
  }

  String? _nullableText(String? value) {
    final normalized = value?.trim();

    return normalized == null || normalized.isEmpty ? null : normalized;
  }
}
