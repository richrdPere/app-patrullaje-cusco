import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/auth/AuthUseCases.dart';

import 'splash_event.dart';
import 'splash_state.dart';

@injectable
class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final AuthUsesCases authUsesCases;

  SplashBloc(this.authUsesCases) : super(const SplashInitial()) {
    on<SplashStarted>(_onSplashStarted);
  }

  Future<void> _onSplashStarted(
    SplashStarted event,
    Emitter<SplashState> emit,
  ) async {
    emit(const SplashLoading());

    try {
      /// Mostrar el Splash al menos 2 segundos
      await Future.delayed(const Duration(seconds: 2));

      final session = await authUsesCases.getUserSession.run();

      if (session != null) {
        emit(SplashAuthenticated(session));
      } else {
        emit(const SplashUnauthenticated());
      }
    } catch (e) {
      emit(SplashFailure(e.toString()));
    }
  }
}
