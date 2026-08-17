import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Models
import 'package:sis_patrullaje_cusco/src/data/models/common/api_response.dart';
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_detalle_data.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

// BloC
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/bloc/ocurrencia_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/bloc/ocurrencia_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/bloc/ocurrencia_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/view/form/ocurrencia_form_content.dart';

class OcurrenciaFormPage extends StatelessWidget {
  const OcurrenciaFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<OcurrenciaBloc, OcurrenciaState>(
      listenWhen: (previous, current) {
        return previous.createResponse != current.createResponse;
      },
      listener: (context, state) {
        final response = state.createResponse;

        if (response is Success<ApiResponse<OcurrenciaDetalleData>>) {
          final ocurrencia = response.data.data;

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(response.data.message),
                behavior: SnackBarBehavior.floating,
              ),
            );

          context.read<OcurrenciaBloc>().add(
            const ClearOcurrenciaCreateResponse(),
          );

          if (context.canPop()) {
            context.pop(true);
          } else if (ocurrencia != null) {
            context.go('/ocurrencias/${ocurrencia.id}');
          } else {
            context.go('/ocurrencias');
          }
        }

        if (response is ErrorData<ApiResponse<OcurrenciaDetalleData>>) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(response.message),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Nueva ocurrencia')),
        body: const SafeArea(child: OcurrenciaFormContent()),
      ),
    );
  }
}
