import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/auth/AuthUseCases.dart';

import 'loading_event.dart';
import 'loading_state.dart';

@injectable
class LoadingBloc extends Bloc<LoadingEvent, LoadingState> {
  final AuthUsesCases authUsesCases;

  LoadingBloc(this.authUsesCases) : super(const LoadingInitial()) {
    on<LoadingStarted>(_onLoadingStarted);
  }

  Future<void> _onLoadingStarted(
    LoadingStarted event,
    Emitter<LoadingState> emit,
  ) async {
    emit(const LoadingInProgress());

    try {
      /// Recuperar la sesión local
      final session = await authUsesCases.getUserSession.run();

      print("==========================");
      print("SESION: ${session}");
      print("==========================");

      if (session == null) {
        emit(const LoadingFailure("No existe una sesión activa."));
        return;
      }

      /// Simular carga inicial
      /// Posteriormente aquí irán las llamadas al backend
      await Future.delayed(const Duration(seconds: 2));

      emit(const LoadingSuccess());
    } catch (e) {
      print("ERROR: ${e}");

      emit(LoadingFailure(e.toString()));
    }
  }
}
