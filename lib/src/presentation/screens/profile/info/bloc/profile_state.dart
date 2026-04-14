import 'package:equatable/equatable.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/usuarios.dart';

class ProfileState extends Equatable {
  final Usuario? user;

  const ProfileState({this.user});

  ProfileState copyWith({Usuario? user}) {
    return ProfileState(user: user);
  }

  @override
  List<Object?> get props => [user];
}
