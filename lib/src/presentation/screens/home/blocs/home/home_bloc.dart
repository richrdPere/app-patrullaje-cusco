import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/patrullaje_entity.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/PatrullajeUseCases.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  PatrullajeUseCases patrullajeUseCases;

  StreamSubscription? _nuevoPatrullajeSub;
  StreamSubscription? _finalizadoSub;

  HomeBloc(this.patrullajeUseCases) : super(HomeState()) {
    on<LoadPatrullajeActivo>(_onLoadPatrullajeActivo);
    on<NuevoPatrullajeRecibido>(_onNuevoPatrullaje);
    on<PatrullajeFinalizadoRecibido>(_onPatrullajeFinalizado);
    on<AceptarPatrullaje>(_onAceptarPatrullaje);
    // INICIAR LISTENERS
    on<InitSocketListeners>(_onInitSocketListeners);
  }

  // SOCKET LISTENERS
  void _onInitSocketListeners(
    InitSocketListeners event,
    Emitter<HomeState> emit,
  ) {
    print("Inicializando listeners de socket...");

    _nuevoPatrullajeSub?.cancel();
    _finalizadoSub?.cancel();

    // NUEVO PATRULLAJE
    _nuevoPatrullajeSub = patrullajeUseCases.listenNewPatrullaje.run().listen(
      (patrullaje) {
        try {
          if (patrullaje == null) {
            print("⚠️ Patrullaje recibido es NULL");
            return;
          }

          print("📡 NUEVO PATRULLAJE RECIBIDO:");
          print("ID: ${patrullaje.id}");
          print("Estado: ${patrullaje.estado}");
          print("Zona: ${patrullaje.zona.nombre}");

          add(NuevoPatrullajeRecibido(patrullaje));
        } catch (e) {
          print("❌ ERROR procesando patrullaje: $e");
        }
      },
      onError: (error) {
        print("❌ ERROR EN STREAM nuevo patrullaje: $error");
      },
    );

    // FINALIZADO
    _finalizadoSub = patrullajeUseCases.listenPatrullajeEnd.run().listen(
      (id) {
        try {
          print("📡 PATRULLAJE FINALIZADO RECIBIDO: $id");

          if (id == null) {
            print("⚠️ ID finalizado es NULL");
            return;
          }

          add(PatrullajeFinalizadoRecibido(id));
        } catch (e) {
          print("❌ ERROR procesando finalizado: $e");
        }
      },
      onError: (error) {
        print("❌ ERROR EN STREAM finalizado: $error");
      },
    );
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
            activo: true,
            status: PatrullajeStatus
                .enCurso, // OJO: si el patrullaje activo se carga desde el backend, asumimos que ya está en curso. Si queremos ser más precisos, podríamos revisar el estado del patrullaje y asignar el status correcto (asignado, aceptando, enCurso). Pero para simplificar, lo dejamos como enCurso
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
        activo: true,
        success: true,
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
    print("Aceptando patrullaje...");

    try {
      // 1. Emitir al backend
      await patrullajeUseCases.startPatrullajeSocket.run(event.patrullajeId);

      // 2. Unirse al room
      await patrullajeUseCases.joinPatrullaje.run(event.patrullajeId);

      emit(
        state.copyWith(
          isLoading: false,
          status: PatrullajeStatus
              .enCurso, // asumimos que al aceptar el patrullaje, este pasa directamente a enCurso. Si queremos ser más precisos, podríamos esperar una confirmación del backend vía socket para cambiar el estado a enCurso, pero para simplificarlo, lo hacemos de inmediato.
          activo: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          status: PatrullajeStatus.error,
          error: e.toString(),
        ),
      );
    }
  }

  // =========================
  // 4. FINALIZADO
  // =========================
  void _onPatrullajeFinalizado(
    PatrullajeFinalizadoRecibido event,
    Emitter<HomeState> emit,
  ) async {
    print("Patrullaje finalizado");

    try {
      await patrullajeUseCases.leavePatrullaje.run(event.patrullajeId);

      emit(
        state.copyWith(
          patrullaje: null,
          activo: false,
          status: PatrullajeStatus.finalizado,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: PatrullajeStatus.error, error: e.toString()));
    }
  }

  // =========================
  // CLEANUP
  // =========================
  @override
  Future<void> close() {
    _nuevoPatrullajeSub?.cancel();
    _finalizadoSub?.cancel();
    return super.close();
  }
}
