import 'package:sis_patrullaje_cusco/src/domain/use_cases/index_uses_cases.dart';

class HistorialPatrullajeUseCases {
  ArchivarHistorialUC archivedHistorial;
  CreateHistorialUC createHistorial;
  CreateObservacionConArchivosUC createObservacionConArchivos;
  GetContextoZonaUC getContextoZona;
  GetParaSiguienteTurnoUC getParaSiguienteTurno;
  GetHistorialByIdUC getHistorialById;
  GetHistorialByPatrullajeUC getHistorialByPatrullaje;
  UpdateHistorialUC updateHistorial;

  HistorialPatrullajeUseCases({
    required this.archivedHistorial,
    required this.createHistorial,
    required this.createObservacionConArchivos,
    required this.getContextoZona,
    required this.getParaSiguienteTurno,
    required this.getHistorialById,
    required this.getHistorialByPatrullaje,
    required this.updateHistorial,
  });
}
