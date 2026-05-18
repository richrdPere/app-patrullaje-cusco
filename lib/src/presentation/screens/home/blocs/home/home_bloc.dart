import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/patrullaje_entity.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/PatrullajeUseCases.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  PatrullajeUseCases patrullajeUseCases;

  StreamSubscription? _nuevoPatrullajeSub;
  StreamSubscription? _actualizadoSub;

  HomeBloc(this.patrullajeUseCases) : super(HomeState()) {
    on<LoadPatrullajeActivo>(_onLoadPatrullajeActivo);
    // INICIAR LISTENERS
    on<InitSocketListeners>(_onInitSocketListeners);

    on<NuevoPatrullajeRecibido>(_onNuevoPatrullaje);
    on<PatrullajeActualizadoRecibido>(_onPatrullajeActualizado);
    on<AceptarPatrullaje>(_onAceptarPatrullaje);
    on<FinalizarPatrullaje>(_onFinalizarPatrullaje);
  }

  // SOCKET LISTENERS
  void _onInitSocketListeners(
    InitSocketListeners event,
    Emitter<HomeState> emit,
  ) {
    // print("Inicializando listeners de socket...");

    _nuevoPatrullajeSub?.cancel();
    _actualizadoSub?.cancel();

    // NUEVO PATRULLAJE
    _nuevoPatrullajeSub = patrullajeUseCases.listenNewPatrullaje.run().listen((
      patrullaje,
    ) {
      add(NuevoPatrullajeRecibido(patrullaje));
    });

    // ACTUALIZADO PATRULLAJE
    _actualizadoSub = patrullajeUseCases.listenPatrullajeActualizado
        .run()
        .listen((patrullaje) {
          add(PatrullajeActualizadoRecibido(patrullaje));
        });
  }

  // =========================
  // 1. LOAD ACTIVO (HTTP)
  // =========================
  Future<void> _onLoadPatrullajeActivo(
    LoadPatrullajeActivo event,
    Emitter<HomeState> emit,
  ) async {
    // LOADING
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final patrullaje = await patrullajeUseCases.getPatrullajeActivo.run();

      print("Patrullaje activo cargado: ${patrullaje?.id}");
      // SUCCESS
      if (patrullaje != null) {
        emit(
          state.copyWith(
            isLoading: false,
            patrullaje: patrullaje,
            // activo: true,
            status: mapEstado(patrullaje.estado),
          ),
        );
      } else {
        emit(
          state.copyWith(
            isLoading: false,
            status: PatrullajeStatus.sinAsignacion,
          ),
        );
      }
    } catch (e) {
      //  ERROR
      emit(
        state.copyWith(
          isLoading: false,
          error: e.toString(),
          status: PatrullajeStatus.error,
        ),
      );
    }
  }

  // =========================
  // 2. NUEVO PATRULLAJE (SOCKET)
  // =========================
  void _onNuevoPatrullaje(
    NuevoPatrullajeRecibido event,
    Emitter<HomeState> emit,
  ) {
    print("Nuevo patrullaje recibido en BLoC");

    emit(
      state.copyWith(
        patrullaje: event.patrullaje,
        status: PatrullajeStatus.asignado,
        isLoading: false,
      ),
    );
  }

  void _onPatrullajeActualizado(
    PatrullajeActualizadoRecibido event,
    Emitter<HomeState> emit,
  ) {
    final nuevoEstado = mapEstado(event.patrullaje.estado);

    // SI FINALIZA → limpiar
    if (nuevoEstado == PatrullajeStatus.finalizado) {
      emit(
        state.copyWith(
          patrullaje: null,
          status: PatrullajeStatus.finalizado,
          isLoading: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        patrullaje: event.patrullaje,
        status: nuevoEstado,
        isLoading: false,
      ),
    );
  }

  // =========================
  // 3. ACEPTAR PATRULLAJE
  // =========================
  void _onAceptarPatrullaje(
    AceptarPatrullaje event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, status: PatrullajeStatus.aceptando));

    patrullajeUseCases.startPatrullajeSocket.run(event.patrullajeId);
    patrullajeUseCases.joinPatrullaje.run(event.patrullajeId);
  }

  // =========================
  // 4. FINALIZAR PATRULLAJE
  // =========================
  Future<void> _onFinalizarPatrullaje(
    FinalizarPatrullaje event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      await patrullajeUseCases.endPatrullaje.run(event.patrullajeId);

      emit(
        state.copyWith(
          isLoading: false,
          patrullaje: null,
          status: PatrullajeStatus.finalizado,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          error: e.toString(),
          status: PatrullajeStatus.error,
        ),
      );
    }
  }

 
  // =========================
  // CLEANUP
  // =========================

  PatrullajeStatus mapEstado(String estado) {
    switch (estado) {
      case 'ASIGNADO':
        return PatrullajeStatus.asignado;
      case 'ACEPTADO':
        return PatrullajeStatus.aceptando;
      case 'EN_CURSO':
        return PatrullajeStatus.enCurso;
      case 'FINALIZADO':
        return PatrullajeStatus.finalizado;
      default:
        return PatrullajeStatus.sinAsignacion;
    }
  }

  @override
  Future<void> close() {
    _nuevoPatrullajeSub?.cancel();
    _actualizadoSub?.cancel();
    return super.close();
  }
}
