import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

// Modelos
import 'package:sis_patrullaje_cusco/src/data/models/common/api_response.dart';
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_detalle_data.dart';
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_pdf_data.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

// BLoC
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
  late OcurrenciaBloc _ocurrenciaBloc;

  bool _blocInitialized = false;

  // ==========================================================
  // OBTENER REFERENCIA SEGURA AL BLOC
  // ==========================================================

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_blocInitialized) {
      _ocurrenciaBloc = context.read<OcurrenciaBloc>();
      _blocInitialized = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        _getOcurrencia();
      });
    }
  }

  // Ya no es necesario cargar desde initState.
  @override
  void initState() {
    super.initState();
  }

  // ==========================================================
  // LIMPIAR
  // ==========================================================

  @override
  void dispose() {
    // No se utiliza context.read() aquí.
    if (_blocInitialized) {
      _ocurrenciaBloc.add(const ClearOcurrenciaDetailResponse());

      _ocurrenciaBloc.add(const ClearOcurrenciaPdfResponse());
    }

    super.dispose();
  }

  // ==========================================================
  // EVENTOS
  // ==========================================================

  void _getOcurrencia() {
    _ocurrenciaBloc.add(GetOcurrenciaById(ocurrenciaId: widget.ocurrenciaId));
  }

  void _generatePdf() {
    _ocurrenciaBloc.add(GetOcurrenciaPdf(ocurrenciaId: widget.ocurrenciaId));
  }

  Future<void> _sharePdf(OcurrenciaPdfData pdf) async {
    await Printing.sharePdf(bytes: pdf.bytes, filename: pdf.fileName);
  }

  // ========================================================
  // CERRAR FULLSCREEN DIALOG
  // ========================================================

  void _close() {
    if (!mounted) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    if (context.canPop()) {
      // Cierra sin devolver un clasificador.
      context.pop<OcurrenciaDetalleData>();
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Detalle
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

        // PDF
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
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('No se pudo compartir el PDF: $error'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } finally {
                // Usa la referencia guardada al BLoC.
                if (_blocInitialized) {
                  _ocurrenciaBloc.add(const ClearOcurrenciaPdfResponse());
                }
              }
            }

            if (response is ErrorData<OcurrenciaPdfData>) {
              if (!mounted) return;

              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(response.message),
                    behavior: SnackBarBehavior.floating,
                  ),
                );

              _ocurrenciaBloc.add(const ClearOcurrenciaPdfResponse());
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalle de ocurrencia'),
          leading: IconButton(
            tooltip: 'Cerrar',
            onPressed: _close,
            icon: const Icon(Icons.close_rounded),
          ),
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
