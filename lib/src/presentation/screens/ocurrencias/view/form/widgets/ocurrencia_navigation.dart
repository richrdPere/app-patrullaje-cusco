import 'package:flutter/material.dart';

class OcurrenciaNavigation extends StatelessWidget {
  /// Índice actual comenzando desde cero.
  final int currentStep;

  final int totalSteps;

  /// Índices de los pasos que ya fueron validados.
  final List<int> completedSteps;

  final bool isLoading;

  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onSubmit;

  const OcurrenciaNavigation({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.completedSteps,
    required this.isLoading,
    this.onPrevious,
    this.onNext,
    this.onSubmit,
  });

  bool get isFirstStep => currentStep <= 0;

  bool get isLastStep => currentStep >= totalSteps - 1;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 12,
      color: Theme.of(context).colorScheme.surface,
      shadowColor: Colors.black.withAlpha(50),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _NavigationButtons(
                isFirstStep: isFirstStep,
                isLastStep: isLastStep,
                isLoading: isLoading,
                onPrevious: onPrevious,
                onNext: onNext,
                onSubmit: onSubmit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// BOTONES DE NAVEGACIÓN
// ============================================================

class _NavigationButtons extends StatelessWidget {
  final bool isFirstStep;
  final bool isLastStep;
  final bool isLoading;

  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final VoidCallback? onSubmit;

  const _NavigationButtons({
    required this.isFirstStep,
    required this.isLastStep,
    required this.isLoading,
    this.onPrevious,
    this.onNext,
    this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ====================================================
        // BOTÓN ANTERIOR
        // ====================================================
        if (!isFirstStep)
          OutlinedButton.icon(
            onPressed: isLoading ? null : onPrevious,
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('ANTERIOR'),
          )
        else
          const SizedBox.shrink(),

        // ====================================================
        // BOTÓN SIGUIENTE / REGISTRAR
        // ====================================================
        if (isLastStep)
          FilledButton.icon(
            onPressed: isLoading ? null : onSubmit,
            icon: isLoading
                ? const SizedBox.square(
                    dimension: 19,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(
              isLoading ? 'REGISTRANDO...' : 'REGISTRAR OCURRENCIA',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )
        else
          FilledButton.icon(
            onPressed: isLoading ? null : onNext,
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('SIGUIENTE'),
          ),
      ],
    );
  }
}
