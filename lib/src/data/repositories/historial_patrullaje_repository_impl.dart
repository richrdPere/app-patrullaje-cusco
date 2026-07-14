// Repo
import 'package:sis_patrullaje_cusco/src/data/models/historial_patrullaje/historial_patrullaje_request.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/auth_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/historial_patrullaje_repository.dart';

// Models
import 'package:sis_patrullaje_cusco/src/data/datasources/remote/services/historial_patrullaje_service.dart';
import 'package:sis_patrullaje_cusco/src/data/models/historial_patrullaje/historial_patrullaje_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class HistorialPatrullajeRepositoryImpl
    implements HistorialPatrullajeRepository {
  final HistorialPatrullajeService historialService;
  final AuthRepository authRepository;

  HistorialPatrullajeRepositoryImpl(this.historialService, this.authRepository);

  // REGISTRAR HISTORIAL
  @override
  Future<Resource<HistorialPatrullajeModel>> registerHistorial(
    HistorialPatrullajeRequest historial,
  ) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData<HistorialPatrullajeModel>(
        message: 'No existe una sesión iniciada.',
      );
    }

    final response = await historialService.registerHistorial(
      historial: historial,
      token: token,
    );

    return response;
  }

  // OBTENER HISTORIAL POR PATRULLAJE
  @override
  Future<Resource<List<HistorialPatrullajeModel>>> getHistorialByPatrullaje(
    int patrullajeId,
  ) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData<List<HistorialPatrullajeModel>>(
        message: "No existe una sesión iniciada.",
      );
    }

    return await historialService.getHistorialByPatrullaje(
      patrullajeId: patrullajeId,
      token: token,
    );
  }

  // ARCHIVAR HISTORIAL
  @override
  Future<Resource<bool>> archivedHistorial(int historialId) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData<bool>(message: "No existe una sesión iniciada.");
    }

    return await historialService.archivedHistorial(
      historialId: historialId,
      token: token,
    );
  }

  // UPDATE HISTORIAL
  @override
  Future<Resource<HistorialPatrullajeModel>> updateHistorial({
    required int idHistorial,
    required HistorialPatrullajeRequest historial,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData<HistorialPatrullajeModel>(
        message: 'No existe una sesión iniciada.',
      );
    }

    return await historialService.updateHistorial(
      idHistorial: idHistorial,
      historial: historial,
      token: token,
    );
  }

  @override
  Future<Resource<HistorialPatrullajeModel>> getHistorialById(
    int historialId,
  ) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData<HistorialPatrullajeModel>(
  message: "No existe una sesión iniciada.",
);
    }

    return await historialService.getHistorialById(
      historialId: historialId,
      token: token,
    );
  }
}
