part of 'alertas_bloc.dart';

sealed class AlertasState extends Equatable {
  const AlertasState();
  
  @override
  List<Object> get props => [];
}

final class AlertasInitial extends AlertasState {}
