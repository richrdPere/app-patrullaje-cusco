import 'package:bloc/bloc.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/PatrullajeUseCases.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  PatrullajeUseCases patrullajeUseCases;

  HomeBloc(this.patrullajeUseCases) : super(HomeState()) {
    on<LoadPatrullajeActivo>(_onLoadPatrullajeActivo);
  }

  // HANDLER LIMPIO
  Future<void> _onLoadPatrullajeActivo(
    LoadPatrullajeActivo event,
    Emitter<HomeState> emit,
  ) async {
    // LOADING
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final patrullaje = await patrullajeUseCases.getPatrullajeActivo.run();

      print("ZONA PATRULLAJE: ${patrullaje.zona.coordenadas}");

      // SUCCESS
      emit(state.copyWith(isLoading: false, patrullaje: patrullaje));
    } catch (e) {
      //  ERROR
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
