import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Modelos
import 'package:sis_patrullaje_cusco/src/data/models/common/api_response.dart';
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_paginated.dart';
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_query_params.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

// BloC
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/bloc/ocurrencia_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/bloc/ocurrencia_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/bloc/ocurrencia_state.dart';

// Content
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/view/listado/ocurrencias_content.dart';

class OcurrenciasPage extends StatelessWidget {
  const OcurrenciasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<OcurrenciaBloc, OcurrenciaState>(
      listenWhen: (previous, current) {
        return previous.paginatedResponse != current.paginatedResponse;
      },
      listener: (context, state) {
        final response = state.paginatedResponse;

        if (response is ErrorData<ApiResponse<OcurrenciaPaginated>>) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(response.message),
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'Reintentar',
                  onPressed: () {
                    context.read<OcurrenciaBloc>().add(
                      const GetOcurrenciasPaginado(
                        params: OcurrenciaQueryParams(page: 1, limit: 20),
                      ),
                    );
                  },
                ),
              ),
            );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Ocurrencias'), centerTitle: false),
        body: const SafeArea(child: OcurrenciasContent()),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            context.pushNamed('ocurrencia_crear');
          
          },
          icon: const Icon(Icons.add_rounded),
          label: const Text('Registrar'),
        ),
      ),
    );
  }
}
