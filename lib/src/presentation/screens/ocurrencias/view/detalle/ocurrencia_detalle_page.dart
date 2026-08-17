import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';

// Modelos
import 'package:sis_patrullaje_cusco/src/data/models/common/api_response.dart';
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_detalle_data.dart';
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_pdf_data.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

// BloC
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/bloc/ocurrencia_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/bloc/ocurrencia_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/bloc/ocurrencia_state.dart';

// Content
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/view/detalle/ocurrencia_detalle_content.dart';

class OcurrenciaDetallePage extends StatefulWidget {
  final int ocurrenciaId;

  const OcurrenciaDetallePage({super.key, required this.ocurrenciaId});

  @override
  State<OcurrenciaDetallePage> createState() => _OcurrenciaDetallePageState();
}

class _OcurrenciaDetallePageState extends State<OcurrenciaDetallePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _getOcurrencia();
    });
  }

  @override
  void dispose() {
    final bloc = context.read<OcurrenciaBloc>();

    bloc.add(const ClearOcurrenciaDetailResponse());
    bloc.add(const ClearOcurrenciaPdfResponse());

    super.dispose();
  }

  void _getOcurrencia() {
    context.read<OcurrenciaBloc>().add(
      GetOcurrenciaById(ocurrenciaId: widget.ocurrenciaId),
    );
  }

  void _generatePdf() {
    context.read<OcurrenciaBloc>().add(
      GetOcurrenciaPdf(ocurrenciaId: widget.ocurrenciaId),
    );
  }

  Future<void> _sharePdf(OcurrenciaPdfData pdf) async {
    await Printing.sharePdf(bytes: pdf.bytes, filename: pdf.fileName);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<OcurrenciaBloc, OcurrenciaState>(
          listenWhen: (previous, current) {
            return previous.detailResponse != current.detailResponse;
          },
          listener: (context, state) {
            final response = state.detailResponse;

            if (response is ErrorData<ApiResponse<OcurrenciaDetalleData>>) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(response.message),
                    behavior: SnackBarBehavior.floating,
                    action: SnackBarAction(
                      label: 'Reintentar',
                      onPressed: _getOcurrencia,
                    ),
                  ),
                );
            }
          },
        ),
        BlocListener<OcurrenciaBloc, OcurrenciaState>(
          listenWhen: (previous, current) {
            return previous.pdfResponse != current.pdfResponse;
          },
          listener: (context, state) async {
            final response = state.pdfResponse;

            if (response is Success<OcurrenciaPdfData>) {
              try {
                await _sharePdf(response.data);
              } catch (error) {
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('No se pudo compartir el PDF: $error'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } finally {
                if (context.mounted) {
                  context.read<OcurrenciaBloc>().add(
                    const ClearOcurrenciaPdfResponse(),
                  );
                }
              }
            }

            if (response is ErrorData<OcurrenciaPdfData>) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(response.message),
                    behavior: SnackBarBehavior.floating,
                  ),
                );

              context.read<OcurrenciaBloc>().add(
                const ClearOcurrenciaPdfResponse(),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalle de ocurrencia'),
          actions: [
            BlocBuilder<OcurrenciaBloc, OcurrenciaState>(
              buildWhen: (previous, current) {
                return previous.pdfResponse != current.pdfResponse ||
                    previous.detailResponse != current.detailResponse;
              },
              builder: (context, state) {
                final isLoadingPdf = state.isLoadingPdf;

                final hasDetail =
                    state.detailResponse
                        is Success<ApiResponse<OcurrenciaDetalleData>>;

                return IconButton(
                  tooltip: 'Generar PDF',
                  onPressed: hasDetail && !isLoadingPdf ? _generatePdf : null,
                  icon: isLoadingPdf
                      ? const SizedBox(
                          width: 21,
                          height: 21,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.picture_as_pdf_outlined),
                );
              },
            ),
            IconButton(
              tooltip: 'Actualizar',
              onPressed: _getOcurrencia,
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: SafeArea(
          child: OcurrenciaDetalleContent(
            ocurrenciaId: widget.ocurrenciaId,
            onRetry: _getOcurrencia,
          ),
        ),
      ),
    );
  }
}
