import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Bloc's
import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/bloc/historial_patrullaje_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/bloc/historial_patrullaje_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/bloc/historial_patrullaje_state.dart';

// Widgets
import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/view/listado/widgets/historial_empty_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/view/listado/widgets/historial_error_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/view/listado/widgets/historial_loading.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/view/listado/widgets/historial_patrullaje_list.dart';

class HistorialPatrullajeContent extends StatelessWidget {
  final int patrullajeId;

  const HistorialPatrullajeContent({super.key, required this.patrullajeId});

  Future<void> _refresh(BuildContext context) async {
    final bloc = context.read<HistorialPatrullajeBloc>();

    bloc.add(
      LoadHistorialPatrullajeEvent(patrullajeId: patrullajeId, refresh: true),
    );

    await bloc.stream.firstWhere(
      (state) => state.listStatus != HistorialListStatus.loading,
    );
  }

  void _retry(BuildContext context) {
    context.read<HistorialPatrullajeBloc>().add(
      LoadHistorialPatrullajeEvent(patrullajeId: patrullajeId, refresh: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistorialPatrullajeBloc, HistorialPatrullajeState>(
      buildWhen: (previous, current) {
        return previous.listStatus != current.listStatus ||
            previous.historial != current.historial ||
            previous.errorMessage != current.errorMessage;
      },
      builder: (context, state) {
        switch (state.listStatus) {
          case HistorialListStatus.initial:
          case HistorialListStatus.loading:
            return const HistorialLoading();

          case HistorialListStatus.empty:
            return HistorialEmptyState(onRefresh: () => _retry(context));

          case HistorialListStatus.error:
            return HistorialErrorState(
              message: state.errorMessage ?? 'No se pudo obtener el historial.',
              onRetry: () => _retry(context),
            );

          case HistorialListStatus.success:
            return RefreshIndicator(
              onRefresh: () => _refresh(context),
              child: HistorialPatrullajeList(historial: state.historial),
            );
        }
      },
    );
  }
}
