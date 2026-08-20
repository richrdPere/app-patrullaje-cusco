// mis_patrullajes_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_sereno_query_params.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/mis-patrullaje/listado/mis_patrullajes_content.dart';

class MisPatrullajesPage extends StatefulWidget {
  const MisPatrullajesPage({super.key});

  @override
  State<MisPatrullajesPage> createState() => _MisPatrullajesPageState();
}

class _MisPatrullajesPageState extends State<MisPatrullajesPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final bloc = context.read<HomeBloc>();

      /*
       * Solo vuelve a solicitar la información si todavía
       * no se cargó el listado.
       */
      if (bloc.state.misPatrullajes == null) {
        bloc.add(
          const LoadMisPatrullajes(
            params: PatrullajeSerenoQueryParams(
              page: 1,
              limit: 10,
              orderBy: PatrullajeOrderBy.fecha,
              orderDirection: OrderDirection.desc,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Patrullajes',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 26,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (previous, current) {
            return previous.misPatrullajes != current.misPatrullajes ||
                previous.misPatrullajesParams != current.misPatrullajesParams ||
                previous.isLoadingMisPatrullajes !=
                    current.isLoadingMisPatrullajes ||
                previous.misPatrullajesError != current.misPatrullajesError;
          },
          builder: (context, state) {
            return MisPatrullajesContent(homeState: state);
          },
        ),
      ),
    );
  }
}
