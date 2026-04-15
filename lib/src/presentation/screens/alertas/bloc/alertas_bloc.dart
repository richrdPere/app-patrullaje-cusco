import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'alertas_event.dart';
part 'alertas_state.dart';

class AlertasBloc extends Bloc<AlertasEvent, AlertasState> {
  AlertasBloc() : super(AlertasInitial()) {
    on<AlertasEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
