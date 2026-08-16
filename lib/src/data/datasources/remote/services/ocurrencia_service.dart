// ignore_for_file: non_constant_identifier_names, unnecessary_this

import 'dart:convert';
import 'package:http/http.dart' as http;

// Environment
import 'package:sis_patrullaje_cusco/src/config/constants/environment.dart'
    as url_backend;

// Models

class OcurrenciaService {
  String get API_BASE => '${url_backend.Environment.mainUrl}/ocurrencias';

  String get API_POST_OCURRENCIA => '$API_BASE/proyectado';
  String get API_GET_OCURRENCIAS_PAGINADO => '$API_BASE/proyectado';
  String get API_GET_OCURRENCIAS_DETALLE => '$API_BASE/proyectado';
  String get API_GENERATE_OCURRENCIA_PDF => '$API_BASE/proyectado';

  // TODO:

  // 3. POST /api/ocurrencias/create
  // crearOcurrencia

  // 4. GET /api/ocurrencias/paginado?page=1&limit=10 where.sereno_id = req.usuario.id;

  // 5. cONSULTAR DETALLE
  // GET /api/ocurrencias/15

  // 6. GET /api/ocurrencias/15/formato?formato=pdf
}
